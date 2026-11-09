extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := Node3D.new()
    player.name = "CoordinationPlayer"
    player.add_to_group("player")
    player.global_position = Vector3.ZERO
    root.add_child(player)

    var enemies: Array[CharacterBody3D] = []
    var positions := [Vector3(0.0, 0.0, -2.0), Vector3(2.0, 0.0, -4.0), Vector3(-3.0, 0.0, -5.0)]
    for index in range(positions.size()):
        var enemy := CharacterBody3D.new()
        enemy.name = "CoordinationEnemy%d" % index
        enemy.set_script(load("res://scripts/training_enemy.gd"))
        enemy.global_position = positions[index]
        root.add_child(enemy)
        enemies.append(enemy)

    await process_frame
    for enemy in enemies:
        enemy.player = player

    var ranks: Array[int] = []
    var flank_points: Array[Vector3] = []
    for enemy in enemies:
        ranks.append(enemy._get_group_rank())
        flank_points.append(enemy._get_chase_destination())

    if ranks.size() != 3 or ranks[0] != 0 or ranks[1] == ranks[0] or ranks[2] == ranks[0]:
        push_error("The closest enemy must receive the primary attack lane and other enemies distinct flank ranks.")
        quit(1)
        return
    if enemies[0]._should_begin_attack(1.5) != true:
        push_error("The primary enemy must be allowed to begin its melee attack.")
        quit(1)
        return
    if enemies[1]._should_begin_attack(1.5) or enemies[2]._should_begin_attack(1.5):
        push_error("Secondary enemies must not stack simultaneous melee wind-ups.")
        quit(1)
        return
    if flank_points[1].distance_to(flank_points[2]) < 0.5:
        push_error("Secondary enemies must receive spatially distinct flank destinations.")
        quit(1)
        return

    var archer := CharacterBody3D.new()
    archer.name = "CoordinatedArcher"
    archer.set_script(load("res://scripts/ashen_archer.gd"))
    archer.global_position = Vector3(4.0, 0.0, -6.0)
    root.add_child(archer)
    await process_frame
    archer.player = player
    if archer._get_group_rank() <= 0:
        push_error("A supporting archer must be assigned a non-primary support lane when closer allies are present.")
        quit(1)
        return
    if archer._should_begin_attack(7.0):
        push_error("A supporting archer must not claim the primary firing lane while a closer ally is engaged.")
        quit(1)
        return
    if archer._get_chase_destination().distance_to(player.global_position) < 4.0:
        push_error("A supporting archer must hold a ranged flank instead of crowding the player.")
        quit(1)
        return

    enemies[0].state = enemies[0].State.DEAD
    if enemies[1]._get_group_rank() != 0 or not enemies[1]._should_begin_attack(1.5):
        push_error("The next closest living enemy must take over the primary attack lane when the leader dies.")
        quit(1)
        return

    print("PASS: enemy groups coordinate attack lanes, distinct flanks and primary-attacker handoff")
    quit(0)
