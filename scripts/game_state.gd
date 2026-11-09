extends Node

signal recovery_changed(position: Vector3, essence: int, active: bool)
signal sanctuary_restored(position: Vector3)

const SAVE_PATH := "user://soul_land_save.json"
const SAVE_VERSION := 2
const RECOVERY_RADIUS := 2.6

var data: Dictionary = {
    "version": SAVE_VERSION,
    "player": {"health": 100.0, "stamina": 100.0, "level": 1, "soul_essence": 0},
    "location": "ashen_kingdom_training_ground",
    "inventory": [],
    "discovered_areas": [],
    "defeated_bosses": [],
    "quest_flags": {},
    "world_flags": {},
    "sanctuary_position": [0.0, 1.05, 6.0],
    "dropped_essence": 0,
    "recovery_position": [0.0, 0.0, 0.0],
    "has_recovery": false
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

func get_soul_essence() -> int:
    return int(data.get("player", {}).get("soul_essence", 0))

func get_sanctuary_position() -> Vector3:
    var stored: Array = data.get("sanctuary_position", [0.0, 1.05, 6.0])
    return Vector3(float(stored[0]), float(stored[1]), float(stored[2]))

func rest_at_sanctuary(position: Vector3, player: Node) -> void:
    data["sanctuary_position"] = [position.x, position.y, position.z]
    set_player_location("ashen_kingdom_training_ground")
    if is_instance_valid(player) and player.has_method("restore_at_sanctuary"):
        player.restore_at_sanctuary()
    sanctuary_restored.emit(position)
    save_game()

func register_player_death(death_position: Vector3) -> void:
    var lost := get_soul_essence()
    if lost > 0:
        data["dropped_essence"] = lost
        data["recovery_position"] = [death_position.x, death_position.y, death_position.z]
        data["has_recovery"] = true
        recovery_changed.emit(death_position, lost, true)
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
    var version := int(loaded.get("version", 0))
    if version < 1 or version > SAVE_VERSION:
        push_warning("SOUL LAND save version is unsupported; starting with defaults.")
        return false
    data.merge(loaded, true)
    data["version"] = SAVE_VERSION
    return true

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
