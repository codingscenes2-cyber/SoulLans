extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")
const ENEMY_SCRIPT = preload("res://scripts/training_enemy.gd")
const SHIELD_GUARD_SCRIPT = preload("res://scripts/shield_guard.gd")
const ASHEN_ARCHER_SCRIPT = preload("res://scripts/ashen_archer.gd")
const ASHEN_VANGUARD_SCRIPT = preload("res://scripts/ashen_vanguard.gd")
const WARDEN_SCRIPT = preload("res://scripts/warden_eira.gd")
const BLACKSMITH_SCRIPT = preload("res://scripts/ashen_blacksmith.gd")
const REGENT_SCRIPT = preload("res://scripts/ashen_regent.gd")
const HUD_SCRIPT = preload("res://scripts/mobile_hud.gd")
const ASHEN_WORLD_ART = preload("res://scripts/ashen_world_art.gd")
const ENCOUNTER_DIRECTOR_SCRIPT = preload("res://scripts/encounter_director.gd")

var player: CharacterBody3D
var enemy: CharacterBody3D
var shield_guard: CharacterBody3D
var courtyard_enemy: CharacterBody3D
var archer_enemy: CharacterBody3D
var ashen_vanguard: CharacterBody3D
var archer_respawn_timer := 0.0
var courtyard_enemy_respawn_timer := 0.0
var enemy_respawn_timer := 0.0
var guard_respawn_timer := 0.0
var recovery_visual: MeshInstance3D
var warden: StaticBody3D
var blacksmith: StaticBody3D
var ashen_regent: CharacterBody3D
var throne_gate_door: StaticBody3D
var encounter_director: Node

func _ready() -> void:
    _build_environment()
    _build_arena()
    _build_ashen_approach()
    ASHEN_WORLD_ART.build(self)
    _build_sanctuary()
    _build_recovery_marker()
    _spawn_blacksmith()
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
    _spawn_shield_guard()
    _spawn_courtyard_enemy()
    _spawn_ashen_archer()
    _spawn_ashen_vanguard()
    _spawn_warden()
    _spawn_ashen_regent()
    if _has_defeated_ashen_regent():
        _open_throne_gate()
    GameState.recovery_changed.connect(_update_recovery_marker)
    GameState.sanctuary_restored.connect(_on_sanctuary_restored)
    _update_recovery_marker(GameState.get_recovery_position(), GameState.get_dropped_essence(), GameState.has_recovery())

    var hud := CanvasLayer.new()
    hud.name = "MobileHUD"
    hud.set_script(HUD_SCRIPT)
    add_child(hud)
    hud.set("player", player)
    player.set("hud", hud)
    encounter_director = Node.new()
    encounter_director.name = "EncounterDirector"
    encounter_director.set_script(ENCOUNTER_DIRECTOR_SCRIPT)
    add_child(encounter_director)
    encounter_director.configure(self, player, hud)

func _process(delta: float) -> void:
    if is_instance_valid(encounter_director):
        encounter_director.update_encounter(delta)
    if not is_instance_valid(enemy):
        enemy_respawn_timer += delta
        if enemy_respawn_timer >= 4.0:
            _spawn_enemy()
    else:
        enemy_respawn_timer = 0.0
    if not is_instance_valid(shield_guard):
        guard_respawn_timer += delta
        if guard_respawn_timer >= 4.0:
            _spawn_shield_guard()
    else:
        guard_respawn_timer = 0.0
    if not is_instance_valid(archer_enemy):
        archer_respawn_timer += delta
        if archer_respawn_timer >= 4.0:
            _spawn_ashen_archer()
    else:
        archer_respawn_timer = 0.0
    if not is_instance_valid(courtyard_enemy):
        courtyard_enemy_respawn_timer += delta
        if courtyard_enemy_respawn_timer >= 4.0:
            _spawn_courtyard_enemy()
    else:
        courtyard_enemy_respawn_timer = 0.0

