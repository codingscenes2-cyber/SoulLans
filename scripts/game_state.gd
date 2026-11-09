extends Node

signal recovery_changed(position: Vector3, essence: int, active: bool)
signal sanctuary_restored(position: Vector3)

const SAVE_PATH := "user://soul_land_save.json"
const SAVE_BACKUP_PATH := "user://soul_land_save.backup.json"
const SAVE_TEMP_PATH := "user://soul_land_save.tmp.json"
const SAVE_VERSION := 2
const RECOVERY_RADIUS := 2.6
const AUTOSAVE_INTERVAL := 15.0

const ITEM_CATALOG := {
    "ashen_iron_sword": {"name": "Ashen Iron Sword", "type": "weapon", "description": "Balanced straight sword recovered from the old watchpost."},
    "ashen_watch_dagger": {"name": "Ashen Watch Dagger", "type": "weapon", "description": "Fast sidearm with short reach and quick recovery."},
    "ashen_tonic": {"name": "Ashen Tonic", "type": "consumable", "description": "Restores 45 HP. Cannot exceed maximum health."},
    "ashen_scrap": {"name": "Ashen Scrap", "type": "material", "description": "Salvaged metal fragments from fallen Ashen foes."},
    "tempered_plate": {"name": "Tempered Plate", "type": "material", "description": "A durable plate stripped from an Ashen Watch shield."},
    "regent_core": {"name": "Ashen Regent Core", "type": "material", "description": "A dense soul-forged core left by the fallen regional ruler."}
}


var autosave_timer := 0.0

var data: Dictionary = {
    "version": SAVE_VERSION,
    "player": {"health": 100.0, "stamina": 100.0, "level": 1, "soul_essence": 0, "attributes": {"vigor": 10, "endurance": 10, "strength": 10, "dexterity": 10}, "healing_flasks": 3, "max_healing_flasks": 3},
    "location": "ashen_kingdom_training_ground",
    "inventory": [],
    "equipment": {"weapon": "ashen_iron_sword"},
    "inventory_initialized": false,
    "discovered_areas": [],
    "defeated_bosses": [],
    "quest_flags": {},
    "quests": {},
    "world_flags": {},
    "sanctuary_position": [0.0, 1.05, 6.0],
    "dropped_essence": 0,
    "recovery_position": [0.0, 0.0, 0.0],
    "has_recovery": false
}

func _ready() -> void:
    load_game()
    _ensure_starter_inventory()

func _process(delta: float) -> void:
    autosave_timer += delta
    if autosave_timer >= AUTOSAVE_INTERVAL:
        autosave_timer = 0.0
        save_game()

func _ensure_starter_inventory() -> void:
    var items: Array = data.get("inventory", [])
    var changed := false
    if not bool(data.get("inventory_initialized", false)):
        for starter_id in ["ashen_iron_sword", "ashen_watch_dagger", "ashen_tonic"]:
            if get_item_count(starter_id) <= 0:
                items.append({"id": starter_id, "quantity": 2 if starter_id == "ashen_tonic" else 1})
                changed = true
        data["inventory_initialized"] = true
        changed = true
    data["inventory"] = items
    var equipment: Dictionary = data.get("equipment", {})
    var equipped_id := str(equipment.get("weapon", ""))
    var equipped_info := get_item_info(equipped_id)
    if str(equipped_info.get("type", "")) != "weapon" or get_item_count(equipped_id) <= 0:
        if get_item_count("ashen_iron_sword") > 0:
            equipment["weapon"] = "ashen_iron_sword"
        elif get_item_count("ashen_watch_dagger") > 0:
            equipment["weapon"] = "ashen_watch_dagger"
        data["equipment"] = equipment
        changed = true
    if changed:
        save_game()

func get_inventory() -> Array:
    var items: Array = data.get("inventory", [])
    return items.duplicate(true)

func get_item_info(item_id: String) -> Dictionary:
    var info: Dictionary = ITEM_CATALOG.get(item_id, {})
    return info.duplicate(true)

func get_item_count(item_id: String) -> int:
    var items: Array = data.get("inventory", [])
    for entry in items:
        if entry is Dictionary and str(entry.get("id", "")) == item_id:
            return maxi(0, int(entry.get("quantity", 0)))
    return 0

func add_item(item_id: String, quantity: int = 1) -> bool:
    if not ITEM_CATALOG.has(item_id) or quantity <= 0:
        return false
    var items: Array = data.get("inventory", [])
    for index in range(items.size()):
        if items[index] is Dictionary and str(items[index].get("id", "")) == item_id:
            var entry: Dictionary = items[index]
            entry["quantity"] = int(entry.get("quantity", 0)) + quantity
            items[index] = entry
            data["inventory"] = items
            save_game()
            return true
    items.append({"id": item_id, "quantity": quantity})
    data["inventory"] = items
    save_game()
    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    if quantity <= 0 or get_item_count(item_id) < quantity:
        return false
    var items: Array = data.get("inventory", [])
    for index in range(items.size()):
        if items[index] is Dictionary and str(items[index].get("id", "")) == item_id:
            var entry: Dictionary = items[index]
            var remaining := int(entry.get("quantity", 0)) - quantity
            if remaining <= 0:
                items.remove_at(index)
            else:
                entry["quantity"] = remaining
                items[index] = entry
            data["inventory"] = items
            save_game()
            return true
    return false

