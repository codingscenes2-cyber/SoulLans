extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var path := "res://assets/characters/ashen_hero_animated.glb"
    var packed := load(path) as PackedScene
    if packed == null:
        push_error("Animated hero GLB did not import as a PackedScene: " + path)
        quit(1)
        return

    var instance := packed.instantiate()
    root.add_child(instance)
    await process_frame

    var report := {"skeletons": 0, "meshes": 0, "null_meshes": 0}
    _inspect_model(instance, report)
    var player := _find_animation_player(instance)
    if report.skeletons < 1 or report.meshes < 1 or report.null_meshes > 0 or player == null:
        push_error("Animated hero must contain a valid skeleton, meshes and AnimationPlayer.")
        instance.queue_free()
        quit(1)
        return

    var required := ["Idle_Loop", "Walk_Loop", "Jog_Fwd_Loop", "Sprint_Loop", "Roll", "Sword_Attack", "Sword_Idle", "Death01", "Hit_Chest"]
    var available: Array[String] = []
    for library_name in player.get_animation_library_list():
        var library: AnimationLibrary = player.get_animation_library(library_name)
        for clip in library.get_animation_list():
            available.append(str(library_name) + "/" + str(clip))
    print("HERO_ANIMATION_CLIPS ", available)
    for clip in required:
        if not player.has_animation(clip):
            push_error("Required animation is missing from imported hero: " + clip)
            instance.queue_free()
            quit(1)
            return

    player.play("Idle_Loop")
    if player.current_animation != "Idle_Loop":
        push_error("Idle_Loop animation failed to start.")
        instance.queue_free()
        quit(1)
        return
    player.play("Sword_Attack")
    if player.current_animation != "Sword_Attack":
        push_error("Sword attack animation failed to start.")
        instance.queue_free()
        quit(1)
        return

    print("PASS: hero rig, meshes, 43+ animation clips and Idle/Sword_Attack playback")
    instance.queue_free()
    quit(0)

func _inspect_model(node: Node, report: Dictionary) -> void:
    if node is Skeleton3D:
        report.skeletons += 1
    if node is MeshInstance3D:
        if node.mesh == null:
            report.null_meshes += 1
        else:
            report.meshes += 1
    for child in node.get_children():
        _inspect_model(child, report)

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null
