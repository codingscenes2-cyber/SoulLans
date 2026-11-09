extends SceneTree

func _initialize() -> void:
    var model_path := "res://assets/characters/ashen_hero.glb"
    var packed := load(model_path) as PackedScene
    if packed == null:
        push_error("Rigged hero GLB did not import as a PackedScene: " + model_path)
        quit(1)
        return
    var instance := packed.instantiate()
    var counts := {"skeletons": 0, "meshes": 0}
    _count_model_nodes(instance, counts)
    print("Hero asset smoke test: skeletons=", counts.skeletons, " meshes=", counts.meshes)
    if counts.skeletons < 1 or counts.meshes < 1:
        push_error("Hero asset must contain at least one Skeleton3D and one MeshInstance3D.")
        instance.free()
        quit(1)
        return
    instance.free()
    quit(0)

func _count_model_nodes(node: Node, counts: Dictionary) -> void:
    if node is Skeleton3D:
        counts.skeletons += 1
    if node is MeshInstance3D:
        counts.meshes += 1
    for child in node.get_children():
        _count_model_nodes(child, counts)
