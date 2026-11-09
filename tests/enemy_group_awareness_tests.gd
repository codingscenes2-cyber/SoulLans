extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := Node3D.new()
    player.name = "GroupAwarenessPlayer"
    player.add_to_group("player")
    player.global_position = Vector3(0.0, 0.0, -3.0)
    root.add_child(player)

    var caller := CharacterBody3D.new()
    caller.name = "GroupAwarenessCaller"
    caller.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(caller)

    var nearby := CharacterBody3D.new()
    nearby.name = "NearbyAlly"
    nearby.set_script(load("res://scripts/training_enemy.gd"))
    nearby.global_position = Vector3(0.0, 0.0, -6.0)
    root.add_child(nearby)

    var distant := CharacterBody3D.new()
    distant.name = "DistantAlly"
    distant.set_script(load("res://scripts/training_enemy.gd"))
    distant.global_position = Vector3(0.0, 0.0, -30.0)
    root.add_child(distant)
    await process_frame

    caller.player = player
    caller._alert_nearby_enemies()
    if nearby.state != nearby.State.INVESTIGATE:
        push_error("A nearby idle ally must investigate the caller's last known player position.")
        quit(1)
        return
    if nearby.last_known_player_position.distance_to(player.global_position) > 0.01:
        push_error("Nearby ally must receive the correct last known player position.")
        quit(1)
        return
    if distant.state != distant.State.IDLE:
        push_error("Enemies outside the alert radius must not be pulled into the encounter.")
        quit(1)
        return
    if caller.state != caller.State.IDLE:
        push_error("Group alert must not overwrite the initiating enemy's state.")
        quit(1)
        return

    print("PASS: enemy group awareness alerts nearby allies while respecting alert radius")
    quit(0)
