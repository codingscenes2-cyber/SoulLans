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

    var required := ["Idle", "Walk", "Jog_Fwd", "Sprint", "Roll", "Sword_Attack", "Sword_Idle", "Death01", "Hit_Chest"]
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

    player.play("Idle")
    if player.current_animation != "Idle":
        push_error("Idle animation failed to start.")
        instance.queue_free()
        quit(1)
        return
    player.play("Sword_Attack")
    if player.current_animation != "Sword_Attack":
        push_error("Sword attack animation failed to start.")
        instance.queue_free()
        quit(1)
        return

    var player_body := CharacterBody3D.new()
    player_body.name = "ArmorAttachmentRegressionPlayer"
    player_body.set_script(load("res://scripts/player_controller.gd"))
    player_body.set("enable_visual_body", true)
    root.add_child(player_body)
    await process_frame
    var armor_roots: Dictionary = player_body.get("armor_visual_roots")
    if armor_roots.size() != 3:
        push_error("Hero rig must expose head, chest and legs armour attachment points. Found: " + str(armor_roots.keys()))
        player_body.queue_free()
        instance.queue_free()
        quit(1)
        return
    for slot in ["head", "chest", "legs"]:
        var armor_root: Node3D = armor_roots.get(slot)
        if not is_instance_valid(armor_root) or armor_root.get_child_count() == 0:
            push_error("Equipped " + slot + " armour must create visible meshes on the hero rig.")
            player_body.queue_free()
            instance.queue_free()
            quit(1)
            return
    var initial_head_count := (armor_roots["head"] as Node3D).get_child_count()
    if not player_body.equip_armor_by_id("scout_hood"):
        push_error("Re-equipping owned armour must succeed.")
        player_body.queue_free()
        instance.queue_free()
        quit(1)
        return
    if (armor_roots["head"] as Node3D).get_child_count() != initial_head_count:
        push_error("Changing equipped armour must refresh its visual attachment.")
        player_body.queue_free()
        instance.queue_free()
        quit(1)
        return
    print("PASS: equipped head, chest and leg armour attach to animated hero skeleton and refresh on equip")
    player_body.queue_free()
\n    print("PASS: hero rig, meshes, 43+ animation clips and Idle/Sword_Attack playback")
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
