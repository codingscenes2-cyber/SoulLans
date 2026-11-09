extends SceneTree

func _initialize() -> void:
    var model_path := "res://assets/characters/ashen_hero.glb"
    var packed := load(model_path) as PackedScene
    if packed == null:
        push_error("Rigged hero GLB did not import as a PackedScene: " + model_path)
        quit(1)
        return
    var instance := packed.instantiate()
    var report := {"skeletons": 0, "meshes": 0, "null_meshes": 0, "animation_players": 0, "animation_libraries": [], "skeleton_paths": []}
    _inspect_model(instance, report)
    print("HERO_ASSET_REPORT ", JSON.stringify(report))
    if report.skeletons < 1 or report.meshes < 1 or report.null_meshes > 0:
        push_error("Hero asset must contain a skeleton and valid meshes.")
        instance.free()
        quit(1)
        return
    instance.free()
    quit(0)

func _inspect_model(node: Node, report: Dictionary) -> void:
    if node is Skeleton3D:
        report.skeletons += 1
        var bones: Array[String] = []
        for index in range(node.get_bone_count()):
            bones.append(node.get_bone_name(index))
        report.skeleton_paths.append({"path": str(node.get_path()), "bones": bones})
    if node is MeshInstance3D:
        if node.mesh == null:
            report.null_meshes += 1
            print("NULL_MESH_NODE ", node.get_path())
        else:
            report.meshes += 1
    if node is AnimationPlayer:
        report.animation_players += 1
        var libraries: Array[String] = []
        for library_name in node.get_animation_library_list():
            var library: AnimationLibrary = node.get_animation_library(library_name)
            for animation_name in library.get_animation_list():
                libraries.append(str(library_name) + "/" + str(animation_name))
        report.animation_libraries.append({"path": str(node.get_path()), "clips": libraries})
    for child in node.get_children():
        _inspect_model(child, report)
