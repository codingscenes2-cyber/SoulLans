extends SceneTree

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player: Variant = CharacterBody3D.new()
    player.name = "InventoryTestPlayer"
    player.set_script(PLAYER_SCRIPT)
    root.add_child(player)
    await process_frame

    _expect(str(player.get_weapon_name()) == "Ashen Iron Sword", "saved starter weapon loads into the player")
    _expect(bool(player.call("equip_weapon_by_id", "ashen_watch_dagger")), "player can equip an owned dagger")
    _expect(str(player.get_weapon_name()) == "Ashen Watch Dagger", "equipping updates the active weapon resource")
    _expect(GameState.get_equipped_weapon_id() == "ashen_watch_dagger", "player equipment change persists")

    player.set("health", 50.0)
    _expect(bool(player.call("use_inventory_item", "ashen_tonic")), "player can consume an Ashen Tonic")
    _expect(is_equal_approx(float(player.get("health")), 95.0), "Ashen Tonic restores 45 health")
    _expect(GameState.get_item_count("ashen_tonic") == 1, "consumed tonic is removed from inventory")
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
