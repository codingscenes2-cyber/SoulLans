extends StaticBody3D

func _ready() -> void:
    name = "AshenBlacksmith"
    add_to_group("interactables")
    add_to_group("blacksmiths")
    collision_layer = 1
    collision_mask = 1

    var body_collision := CollisionShape3D.new()
    var body_shape := CapsuleShape3D.new()
    body_shape.radius = 0.42
    body_shape.height = 1.8
    body_collision.shape = body_shape
    body_collision.position.y = 0.9
    add_child(body_collision)

    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.42
    body_mesh.height = 1.8
    body.mesh = body_mesh
    body.position.y = 0.9
    var apron := StandardMaterial3D.new()
    apron.albedo_color = Color(0.18, 0.2, 0.22)
    apron.roughness = 0.94
    body.material_override = apron
    add_child(body)

    var anvil := MeshInstance3D.new()
    var anvil_mesh := BoxMesh.new()
    anvil_mesh.size = Vector3(0.95, 0.42, 0.55)
    anvil.mesh = anvil_mesh
    anvil.position = Vector3(0.95, 0.82, -0.15)
    var iron := StandardMaterial3D.new()
    iron.albedo_color = Color(0.16, 0.19, 0.22)
    iron.metallic = 0.86
    iron.roughness = 0.28
    anvil.material_override = iron
    add_child(anvil)

    var forge := MeshInstance3D.new()
    var forge_mesh := CylinderMesh.new()
    forge_mesh.top_radius = 0.48
    forge_mesh.bottom_radius = 0.58
    forge_mesh.height = 0.82
    forge.mesh = forge_mesh
    forge.position = Vector3(-0.95, 0.42, -0.2)
    var stone := StandardMaterial3D.new()
    stone.albedo_color = Color(0.22, 0.19, 0.16)
    stone.roughness = 0.96
    forge.material_override = stone
    add_child(forge)

    var ember := MeshInstance3D.new()
    var ember_mesh := SphereMesh.new()
    ember_mesh.radius = 0.2
    ember_mesh.height = 0.4
    ember.mesh = ember_mesh
    ember.position = Vector3(-0.95, 0.95, -0.2)
    var fire := StandardMaterial3D.new()
    fire.albedo_color = Color(1.0, 0.31, 0.07)
    fire.emission_enabled = true
    fire.emission = Color(1.0, 0.12, 0.025)
    fire.emission_energy_multiplier = 2.2
    ember.material_override = fire
    add_child(ember)

    var nameplate := Label3D.new()
    nameplate.text = "ASHEN BLACKSMITH"
    nameplate.position = Vector3(0.0, 2.25, 0.0)
    nameplate.font_size = 34
    nameplate.pixel_size = 0.005
    nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    nameplate.modulate = Color(0.95, 0.72, 0.42)
    add_child(nameplate)

func interact() -> String:
    return "Blacksmith: Bring Ashen Scrap, Tempered Plates and a Regent Core. I can reinforce weapons and armour here. Open your inventory to equip gear or spend materials on reinforcement."
