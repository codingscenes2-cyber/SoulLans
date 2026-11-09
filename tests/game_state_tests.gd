extends SceneTree

const GAME_STATE_SCRIPT = preload("res://scripts/game_state.gd")
const PRIMARY_PATH := "user://soul_land_save.json"
const BACKUP_PATH := "user://soul_land_save.backup.json"
const TEMP_PATH := "user://soul_land_save.tmp.json"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    _remove_test_files()
    var state: Variant = GAME_STATE_SCRIPT.new()
    root.add_child(state)

    state.data["player"]["soul_essence"] = 321
    _expect(state.save_game(), "first save writes successfully")
    state.data["player"]["soul_essence"] = 654
    _expect(state.save_game(), "second save writes successfully")
    _expect(FileAccess.file_exists(BACKUP_PATH), "second save creates a backup")
    _expect(int(state.data["player"]["soul_essence"]) == 654, "current in-memory save remains current")

    _write_text(PRIMARY_PATH, "{ definitely not valid JSON")
    _expect(state.load_game(), "invalid primary save recovers from backup")
    _expect(state.get_soul_essence() == 321, "backup restores the previous known-good essence amount")

    _write_text(PRIMARY_PATH, JSON.stringify({
        "version": 1,
        "player": {
            "health": 72.0,
            "stamina": 44.0,
            "level": 3,
            "soul_essence": 0
        }
    }))
    _expect(state.load_game(), "version 1 save loads")
    _expect(state.get_player_level() == 3, "version 1 player level is retained")
    _expect(int(state.get_player_attributes().get("vigor", 0)) == 10, "missing legacy attributes receive defaults")

    state.data["player"]["soul_essence"] = 200
    state.register_player_death(Vector3(2.0, 0.0, -3.0))
    _expect(state.get_soul_essence() == 0 and state.get_dropped_essence() == 200, "death moves unspent essence to recovery")
    _expect(not state.try_recover_souls(Vector3(20.0, 0.0, 20.0)), "recovery rejects distant position")
    _expect(state.try_recover_souls(Vector3(2.0, 0.0, -3.0)), "recovery succeeds inside radius")
    _expect(state.get_soul_essence() == 200 and not state.has_recovery(), "recovery restores essence and clears marker")

    state.data["player"]["soul_essence"] = 200
    _expect(state.level_up_attribute("vigor"), "level-up spends the required essence")
    _expect(state.get_player_level() == 4 and int(state.get_player_attributes()["vigor"]) == 11, "level-up increments level and attribute")
    _expect(state.get_soul_essence() == 0, "level-up deducts essence")

    _expect(state.start_quest("ashen_sigils", 3, 120), "quest can be accepted once")
    _expect(not state.start_quest("ashen_sigils", 3, 120), "active quest cannot be accepted twice")
    _expect(state.advance_quest("ashen_sigils"), "quest objective records first defeat")
    _expect(int(state.get_quest_state("ashen_sigils").get("progress", 0)) == 1, "quest progress persists after first defeat")
    _expect(state.advance_quest("ashen_sigils", 2), "quest accepts multiple objective increments")
    _expect(str(state.get_quest_state("ashen_sigils").get("status", "")) == "completed", "quest completes at its target")
    _expect(state.get_soul_essence() == 120, "quest completion grants its reward")
    _expect(not state.advance_quest("ashen_sigils"), "completed quest cannot be progressed or rewarded again")
    _expect(state.get_soul_essence() == 120, "quest reward cannot be claimed twice")

    _expect(state.get_item_count("ashen_iron_sword") >= 1, "starter sword is present in inventory")
    _expect(state.get_item_count("ashen_watch_dagger") >= 1, "starter dagger is present in inventory")
    _expect(state.equip_weapon("ashen_watch_dagger"), "owned dagger can be equipped")
    _expect(state.get_equipped_weapon_id() == "ashen_watch_dagger", "equipped weapon selection is stored")
    _expect(not state.equip_weapon("regent_core"), "materials cannot be equipped as weapons")
    _expect(state.add_item("ashen_scrap", 3), "material stack can be added")
    _expect(state.get_item_count("ashen_scrap") == 3, "material quantity is tracked")
    _expect(state.remove_item("ashen_scrap", 2), "partial stack removal succeeds")
    _expect(state.get_item_count("ashen_scrap") == 1, "partial removal leaves the correct quantity")
    _expect(not state.remove_item("ashen_scrap", 2), "inventory prevents removing more than owned")

    state.free()
    _remove_test_files()
    if failures.is_empty():
        print("SOUL LAND GameState regression tests: PASS")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

func _expect(condition: bool, description: String) -> void:
    if condition:
        print("PASS: " + description)
    else:
        failures.append("FAIL: " + description)

func _write_text(path: String, contents: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        failures.append("FAIL: could not write test fixture " + path)
        return
    file.store_string(contents)
    file.close()

func _remove_test_files() -> void:
    for path in [PRIMARY_PATH, BACKUP_PATH, TEMP_PATH]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
