extends SceneTree

func _initialize() -> void:
    var path := "res://assets/animations/UAL1_Standard.glb"
    var packed := load(path) as PackedScene
    if packed == null:
        push_error("Quaternius UAL1 did not import as a PackedScene.")
        quit(1)
        return
    var instance := packed.instantiate()
    var report := {"skeletons": [], "animation_players": [], "clip_count": 0}
    _inspect(instance, report)
    print("UAL1_ASSET_REPORT ", JSON.stringify(report))
    if report.clip_count < 1:
        push_error("UAL1 imported without animation clips.")
        instance.free()
        quit(1)
        return
    instance.free()
    quit(0)

func _inspect(node: Node, report: Dictionary) -> void:
    if node is Skeleton3D:
        var bones: Array[String] = []
        for i in range(node.get_bone_count()):
            bones.append(node.get_bone_name(i))
        report.skeletons.append({"path": str(node.get_path()), "bones": bones})
    if node is AnimationPlayer:
        var clips: Array[String] = []
        for library_name in node.get_animation_library_list():
            var library: AnimationLibrary = node.get_animation_library(library_name)
            for animation_name in library.get_animation_list():
                clips.append(str(animation_name))
        report.clip_count += clips.size()
        report.animation_players.append({"path": str(node.get_path()), "clips": clips})
    for child in node.get_children():
        _inspect(child, report)
