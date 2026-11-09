extends StaticBody3D

const QUEST_ID := "ashen_sigils"
const QUEST_TARGET := 3
const QUEST_REWARD := 120

func _ready() -> void:
    add_to_group("interactables")
    collision_layer = 1
    collision_mask = 1

    var collision := CollisionShape3D.new()
    var body_shape := CapsuleShape3D.new()
    body_shape.radius = 0.42
    body_shape.height = 1.8
    collision.shape = body_shape
    collision.position.y = 0.9
    add_child(collision)

    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    body.mesh = capsule
    body.position.y = 0.9
    var cloth := StandardMaterial3D.new()
    cloth.albedo_color = Color(0.22, 0.28, 0.31)
    cloth.roughness = 0.92
    body.material_override = cloth
    add_child(body)

    var mantle := MeshInstance3D.new()
    var mantle_mesh := BoxMesh.new()
    mantle_mesh.size = Vector3(0.92, 0.62, 0.5)
    mantle.mesh = mantle_mesh
    mantle.position = Vector3(0.0, 1.18, -0.04)
    var mantle_material := StandardMaterial3D.new()
    mantle_material.albedo_color = Color(0.38, 0.24, 0.16)
    mantle_material.roughness = 0.88
    mantle.material_override = mantle_material
    add_child(mantle)

    var nameplate := Label3D.new()
    nameplate.text = "WARDEN EIRA"
    nameplate.position = Vector3(0.0, 2.25, 0.0)
    nameplate.font_size = 36
    nameplate.pixel_size = 0.005
    nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    nameplate.modulate = Color(0.95, 0.82, 0.58)
    add_child(nameplate)

func interact() -> String:
    var quest := GameState.get_quest_state(QUEST_ID)
    var status := str(quest.get("status", "not_started"))
    if status == "not_started":
        if GameState.start_quest(QUEST_ID, QUEST_TARGET, QUEST_REWARD):
            return "Warden Eira: Three Ashen foes haunt this road. Defeat three and return to me. Your reward is 120 Soul Essence."
        return "Warden Eira: I cannot offer that task right now."
    if status == "active":
        var progress := int(quest.get("progress", 0))
        return "Warden Eira: The road is not safe yet. Ashen foes defeated: %d/%d." % [progress, QUEST_TARGET]
    var flags: Dictionary = GameState.data.get("world_flags", {})
    var already_unlocked := bool(flags.get("ashen_regent_unlocked", false))
    flags["ashen_regent_unlocked"] = true
    GameState.data["world_flags"] = flags
    GameState.save_game()
    if already_unlocked:
        return "Warden Eira: The Ashen Regent still waits beyond the sealed gate. End its reign."
    return "Warden Eira: You have earned the truth. The Ashen Regent waits beyond the sealed gate. Its defeat may free this road."
