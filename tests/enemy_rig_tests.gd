extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var cases := [
        {"name": "Ashen Hollow", "script": load("res://scripts/training_enemy.gd"), "idle": "Zombie_Idle"},
        {"name": "Ashen Watch Shield Guard", "script": load("res://scripts/shield_guard.gd"), "idle": "Zombie_Idle"},
        {"name": "Ashen Ember Archer", "script": load("res://scripts/ashen_archer.gd"), "idle": "Zombie_Idle"}
    ]
    for entry in cases:
        var enemy := CharacterBody3D.new()
        enemy.name = entry.name.replace(" ", "")
        enemy.set_script(entry.script)
        root.add_child(enemy)
        await process_frame
        var visual: Node = enemy.get("enemy_visual")
        var animation_player: AnimationPlayer = enemy.get("enemy_animation_player")
        if visual == null or not visual is Node3D:
            push_error(entry.name + " did not create a rigged 3D visual.")
            enemy.queue_free()
            quit(1)
            return
        if animation_player == null or not animation_player.has_animation(entry.idle):
            push_error(entry.name + " did not load its undead idle animation.")
            enemy.queue_free()
            quit(1)
            return
        var required_clips := ["Zombie_Idle", "Zombie_Walk_Fwd", "Jog_Fwd", "Sword_Regular_A", "Hit_Chest", "Death01"]
        for clip in required_clips:
            if not animation_player.has_animation(clip):
                push_error(entry.name + " is missing required combat clip: " + clip)
                enemy.queue_free()
                quit(1)
                return
        if entry.name == "Ashen Watch Shield Guard":
            for visual_name in ["AshenWatchShield", "GuardIronHelm", "GuardBreastplate", "GuardLeftPauldron", "GuardRightPauldron"]:
                if enemy.get_node_or_null(visual_name) == null:
                    push_error("Shield Guard is missing its defining visual: " + visual_name)
                    enemy.queue_free()
                    quit(1)
                    return
        elif entry.name == "Ashen Ember Archer":
            for visual_name in ["AshenEmberBow", "ArcherAshHood", "ArcherShoulderMantle", "ArcherBackQuiver"]:
                if enemy.get_node_or_null(visual_name) == null:
                    push_error("Ember Archer is missing its defining visual: " + visual_name)
                    enemy.queue_free()
                    quit(1)
                    return
        var state_cases := [
            {"state": enemy.State.IDLE, "clip": "Zombie_Idle"},
            {"state": enemy.State.PATROL, "clip": "Zombie_Walk_Fwd"},
            {"state": enemy.State.CHASE, "clip": "Jog_Fwd"},
            {"state": enemy.State.STAGGER, "clip": "Hit_Chest"},
            {"state": enemy.State.DEAD, "clip": "Death01"}
        ]
        for state_case in state_cases:
            enemy.state = state_case.state
            enemy._update_enemy_animation()
            if animation_player.current_animation != state_case.clip:
                push_error(entry.name + " state did not select " + state_case.clip + "; got " + animation_player.current_animation)
                enemy.queue_free()
                quit(1)
                return
        print("PASS: ", entry.name, " rig supports idle, locomotion, attack, stagger, death and state-driven clip selection")
        enemy.queue_free()
        await process_frame
    quit(0)
