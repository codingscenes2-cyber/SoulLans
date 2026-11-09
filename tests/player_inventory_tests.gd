extends SceneTree

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game_state: Variant = root.get_node("GameState")
    var player: Variant = CharacterBody3D.new()
    player.name = "InventoryTestPlayer"
    player.set_script(PLAYER_SCRIPT)
    root.add_child(player)
    await process_frame

    _expect(str(player.get_weapon_name()) == "Ashen Iron Sword", "saved starter weapon loads into the player")
    _expect(bool(player.call("equip_weapon_by_id", "ashen_watch_dagger")), "player can equip an owned dagger")
    _expect(str(player.get_weapon_name()) == "Ashen Watch Dagger", "equipping updates the active weapon resource")
    _expect(str(game_state.call("get_equipped_weapon_id")) == "ashen_watch_dagger", "player equipment change persists")

    var damage_before_upgrade: float = float(player.call("_get_scaled_weapon_damage"))
    var test_smith := Node3D.new()
    test_smith.add_to_group("blacksmiths")
    test_smith.global_position = Vector3(4.2, 1.05, 6.0)
    root.add_child(test_smith)
    player.global_position = test_smith.global_position
    _expect(bool(player.call("is_near_blacksmith")), "blacksmith proximity is detected")
    game_state.call("add_item", "ashen_scrap", 3)
    _expect(bool(player.call("upgrade_weapon_by_id", "ashen_watch_dagger")), "weapon can be upgraded at the Sanctuary")
    var damage_after_upgrade: float = float(player.call("_get_scaled_weapon_damage"))
    _expect(damage_after_upgrade > damage_before_upgrade * 1.11, "weapon upgrade increases actual attack damage")
    _expect(int(game_state.call("get_weapon_upgrade_level", "ashen_watch_dagger")) == 1, "player weapon upgrade is saved")

    var armor_stats: Dictionary = game_state.call("get_armor_stats")
    _expect(is_equal_approx(float(armor_stats.get("defense", 0.0)), 16.0), "starter armour totals sixteen defence")
    _expect(is_equal_approx(float(armor_stats.get("weight", 0.0)), 10.0), "starter armour weight is tracked")
    var load_status: Dictionary = player.call("get_status")
    _expect(str(load_status.get("equip_load_tier", "")) == "medium", "starter armour uses the medium equip-load tier")
    _expect(float(load_status.get("damage_reduction", 0.0)) > 0.13, "armour calculates damage reduction")
    player.set("health", 100.0)
    player.call("take_damage", 20.0)
    _expect(float(player.get("health")) > 80.0 and float(player.get("health")) < 100.0, "armour reduces incoming damage without negating it")

    player.set("health", 50.0)
    _expect(bool(player.call("use_inventory_item", "ashen_tonic")), "player can consume an Ashen Tonic")
    _expect(is_equal_approx(float(player.get("health")), 95.0), "Ashen Tonic restores 45 health")
    _expect(int(game_state.call("get_item_count", "ashen_tonic")) == 1, "consumed tonic is removed from inventory")
    _expect(bool(player.call("use_inventory_item", "ashen_tonic")), "second tonic can be used to top off health")
    _expect(is_equal_approx(float(player.get("health")), float(player.get("max_health"))), "tonic healing clamps at maximum health")
    _expect(not bool(player.call("use_inventory_item", "ashen_tonic")), "consumed tonics cannot be used again")

    player.queue_free()
    await process_frame
    if failures.is_empty():
        print("SOUL LAND player inventory regression tests: PASS")
        quit(0)
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, description: String) -> void:
    if condition:
        print("PASS: " + description)
    else:
        failures.append("FAIL: " + description)
