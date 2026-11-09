extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")
const ENEMY_SCRIPT = preload("res://scripts/training_enemy.gd")
const HUD_SCRIPT = preload("res://scripts/mobile_hud.gd")

var player: CharacterBody3D
var enemy: CharacterBody3D
var enemy_respawn_timer := 0.0
var recovery_visual: MeshInstance3D

func _ready() -> void:
    _build_environment()
    _build_arena()
    _build_sanctuary()
    _build_recovery_marker()
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCRIPT)
    player.add_to_group("player")
    add_child(player)
    player.global_position = GameState.get_sanctuary_position()
    GameState.apply_to_player(player)
    player.connect("stats_changed", GameState.update_player_snapshot)
    player.connect("died", _on_player_died)
    _spawn_enemy()
    GameState.recovery_changed.connect(_update_recovery_marker)
    _update_recovery_marker(GameState.get_recovery_position(), GameState.get_dropped_essence(), GameState.has_recovery())

    var hud := CanvasLayer.new()
    hud.name = "MobileHUD"
    hud.set_script(HUD_SCRIPT)
    add_child(hud)
    hud.set("player", player)

func _process(delta: float) -> void:
    if not is_instance_valid(enemy):
        enemy_respawn_timer += delta
        if enemy_respawn_timer >= 4.0:
            _spawn_enemy()
    else:
        enemy_respawn_timer = 0.0

func _on_player_died() -> void:
    GameState.register_player_death(player.global_position)
    player.respawn_at(GameState.get_sanctuary_position())

func _spawn_enemy() -> void:
    enemy = CharacterBody3D.new()
    enemy.name = "TrainingHollow"
    enemy.set_script(ENEMY_SCRIPT)
    add_child(enemy)
    enemy.global_position = Vector3(0.0, 1.0, -4.0)
    player.set("target", enemy)
    enemy_respawn_timer = 0.0

func _build_sanctuary() -> void:
    var altar := MeshInstance3D.new()
    altar.name = "SanctuaryAltar"
    var base := CylinderMesh.new()
    base.top_radius = 0.8
    base.bottom_radius = 1.0
    base.height = 0.45
    altar.mesh = base
    altar.position = GameState.get_sanctuary_position() - Vector3.UP * 0.85
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.18, 0.2, 0.24)
    material.metallic = 0.65
    material.roughness = 0.3
    altar.material_override = material
    add_child(altar)

    var flame := MeshInstance3D.new()
    var orb := SphereMesh.new()
    orb.radius = 0.22
    orb.height = 0.44
    flame.mesh = orb
    flame.position = altar.position + Vector3.UP * 0.55
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(0.9, 0.58, 0.2)
    glow.emission_enabled = true
    glow.emission = Color(0.9, 0.32, 0.08)
    glow.emission_energy_multiplier = 2.0
    flame.material_override = glow
    add_child(flame)

func _build_recovery_marker() -> void:
    recovery_visual = MeshInstance3D.new()
    recovery_visual.name = "LostSoulEssence"
    var orb := SphereMesh.new()
    orb.radius = 0.32
    orb.height = 0.64
    recovery_visual.mesh = orb
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.35, 0.75, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.1, 0.5, 1.0)
    material.emission_energy_multiplier = 2.5
    recovery_visual.material_override = material
    add_child(recovery_visual)
    recovery_visual.visible = false

func _update_recovery_marker(position: Vector3, _essence: int, active: bool) -> void:
    if not is_instance_valid(recovery_visual):
        return
    recovery_visual.visible = active
    if active:
        recovery_visual.global_position = position + Vector3.UP * 0.5

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
