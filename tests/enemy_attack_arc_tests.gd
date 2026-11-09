extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := Node3D.new()
    player.name = "AttackArcTestPlayer"
    root.add_child(player)

    var enemy := CharacterBody3D.new()
    enemy.name = "AttackArcTestEnemy"
    enemy.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(enemy)
    await process_frame

    enemy.global_position = Vector3.ZERO
    enemy.rotation = Vector3.ZERO
    enemy.player = player

    player.global_position = Vector3(0.0, 0.0, -2.0)
    if not enemy.can_hit_player():
        push_error("A player directly in front must be inside the attack arc.")
        quit(1)
        return

    player.global_position = Vector3(0.0, 0.0, 2.0)
    if enemy.can_hit_player():
        push_error("A player behind the enemy must not be hit by a frontal strike.")
        quit(1)
        return

    player.global_position = Vector3(2.0, 0.0, 0.0)
    if enemy.can_hit_player():
        push_error("A player outside the frontal strike arc must not be hit.")
        quit(1)
        return

    player.global_position = Vector3(0.0, 2.0, -2.0)
    if enemy.can_hit_player():
        push_error("A player too far above the attack plane must not be hit.")
        quit(1)
        return

    enemy.queue_free()
    player.queue_free()
    await process_frame
    print("PASS: enemy attack arc validates front, rear, side and vertical separation")
    quit(0)