func _on_sanctuary_restored(_position: Vector3) -> void:
    if is_instance_valid(encounter_director):
        encounter_director.reset_encounter()
    if is_instance_valid(enemy):
        enemy.queue_free()
    if is_instance_valid(shield_guard):
        shield_guard.queue_free()
    if is_instance_valid(courtyard_enemy):
        courtyard_enemy.queue_free()
    if is_instance_valid(archer_enemy):
        archer_enemy.queue_free()
    _spawn_enemy()
    _spawn_shield_guard()
    _spawn_courtyard_enemy()
    _spawn_ashen_archer()

func _on_player_died() -> void:
    GameState.register_player_death(player.global_position)
    player.respawn_at(GameState.get_sanctuary_position())

func _spawn_enemy() -> void:
    enemy = CharacterBody3D.new()
    enemy.name = "TrainingHollow"
    enemy.set_script(ENEMY_SCRIPT)
    enemy.position = Vector3(0.0, 1.0, -4.0)
    add_child(enemy)
    player.set("target", enemy)
    enemy_respawn_timer = 0.0

func _spawn_shield_guard() -> void:
    shield_guard = CharacterBody3D.new()
    shield_guard.name = "AshenWatchShieldGuard"
    shield_guard.set_script(SHIELD_GUARD_SCRIPT)
    shield_guard.position = Vector3(4.0, 1.0, -7.0)
    add_child(shield_guard)
    guard_respawn_timer = 0.0

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
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.075, 0.095, 0.14)
    sky_material.sky_horizon_color = Color(0.34, 0.29, 0.25)
    sky_material.ground_bottom_color = Color(0.055, 0.05, 0.055)
    sky_material.ground_horizon_color = Color(0.20, 0.17, 0.16)
    sky_material.sun_angle_max = 18.0
    sky_material.use_debanding = true
    sky.sky_material = sky_material
    env.background_mode = Environment.BG_SKY
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 0.72
    env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_exposure = 1.0
    env.fog_enabled = true
    env.fog_light_color = Color(0.30, 0.27, 0.25)
    env.fog_density = 0.006
    env.fog_sky_affect = 0.65
    world.environment = env
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.name = "AshenKingdomKeyLight"
    sun.rotation_degrees = Vector3(-42.0, -32.0, 0.0)
    sun.light_color = Color(1.0, 0.82, 0.68)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)
    var fill := DirectionalLight3D.new()
    fill.name = "CoolSkyFill"
    fill.rotation_degrees = Vector3(-18.0, 145.0, 0.0)
    fill.light_color = Color(0.42, 0.52, 0.72)
    fill.light_energy = 0.28
    fill.shadow_enabled = false
    add_child(fill)

func _build_arena() -> void:
    var floor_body := StaticBody3D.new()
    floor_body.name = "ArenaFloor"
    floor_body.position.y = -0.5
    add_child(floor_body)
    var floor_mesh := MeshInstance3D.new()
    var floor_box := BoxMesh.new()
    floor_box.size = Vector3(28.0, 1.0, 28.0)
    floor_mesh.mesh = floor_box
    floor_mesh.material_override = ASHEN_WORLD_ART.ground_material()
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


