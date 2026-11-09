extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var cases := [
        {"name": "Ashen Hollow", "script": load("res://scripts/training_enemy.gd"), "idle": "Zombie_Idle"},
        {"name": "Ashen Watch Shield Guard", "script": load("res://scripts/shield_guard.gd"), "idle": "Zombie_Idle"}
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
        animation_player.play(entry.idle)
        if animation_player.current_animation != entry.idle:
            push_error(entry.name + " could not start its idle animation.")
            enemy.queue_free()
            quit(1)
            return
        print("PASS: ", entry.name, " uses rigged animated humanoid")
        enemy.queue_free()
        await process_frame
    quit(0)
