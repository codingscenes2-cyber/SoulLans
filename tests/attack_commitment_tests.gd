extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := CharacterBody3D.new()
    player.name = "AttackCommitmentTestPlayer"
    player.set_script(load("res://scripts/player_controller.gd"))
    player.set("enable_visual_body", false)
    root.add_child(player)
    await process_frame

    player.stamina = player.max_stamina
    player.attack_cooldown = 0.0
    player.perform_attack()
    if not is_equal_approx(player.attack_movement_multiplier, 0.55):
        push_error("Light attacks must apply the intended movement commitment.")
        quit(1)
        return

    player.attack_cooldown = 0.0
    player.perform_heavy_attack()
    if not is_equal_approx(player.attack_movement_multiplier, 0.35):
        push_error("Heavy attacks must commit the player more strongly than light attacks.")
        quit(1)
        return
    if player.attack_movement_multiplier >= 0.55:
        push_error("Heavy attack movement must be slower than light attack movement.")
        quit(1)
        return

    player.attack_cooldown = 0.5
    player.attack_windup = 0.2
    player.attack_active_timer = 0.0
    player.dodge_timer = 0.0
    player.perform_dodge()
    if player.dodge_timer > 0.0:
        push_error("Dodge must not cancel attack wind-up.")
        quit(1)
        return

    player.attack_windup = 0.0
    player.attack_active_timer = 0.1
    player.perform_dodge()
    if player.dodge_timer > 0.0:
        push_error("Dodge must not cancel the active strike.")
        quit(1)
        return

    player.attack_active_timer = 0.0
    player.attack_cooldown = 0.3
    player.perform_dodge()
    if player.dodge_timer <= 0.0 or player.attack_cooldown > 0.0:
        push_error("Dodge should cancel recovery when permitted.")
        quit(1)
        return

    player.queue_free()
    await process_frame
    print("PASS: attack commitment and recovery-only dodge cancel")
    quit(0)