# A compact, connected first-region route: arena -> broken gate -> Ashen Road
# -> ruined outer courtyard -> sealed throne-road gate. All gameplay geometry
# is generated from primitives so the slice stays lightweight on Android.
func _build_ashen_approach() -> void:
    _add_box_structure("AshenRoad", Vector3(0.0, -0.5, -35.0), Vector3(12.0, 1.0, 42.0), Color(0.13, 0.12, 0.13), true)
    _add_box_structure("RoadWestRetainingWall", Vector3(-6.7, 1.0, -35.0), Vector3(0.7, 3.0, 42.0), Color(0.19, 0.18, 0.19), true)
    _add_box_structure("RoadEastRetainingWall", Vector3(6.7, 1.0, -35.0), Vector3(0.7, 3.0, 42.0), Color(0.19, 0.18, 0.19), true)

    # Broken gate frames the transition out of the training arena.
    _add_box_structure("BrokenGateWest", Vector3(-5.0, 2.0, -16.0), Vector3(1.2, 4.0, 1.2), Color(0.24, 0.21, 0.2), true)
    _add_box_structure("BrokenGateEast", Vector3(5.0, 2.0, -16.0), Vector3(1.2, 4.0, 1.2), Color(0.24, 0.21, 0.2), true)
    _add_box_structure("BrokenGateLintel", Vector3(0.0, 4.0, -16.0), Vector3(10.0, 0.8, 1.2), Color(0.22, 0.2, 0.2), true)

    # Roadside rubble gives cover and readable silhouettes without blocking the lane.
    _add_box_structure("WestCollapsedMasonry", Vector3(-4.2, 0.55, -27.0), Vector3(2.4, 1.1, 2.0), Color(0.22, 0.2, 0.19), true)
    _add_box_structure("EastBrokenPillarBase", Vector3(4.1, 0.7, -39.0), Vector3(1.7, 1.4, 1.7), Color(0.25, 0.22, 0.2), true)
    _add_box_structure("RoadsideStoneMarker", Vector3(-4.6, 1.0, -47.0), Vector3(0.9, 2.0, 0.9), Color(0.28, 0.25, 0.22), true)

    # Outer courtyard joins the road and creates room for a future authored encounter.
    _add_box_structure("OuterCourtyard", Vector3(0.0, -0.5, -57.0), Vector3(24.0, 1.0, 18.0), Color(0.15, 0.14, 0.15), true)
    _add_box_structure("CourtyardWestWall", Vector3(-12.2, 1.1, -57.0), Vector3(0.8, 3.2, 18.0), Color(0.2, 0.18, 0.18), true)
    _add_box_structure("CourtyardEastWall", Vector3(12.2, 1.1, -57.0), Vector3(0.8, 3.2, 18.0), Color(0.2, 0.18, 0.18), true)
    _add_box_structure("CourtyardNorthWallWest", Vector3(-7.7, 1.1, -66.2), Vector3(8.6, 3.2, 0.8), Color(0.2, 0.18, 0.18), true)
    _add_box_structure("CourtyardNorthWallEast", Vector3(7.7, 1.1, -66.2), Vector3(8.6, 3.2, 0.8), Color(0.2, 0.18, 0.18), true)

    # A sealed monumental gate is a visible destination, not a fake open exit.
    _add_box_structure("ThroneRoadGateLeft", Vector3(-3.6, 3.0, -65.4), Vector3(1.0, 6.0, 1.0), Color(0.28, 0.22, 0.19), true)
    _add_box_structure("ThroneRoadGateRight", Vector3(3.6, 3.0, -65.4), Vector3(1.0, 6.0, 1.0), Color(0.28, 0.22, 0.19), true)
    _add_box_structure("ThroneRoadGateHeader", Vector3(0.0, 5.8, -65.4), Vector3(8.2, 1.2, 1.0), Color(0.28, 0.22, 0.19), true)
    _add_box_structure("ThroneRoadSealedDoor", Vector3(0.0, 2.7, -65.4), Vector3(6.0, 5.2, 0.65), Color(0.12, 0.1, 0.12), true)
    throne_gate_door = get_node_or_null("ThroneRoadSealedDoor") as StaticBody3D

    # The road beyond the gate is built now; the boss defeat removes the sealed door.
    _add_box_structure("ThroneRoadBeyondGate", Vector3(0.0, -0.5, -77.0), Vector3(8.5, 1.0, 22.0), Color(0.13, 0.12, 0.13), true)
    _add_box_structure("ThroneRoadBeyondWestWall", Vector3(-4.8, 1.1, -77.0), Vector3(0.6, 3.2, 22.0), Color(0.19, 0.18, 0.19), true)
    _add_box_structure("ThroneRoadBeyondEastWall", Vector3(4.8, 1.1, -77.0), Vector3(0.6, 3.2, 22.0), Color(0.19, 0.18, 0.19), true)

    _add_ashen_lantern(Vector3(-4.8, 0.0, -22.0))
    _add_ashen_lantern(Vector3(4.8, 0.0, -43.0))
    _add_ashen_lantern(Vector3(-8.8, 0.0, -59.0))
    _add_ashen_lantern(Vector3(8.8, 0.0, -59.0))

