extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := CharacterBody3D.new()
    player.name = "ParryRegressionPlayer"
    player.set_script(load("res://scripts/player_controller.gd"))
    root.add_child(player)

    var attacker := CharacterBody3D.new()
    attacker.name = "ParryRegressionEnemy"
    attacker.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(attacker)
    await process_frame

    player.global_position = Vector3.ZERO
    player.rotation = Vector3.ZERO
    attacker.global_position = Vector3(0.0, 0.0, -2.0)
    player.parry_timer = 0.22
    var starting_health: float = player.health
    player.take_damage(20.0, attacker)
    if not is_equal_approx(player.health, starting_health):
        push_error("A correctly timed frontal parry must prevent damage without lock-on.")
        quit(1)
        return
    if attacker.state != attacker.State.STAGGER:
        push_error("A successful parry must stagger the actual attacking enemy.")
        quit(1)
        return
    if player.parry_timer > 0.0:
        push_error("A successful parry must consume the parry window.")
        quit(1)
        return

    attacker.state = attacker.State.CHASE
    attacker.global_position = Vector3(0.0, 0.0, 2.0)
    player.parry_timer = 0.22
    var expected_rear_damage: float = 20.0 * (1.0 - float(player.call("get_damage_reduction")))
    player.take_damage(20.0, attacker)
    if not is_equal_approx(player.health, starting_health - expected_rear_damage):
        push_error("A rear attack must not be parried; normal armour mitigation should still apply.")
        quit(1)
        return
    if attacker.state == attacker.State.STAGGER:
        push_error("A rear attack must not stagger the attacker through a frontal parry.")
        quit(1)
        return

    attacker.queue_free()
    player.queue_free()
    await process_frame
    print("PASS: parry resolves against the real attacker without lock-on and rejects rear attacks")
    quit(0)
