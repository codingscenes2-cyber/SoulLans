extends Node

const SAVE_PATH := "user://soul_land_save.json"
const SAVE_VERSION := 1

var data: Dictionary = {
    "version": SAVE_VERSION,
    "player": {"health": 100.0, "stamina": 100.0, "level": 1, "soul_essence": 0},
    "location": "ashen_kingdom_training_ground",
    "inventory": [],
    "discovered_areas": [],
    "defeated_bosses": [],
    "quest_flags": {},
    "world_flags": {}
}

func _ready() -> void:
    load_game()

func update_player_snapshot(health: float, stamina: float) -> void:
    var player_data: Dictionary = data.get("player", {})
    player_data["health"] = health
    player_data["stamina"] = stamina
    data["player"] = player_data

func apply_to_player(player: Node) -> void:
    if is_instance_valid(player) and player.has_method("apply_saved_state"):
        player.apply_saved_state(data.get("player", {}))

func award_soul_essence(amount: int) -> void:
    var player_data: Dictionary = data.get("player", {})
    player_data["soul_essence"] = maxi(0, int(player_data.get("soul_essence", 0)) + amount)
    data["player"] = player_data

func set_player_location(location_id: String) -> void:
    data["location"] = location_id
    var discovered: Array = data.get("discovered_areas", [])
    if not discovered.has(location_id):
        discovered.append(location_id)
    data["discovered_areas"] = discovered

func set_quest_flag(flag_id: String, value: Variant = true) -> void:
    var flags: Dictionary = data.get("quest_flags", {})
    flags[flag_id] = value
    data["quest_flags"] = flags

func set_world_flag(flag_id: String, value: Variant = true) -> void:
    var flags: Dictionary = data.get("world_flags", {})
    flags[flag_id] = value
    data["world_flags"] = flags

func mark_boss_defeated(boss_id: String) -> void:
    var bosses: Array = data.get("defeated_bosses", [])
    if not bosses.has(boss_id):
        bosses.append(boss_id)
    data["defeated_bosses"] = bosses

func save_game() -> bool:
    data["version"] = SAVE_VERSION
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("SOUL LAND save failed: %s" % error_string(FileAccess.get_open_error()))
        return false
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_error("SOUL LAND save could not be opened.")
        return false
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("SOUL LAND save is invalid JSON or has an unsupported structure.")
        return false
    var loaded: Dictionary = parsed
    if int(loaded.get("version", 0)) != SAVE_VERSION:
        push_warning("SOUL LAND save version mismatch; starting with defaults.")
        return false
    data = loaded
    return true

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