func get_equipped_weapon_id() -> String:
    var equipment: Dictionary = data.get("equipment", {})
    return str(equipment.get("weapon", "ashen_iron_sword"))

func equip_weapon(item_id: String) -> bool:
    var info := get_item_info(item_id)
    if str(info.get("type", "")) != "weapon" or get_item_count(item_id) <= 0:
        return false
    var equipment: Dictionary = data.get("equipment", {})
    equipment["weapon"] = item_id
    data["equipment"] = equipment
    save_game()
    return true

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
    save_game()

func get_soul_essence() -> int:
    return int(data.get("player", {}).get("soul_essence", 0))

func get_healing_flasks() -> int:
    return int(data.get("player", {}).get("healing_flasks", 3))

func get_max_healing_flasks() -> int:
    return int(data.get("player", {}).get("max_healing_flasks", 3))

func consume_healing_flask() -> bool:
    var player_data: Dictionary = data.get("player", {})
    var count := int(player_data.get("healing_flasks", 3))
    if count <= 0:
        return false
    player_data["healing_flasks"] = count - 1
    data["player"] = player_data
    save_game()
    return true

func refill_healing_flasks() -> void:
    var player_data: Dictionary = data.get("player", {})
    player_data["healing_flasks"] = get_max_healing_flasks()
    data["player"] = player_data
    save_game()

func get_player_level() -> int:
    return int(data.get("player", {}).get("level", 1))

func get_player_attributes() -> Dictionary:
    var player_data: Dictionary = data.get("player", {})
    var attributes: Dictionary = player_data.get("attributes", {})
    var defaults := {"vigor": 10, "endurance": 10, "strength": 10, "dexterity": 10}
    defaults.merge(attributes, true)
    return defaults

func get_next_level_cost() -> int:
    return 100 + maxi(0, get_player_level() - 1) * 50

func level_up_attribute(attribute_id: String) -> bool:
    var allowed := ["vigor", "endurance", "strength", "dexterity"]
    if not allowed.has(attribute_id):
        return false
    var cost := get_next_level_cost()
    if get_soul_essence() < cost:
        return false
    var player_data: Dictionary = data.get("player", {})
    var attributes: Dictionary = get_player_attributes()
    attributes[attribute_id] = int(attributes.get(attribute_id, 10)) + 1
    player_data["attributes"] = attributes
    player_data["level"] = get_player_level() + 1
    player_data["soul_essence"] = get_soul_essence() - cost
    data["player"] = player_data
    save_game()
    return true


func get_sanctuary_position() -> Vector3:
    var stored: Array = data.get("sanctuary_position", [0.0, 1.05, 6.0])
    return Vector3(float(stored[0]), float(stored[1]), float(stored[2]))

func rest_at_sanctuary(position: Vector3, player: Node) -> void:
    data["sanctuary_position"] = [position.x, position.y, position.z]
    set_player_location("ashen_kingdom_training_ground")
    refill_healing_flasks()
    if is_instance_valid(player) and player.has_method("restore_at_sanctuary"):
        player.restore_at_sanctuary()
    sanctuary_restored.emit(position)
    save_game()

func register_player_death(death_position: Vector3) -> void:
    var lost := get_soul_essence()
    data["dropped_essence"] = lost
    data["recovery_position"] = [death_position.x, death_position.y, death_position.z]
    data["has_recovery"] = lost > 0
    recovery_changed.emit(death_position, lost, lost > 0)
    var player_data: Dictionary = data.get("player", {})
    player_data["soul_essence"] = 0
    player_data["health"] = 100.0
    player_data["stamina"] = 100.0
    data["player"] = player_data
    save_game()

func try_recover_souls(player_position: Vector3) -> bool:
    if not bool(data.get("has_recovery", false)):
        return false
    var stored: Array = data.get("recovery_position", [0.0, 0.0, 0.0])
    var dropped_position := Vector3(float(stored[0]), float(stored[1]), float(stored[2]))
    if player_position.distance_to(dropped_position) > RECOVERY_RADIUS:
        return false
    var player_data: Dictionary = data.get("player", {})
    player_data["soul_essence"] = int(player_data.get("soul_essence", 0)) + int(data.get("dropped_essence", 0))
    data["player"] = player_data
    data["dropped_essence"] = 0
    data["has_recovery"] = false
    recovery_changed.emit(Vector3.ZERO, 0, false)
    save_game()
    return true

func get_recovery_position() -> Vector3:
    var stored: Array = data.get("recovery_position", [0.0, 0.0, 0.0])
    return Vector3(float(stored[0]), float(stored[1]), float(stored[2]))

