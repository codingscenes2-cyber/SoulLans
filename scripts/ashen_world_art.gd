extends RefCounted
# Authored Ashen Kingdom dressing and mobile-friendly PBR material setup.
# CC0 source textures are fetched by CI from Poly Haven and imported by Godot.

const MATERIAL_ROOT := "res://assets/materials/"
const GROUND_DIFF := MATERIAL_ROOT + "concrete_floor_01_diff_1k.jpg"
const GROUND_NORMAL := MATERIAL_ROOT + "concrete_floor_01_nor_gl_1k.jpg"
const GROUND_ROUGH := MATERIAL_ROOT + "concrete_floor_01_rough_1k.jpg"
const STONE_DIFF := MATERIAL_ROOT + "rock_wall_17_diff_1k.jpg"
const STONE_NORMAL := MATERIAL_ROOT + "rock_wall_17_nor_gl_1k.jpg"
const STONE_ROUGH := MATERIAL_ROOT + "rock_wall_17_rough_1k.jpg"

static var _ground_mat: StandardMaterial3D
static var _stone_mat: StandardMaterial3D

static func build(parent: Node3D) -> void:
    _ground_mat = _make_pbr(GROUND_DIFF, GROUND_NORMAL, GROUND_ROUGH, Color(0.43, 0.42, 0.40), 0.22, true)
    _stone_mat = _make_pbr(STONE_DIFF, STONE_NORMAL, STONE_ROUGH, Color(0.55, 0.53, 0.50), 0.32, true)
    _add_ridge(parent, Vector3(-18, 5, -43), Vector3(18, 12, 15), Color(0.15, 0.14, 0.16))
    _add_ridge(parent, Vector3(19, 6, -51), Vector3(22, 15, 18), Color(0.13, 0.13, 0.15))
    _add_ridge(parent, Vector3(0, 7, -78), Vector3(34, 17, 18), Color(0.12, 0.12, 0.14))
    _add_arch(parent, Vector3(-8.5, 0, -34), 0.82)
    _add_arch(parent, Vector3(8.4, 0, -48), 0.68)
    _add_tree(parent, Vector3(-8.2, 0, -28), 1.0)
    _add_tree(parent, Vector3(9.4, 0, -38), 0.82)
    _add_tree(parent, Vector3(-10.2, 0, -61), 1.2)
    _add_tree(parent, Vector3(10.5, 0, -62), 0.95)
    _add_rocks(parent, Vector3(-5, 0, -40), 5, 1.0)
    _add_rocks(parent, Vector3(5, 0, -25), 4, 0.8)
    _add_rocks(parent, Vector3(-9, 0, -54), 5, 1.1)
    _add_rocks(parent, Vector3(9, 0, -54), 5, 1.0)
    _add_banner(parent, Vector3(-5.6, 0, -19), 1.0)
    _add_banner(parent, Vector3(5.6, 0, -19), -1.0)
    _add_banner(parent, Vector3(-10.8, 0, -59), 1.0)
    _apply_surface_materials(parent)

static func ground_material() -> StandardMaterial3D:
    if _ground_mat == null:
        _ground_mat = _make_pbr(GROUND_DIFF, GROUND_NORMAL, GROUND_ROUGH, Color(0.43, 0.42, 0.40), 0.22, true)
    return _ground_mat

static func _make_pbr(diffuse_path: String, normal_path: String, rough_path: String, tint: Color, tiling: float, triplanar: bool) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.92
    material.metallic = 0.0
    material.uv1_scale = Vector3(tiling, tiling, tiling)
    if triplanar:
        material.uv1_triplanar = true
        material.uv1_world_triplanar = true
        material.uv1_triplanar_sharpness = 4.0
    if ResourceLoader.exists(diffuse_path):
        material.albedo_texture = load(diffuse_path)
    if ResourceLoader.exists(normal_path):
        material.normal_enabled = true
        material.normal_texture = load(normal_path)
    if ResourceLoader.exists(rough_path):
        material.roughness_texture = load(rough_path)
        material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    return material

static func _apply_surface_materials(parent: Node3D) -> void:
    for node in parent.get_children():
        if node is StaticBody3D:
            var n := String(node.name).to_lower()
            var is_ground := n.contains("road") or n.contains("courtyard") or n.contains("floor") or n.contains("arena")
            var is_stone := n.contains("wall") or n.contains("gate") or n.contains("masonry") or n.contains("pillar") or n.contains("marker")
            if is_ground or is_stone:
                for child in node.get_children():
                    if child is MeshInstance3D and child.mesh is BoxMesh:
                        child.material_override = _ground_mat if is_ground else _stone_mat