func _add_box_structure(node_name: String, center: Vector3, dimensions: Vector3, tint: Color, solid: bool) -> void:
    var root: Node3D
    if solid:
        var body := StaticBody3D.new()
        body.name = node_name
        body.position = center
        add_child(body)
        root = body
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collision.shape = shape
        body.add_child(collision)
    else:
        var visual_root := Node3D.new()
        visual_root.name = node_name
        visual_root.position = center
        add_child(visual_root)
        root = visual_root
    var mesh_instance := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh_instance.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.95
    mesh_instance.material_override = material
    root.add_child(mesh_instance)

func _add_ashen_lantern(position: Vector3) -> void:
    var post := MeshInstance3D.new()
    post.name = "AshenRoadLanternPost"
    var post_mesh := CylinderMesh.new()
    post_mesh.top_radius = 0.12
    post_mesh.bottom_radius = 0.18
    post_mesh.height = 2.2
    post.mesh = post_mesh
    post.position = position + Vector3.UP * 1.1
    var iron := StandardMaterial3D.new()
    iron.albedo_color = Color(0.12, 0.13, 0.15)
    iron.metallic = 0.65
    post.material_override = iron
    add_child(post)

    var flame := MeshInstance3D.new()
    var orb := SphereMesh.new()
    orb.radius = 0.2
    orb.height = 0.4
    flame.mesh = orb
    flame.position = position + Vector3.UP * 2.35
    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(0.95, 0.42, 0.12)
    glow.emission_enabled = true
    glow.emission = Color(0.9, 0.22, 0.04)
    glow.emission_energy_multiplier = 1.6
    flame.material_override = glow
    add_child(flame)

func _spawn_warden() -> void:
    warden = StaticBody3D.new()
    warden.name = "WardenEira"
    warden.set_script(WARDEN_SCRIPT)
    warden.position = Vector3(-7.0, 0.0, -59.0)
    add_child(warden)

func _spawn_ashen_regent() -> void:
    var defeated: Array = GameState.data.get("defeated_bosses", [])
    if defeated.has("ashen_regent"):
        return
    ashen_regent = CharacterBody3D.new()
    ashen_regent.name = "AshenRegent"
    ashen_regent.set_script(REGENT_SCRIPT)
    ashen_regent.position = Vector3(0.0, 1.0, -61.0)
    add_child(ashen_regent)
    ashen_regent.connect("boss_defeated", _open_throne_gate)

func _has_defeated_ashen_regent() -> bool:
    var defeated: Array = GameState.data.get("defeated_bosses", [])
    return defeated.has("ashen_regent")

func _open_throne_gate() -> void:
    if is_instance_valid(throne_gate_door):
        throne_gate_door.queue_free()
    var flags: Dictionary = GameState.data.get("world_flags", {})
    flags["ashen_gate_open"] = true
    GameState.data["world_flags"] = flags
    GameState.save_game()

func _spawn_courtyard_enemy() -> void:
    courtyard_enemy = CharacterBody3D.new()
    courtyard_enemy.name = "AshenRoadHollow"
    courtyard_enemy.set_script(ENEMY_SCRIPT)
    courtyard_enemy.position = Vector3(0.0, 1.0, -53.0)
    add_child(courtyard_enemy)
    courtyard_enemy_respawn_timer = 0.0

func _spawn_ashen_vanguard() -> void:
    if bool(GameState.data.get("world_flags", {}).get("ashen_vanguard_defeated", false)):
        return
    ashen_vanguard = CharacterBody3D.new()
    ashen_vanguard.name = "AshenVanguard"
    ashen_vanguard.set_script(ASHEN_VANGUARD_SCRIPT)
    ashen_vanguard.position = Vector3(-4.0, 1.0, -47.0)
    add_child(ashen_vanguard)

func _spawn_ashen_archer() -> void:
    archer_enemy = CharacterBody3D.new()
    archer_enemy.name = "AshenEmberArcher"
    archer_enemy.set_script(ASHEN_ARCHER_SCRIPT)
    archer_enemy.position = Vector3(7.0, 1.0, -60.0)
    add_child(archer_enemy)
    archer_respawn_timer = 0.0

func _spawn_blacksmith() -> void:
    blacksmith = StaticBody3D.new()
    blacksmith.set_script(BLACKSMITH_SCRIPT)
    blacksmith.position = Vector3(4.2, 0.0, 6.0)
    add_child(blacksmith)