func has_recovery() -> bool:
    return bool(data.get("has_recovery", false))

func get_dropped_essence() -> int:
    return int(data.get("dropped_essence", 0))

func set_player_location(location_id: String) -> void:
    data["location"] = location_id
    var discovered: Array = data.get("discovered_areas", [])
    if not discovered.has(location_id):
        discovered.append(location_id)
    data["discovered_areas"] = discovered

func get_quest_state(quest_id: String) -> Dictionary:
    var quests: Dictionary = data.get("quests", {})
    var stored: Variant = quests.get(quest_id, {})
    if stored is Dictionary:
        if stored.is_empty():
            return {"status": "not_started", "progress": 0, "target": 0, "reward": 0}
        return stored.duplicate(true)
    return {"status": "not_started", "progress": 0, "target": 0, "reward": 0}

func start_quest(quest_id: String, target: int, reward: int) -> bool:
    if quest_id.is_empty() or target <= 0 or reward < 0:
        return false
    if str(get_quest_state(quest_id).get("status", "not_started")) != "not_started":
        return false
    var quests: Dictionary = data.get("quests", {})
    quests[quest_id] = {
        "status": "active",
        "progress": 0,
        "target": target,
        "reward": reward,
        "reward_claimed": false
    }
    data["quests"] = quests
    save_game()
    return true

func advance_quest(quest_id: String, amount: int = 1) -> bool:
    if amount <= 0:
        return false
    var quest := get_quest_state(quest_id)
    if str(quest.get("status", "not_started")) != "active":
        return false
    var target := maxi(1, int(quest.get("target", 1)))
    quest["progress"] = mini(target, int(quest.get("progress", 0)) + amount)
    var completed := int(quest["progress"]) >= target
    if completed:
        quest["status"] = "completed"
    var quests: Dictionary = data.get("quests", {})
    quests[quest_id] = quest
    data["quests"] = quests
    if completed and not bool(quest.get("reward_claimed", false)):
        quest["reward_claimed"] = true
        quests[quest_id] = quest
        data["quests"] = quests
        award_soul_essence(int(quest.get("reward", 0)))
    else:
        save_game()
    return true

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
    save_game()

func is_boss_defeated(boss_id: String) -> bool:
    return data.get("defeated_bosses", []).has(boss_id)

func _is_supported_save_text(contents: String) -> bool:
    var parser := JSON.new()
    if parser.parse(contents) != OK:
        return false
    if typeof(parser.data) != TYPE_DICTIONARY:
        return false
    var version := int(parser.data.get("version", 0))
    return version >= 1 and version <= SAVE_VERSION

func _read_supported_save(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var contents := file.get_as_text()
    file.close()
    if not _is_supported_save_text(contents):
        return {}
    var parsed: Variant = JSON.parse_string(contents)
    return parsed

func save_game() -> bool:
    data["version"] = SAVE_VERSION
    var temporary_file := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
    if temporary_file == null:
        push_error("SOUL LAND could not create a temporary save file.")
        return false
    temporary_file.store_string(JSON.stringify(data, "\t"))
    temporary_file.flush()
    temporary_file.close()

    # Preserve the last known-good save before replacing it. Invalid files are
    # never promoted to the backup slot.
    if FileAccess.file_exists(SAVE_PATH):
        var previous_contents := FileAccess.get_file_as_string(SAVE_PATH)
        if _is_supported_save_text(previous_contents):
            var backup_file := FileAccess.open(SAVE_BACKUP_PATH, FileAccess.WRITE)
            if backup_file != null:
                backup_file.store_string(previous_contents)
                backup_file.flush()
                backup_file.close()
        var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
        if remove_error != OK:
            push_error("SOUL LAND could not replace the previous save: %s" % error_string(remove_error))
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_TEMP_PATH))
            return false

    var rename_error := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(SAVE_TEMP_PATH),
        ProjectSettings.globalize_path(SAVE_PATH)
    )
    if rename_error != OK:
        push_error("SOUL LAND could not finalize the save: %s" % error_string(rename_error))
        if FileAccess.file_exists(SAVE_BACKUP_PATH) and not FileAccess.file_exists(SAVE_PATH):
            DirAccess.rename_absolute(
                ProjectSettings.globalize_path(SAVE_BACKUP_PATH),
                ProjectSettings.globalize_path(SAVE_PATH)
            )
        return false
    return true

func load_game() -> bool:
    var loaded := _read_supported_save(SAVE_PATH)
    var restored_from_backup := false
    if loaded.is_empty():
        loaded = _read_supported_save(SAVE_BACKUP_PATH)
        restored_from_backup = not loaded.is_empty()
    if loaded.is_empty():
        if FileAccess.file_exists(SAVE_PATH):
            push_warning("SOUL LAND primary save is invalid and no valid backup was found.")
        return false

    data.merge(loaded, true)
    data["version"] = SAVE_VERSION
    if restored_from_backup:
        push_warning("SOUL LAND restored the last known-good backup save.")
        save_game()
    return true

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