static func _add_ridge(parent: Node3D, pos: Vector3, size: Vector3, tint: Color) -> void:
    var ridge := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radial_segments = 9
    mesh.rings = 5
    ridge.mesh = mesh
    ridge.position = pos
    ridge.scale = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = 1.0
    ridge.material_override = mat
    parent.add_child(ridge)

static func _add_rocks(parent: Node3D, center: Vector3, count: int, size: float) -> void:
    var mat := _stone_mat
    for i in range(count):
        var rock := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radial_segments = 9
        mesh.rings = 5
        rock.mesh = mesh
        var angle := TAU * float(i) / float(count)
        rock.position = center + Vector3(cos(angle) * (0.65 + float(i % 2) * 0.45), 0.35 + float(i % 3) * 0.13, sin(angle) * (0.65 + float(i % 2) * 0.45))
        rock.scale = Vector3(size * (0.65 + float(i % 3) * 0.2), size * 0.48, size * 0.7)
        rock.rotation_degrees = Vector3(float(i * 17), float(i * 39), float(i * 11))
        rock.material_override = mat
        parent.add_child(rock)

static func _add_arch(parent: Node3D, base: Vector3, lean: float) -> void:
    var mat := _stone_mat
    for side in [-1.0, 1.0]:
        var pillar := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.32
        mesh.bottom_radius = 0.52
        mesh.height = 4.2
        mesh.radial_segments = 10
        pillar.mesh = mesh
        pillar.position = base + Vector3(side * 2.2, 2.1, 0)
        pillar.rotation_degrees.z = side * lean * 5.0
        pillar.material_override = mat
        parent.add_child(pillar)
    var beam := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(4.8, 0.62, 1.0)
    beam.mesh = box
    beam.position = base + Vector3(0, 4.25, 0)
    beam.rotation_degrees.z = lean * 3.0
    beam.material_override = mat
    parent.add_child(beam)

static func _add_tree(parent: Node3D, base: Vector3, scale_factor: float) -> void:
    var bark := StandardMaterial3D.new()
    bark.albedo_color = Color(0.12, 0.105, 0.10)
    bark.roughness = 1.0
    var trunk := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.12 * scale_factor
    mesh.bottom_radius = 0.38 * scale_factor
    mesh.height = 5.2 * scale_factor
    trunk.mesh = mesh
    trunk.position = base + Vector3(0, 2.6 * scale_factor, 0)
    trunk.rotation_degrees.z = -8.0
    trunk.material_override = bark
    parent.add_child(trunk)
    for i in range(4):
        var branch := MeshInstance3D.new()
        var branch_mesh := CylinderMesh.new()
        branch_mesh.top_radius = 0.045 * scale_factor
        branch_mesh.bottom_radius = 0.15 * scale_factor
        branch_mesh.height = 1.8 * scale_factor
        branch.mesh = branch_mesh
        var side := -1.0 if i % 2 == 0 else 1.0
        branch.position = base + Vector3(side * (0.5 + float(i) * 0.12) * scale_factor, (3.0 + float(i) * 0.42) * scale_factor, 0)
        branch.rotation_degrees.z = side * (38.0 + float(i % 2) * 16.0)
        branch.material_override = bark
        parent.add_child(branch)

static func _add_banner(parent: Node3D, base: Vector3, direction: float) -> void:
    var pole := MeshInstance3D.new()
    var pole_mesh := CylinderMesh.new()
    pole_mesh.top_radius = 0.045
    pole_mesh.bottom_radius = 0.075
    pole_mesh.height = 4.6
    pole.mesh = pole_mesh
    pole.position = base + Vector3(0, 2.3, 0)
    var iron := StandardMaterial3D.new()
    iron.albedo_color = Color(0.095, 0.105, 0.12)
    iron.metallic = 0.72
    pole.material_override = iron
    parent.add_child(pole)
    var cloth := MeshInstance3D.new()
    var cloth_mesh := BoxMesh.new()
    cloth_mesh.size = Vector3(1.25, 1.7, 0.07)
    cloth.mesh = cloth_mesh
    cloth.position = base + Vector3(direction * 0.62, 3.35, 0)
    var fabric := StandardMaterial3D.new()
    fabric.albedo_color = Color(0.22, 0.045, 0.035)
    fabric.roughness = 0.95
    cloth.material_override = fabric
    parent.add_child(cloth)
