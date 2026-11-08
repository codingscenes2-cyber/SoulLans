extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")
const ENEMY_SCRIPT = preload("res://scripts/training_enemy.gd")
const HUD_SCRIPT = preload("res://scripts/mobile_hud.gd")

func _ready() -> void:
    _build_environment()
    _build_arena()
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCRIPT)
    player.add_to_group("player")
    add_child(player)
    player.global_position = Vector3(0.0, 1.05, 4.0)

    var enemy := CharacterBody3D.new()
    enemy.name = "TrainingHollow"
    enemy.set_script(ENEMY_SCRIPT)
    add_child(enemy)
    enemy.global_position = Vector3(0.0, 1.0, -4.0)
    player.set("target", enemy)

    var hud := CanvasLayer.new()
    hud.name = "MobileHUD"
    hud.set_script(HUD_SCRIPT)
    add_child(hud)
    hud.set("player", player)

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.025, 0.025, 0.04)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.42, 0.43, 0.5)
    env.ambient_light_energy = 0.7
    world.environment = env
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
    sun.light_energy = 1.0
    add_child(sun)

func _build_arena() -> void:
    var floor_body := StaticBody3D.new()
    floor_body.name = "ArenaFloor"
    floor_body.position.y = -0.5
    add_child(floor_body)
    var floor_mesh := MeshInstance3D.new()
    var floor_box := BoxMesh.new()
    floor_box.size = Vector3(28.0, 1.0, 28.0)
    floor_mesh.mesh = floor_box
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.17, 0.16, 0.16)
    floor_mat.roughness = 1.0
    floor_mesh.material_override = floor_mat
    floor_body.add_child(floor_mesh)
    var floor_collision := CollisionShape3D.new()
    var floor_shape := BoxShape3D.new()
    floor_shape.size = floor_box.size
    floor_collision.shape = floor_shape
    floor_body.add_child(floor_collision)

    for index in range(8):
        var pillar := MeshInstance3D.new()
        var pillar_mesh := CylinderMesh.new()
        pillar_mesh.top_radius = 0.4
        pillar_mesh.bottom_radius = 0.65
        pillar_mesh.height = 3.5
        pillar.mesh = pillar_mesh
        var stone := StandardMaterial3D.new()
        stone.albedo_color = Color(0.23, 0.22, 0.23)
        pillar.material_override = stone
        add_child(pillar)
        var angle := TAU * float(index) / 8.0
        pillar.position = Vector3(cos(angle) * 10.0, 1.25, sin(angle) * 10.0)
