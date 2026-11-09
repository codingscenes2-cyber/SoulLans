extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := CharacterBody3D.new()
    player.name = "PlayerMeleeArcTest"
    var player_script: Script = load("res://scripts/player_controller.gd")
    if player_script == null:
        push_error("Player controller script failed to load.")
        quit(1)
        return
    player.set_script(player_script)
    player.set("enable_visual_body", false)
    root.add_child(player)
    await process_frame
    if not player.has_method("is_target_in_melee_arc"):
        push_error("Player controller did not initialise the melee arc API.")
        quit(1)
        return
    player.global_position = Vector3.ZERO
    player.rotation = Vector3.ZERO
    player.current_attack_range = 2.5

    if not player.is_target_in_melee_arc(Vector3(0.0, 0.0, -2.0)):
        push_error("A target directly in front must be inside the melee swing.")
        quit(1)
        return
    if player.is_target_in_melee_arc(Vector3(0.0, 0.0, 2.0)):
        push_error("A target behind the player must not be hit.")
        quit(1)
        return
    if player.is_target_in_melee_arc(Vector3(2.0, 0.0, 0.0)):
        push_error("A target directly beside the player must be outside the swing arc.")
        quit(1)
        return
    if player.is_target_in_melee_arc(Vector3(0.0, 0.0, -3.0)):
        push_error("A target outside weapon reach must not be hit.")
        quit(1)
        return
    if player.is_target_in_melee_arc(Vector3(0.0, 2.0, -2.0)):
        push_error("A target outside the vertical swing plane must not be hit.")
        quit(1)
        return

    print("PASS: player melee swing arc validates front, rear, side, range and vertical separation")
    quit(0)
