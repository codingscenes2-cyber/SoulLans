extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := CharacterBody3D.new()
    player.name = "DirectionalBlockTestPlayer"
    player.set_script(load("res://scripts/player_controller.gd"))
    root.add_child(player)

    var attacker := CharacterBody3D.new()
    attacker.name = "DirectionalBlockTestEnemy"
    attacker.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(attacker)
    await process_frame

    player.global_position = Vector3.ZERO
    player.rotation = Vector3.ZERO
    attacker.global_position = Vector3(0.0, 0.0, -2.0)
    player.health = player.max_health
    player.stamina = player.max_stamina
    player.is_blocking = true
    player.take_damage(20.0, attacker)
    if not is_equal_approx(player.health, player.max_health):
        push_error("A frontal block with sufficient stamina must prevent health damage.")
        quit(1)
        return
    if not is_equal_approx(player.stamina, player.max_stamina - 27.0):
        push_error("A frontal block must consume 1.35 times incoming damage as stamina.")
        quit(1)
        return

    player.health = player.max_health
    player.stamina = player.max_stamina
    attacker.global_position = Vector3(0.0, 0.0, 2.0)
    player.is_blocking = true
    var expected_rear_damage: float = 20.0 * (1.0 - float(player.call("get_damage_reduction")))
    player.take_damage(20.0, attacker)
    if not is_equal_approx(player.health, player.max_health - expected_rear_damage):
        push_error("A rear attack must bypass a forward-facing block while armour still mitigates damage.")
        quit(1)
        return

    player.health = player.max_health
    player.stamina = 10.0
    attacker.global_position = Vector3(0.0, 0.0, -2.0)
    player.is_blocking = true
    player.guard_broken_timer = 0.0
    player.take_damage(20.0, attacker)
    if player.guard_broken_timer <= 0.0:
        push_error("Insufficient stamina while blocking must cause guard break.")
        quit(1)
        return
    if player.stamina != 0.0 or player.health >= player.max_health:
        push_error("Guard break must empty stamina and apply overflow damage.")
        quit(1)
        return

    attacker.queue_free()
    player.queue_free()
    await process_frame
    print("PASS: directional block, stamina cost, rear vulnerability and guard break")
    quit(0)
