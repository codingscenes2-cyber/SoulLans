extends "res://scripts/training_enemy.gd"

# A mobile ranged unit that retreats when crowded and fires a slow, readable
# ember projectile. It inherits poise, stagger, death rewards and quest credit.
const FIREBOLT_SCRIPT = preload("res://scripts/ashen_firebolt.gd")

@export var preferred_range := 8.5
@export var retreat_range := 4.0
@export var projectile_damage := 14.0
@export var projectile_speed := 11.0

var bow_visual: Node3D
var retreat_direction := Vector3.ZERO

func _ready() -> void:
    max_health = 92.0
    max_poise = 30.0
    attack_damage = projectile_damage
    soul_reward = 28
    detection_range = 14.0
    lose_target_range = 20.0
    attack_range = preferred_range
    chase_speed = 2.35
    patrol_speed = 0.85
    attack_windup_duration = 0.9
    attack_recovery_duration = 1.05
    stagger_duration = 0.5
    super._ready()
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.38, 0.19, 0.11)
    _create_bow_visual()
    _create_archer_kit()

func _should_begin_attack(distance: float) -> bool:
    return distance <= preferred_range and distance >= retreat_range and _is_primary_group_attacker()

func _configure_attack_pattern(_distance: float) -> void:
    current_attack_kind = "ember_bolt"
    current_attack_damage = projectile_damage
    current_attack_range = preferred_range
    attack_windup_duration = 0.9
    attack_recovery_duration = 1.05

func _get_chase_destination() -> Vector3:
    if not is_instance_valid(player):
        return global_position
    if _get_group_rank() > 0:
        return _get_group_flank_destination(maxf(4.5, preferred_range * 0.78))
    var away := global_position - player.global_position
    away.y = 0.0
    if away.length() < retreat_range:
        if away.length() <= 0.01:
            away = -global_transform.basis.z
            away.y = 0.0
        return global_position + away.normalized() * (retreat_range + 1.0)
    return player.global_position

# Parent attack timing calls this once at the end of the visible wind-up.
# Returning false prevents its melee damage path; the firebolt handles impact.
func can_hit_player() -> bool:
    if not is_instance_valid(player):
        return false
    var distance := global_position.distance_to(player.global_position)
    if distance > attack_range + 1.0:
        return false
    _launch_firebolt()
    return false

func _launch_firebolt() -> void:
    if not is_instance_valid(player):
        return
    var bolt: Variant = FIREBOLT_SCRIPT.new()
    bolt.name = "AshenEmberFirebolt"
    var scene_root := get_tree().current_scene
    if not is_instance_valid(scene_root):
        scene_root = get_tree().root
    scene_root.add_child(bolt)
    bolt.configure(global_position + Vector3.UP * 1.25, player.global_position + Vector3.UP * 0.9, self, projectile_damage)
    bolt.speed = projectile_speed
    bolt.add_to_group("enemy_projectiles")

func _create_bow_visual() -> void:
    bow_visual = Node3D.new()
    bow_visual.name = "AshenEmberBow"
    bow_visual.position = Vector3(0.48, 1.15, -0.35)
    add_child(bow_visual)
    var limb := MeshInstance3D.new()
    var shape := CapsuleMesh.new()
    shape.radius = 0.055
    shape.height = 1.05
    limb.mesh = shape
    limb.rotation.z = deg_to_rad(18.0)
    var wood := StandardMaterial3D.new()
    wood.albedo_color = Color(0.19, 0.105, 0.065)
    wood.roughness = 0.8
    limb.material_override = wood
    bow_visual.add_child(limb)
    var grip := MeshInstance3D.new()
    var grip_shape := CylinderMesh.new()
    grip_shape.top_radius = 0.045
    grip_shape.bottom_radius = 0.045
    grip_shape.height = 0.32
    grip.mesh = grip_shape
    grip.rotation.z = deg_to_rad(90.0)
    grip.material_override = wood
    bow_visual.add_child(grip)

func _update_enemy_animation() -> void:
    if not is_instance_valid(enemy_animation_player):
        return
    var candidates: Array[String] = []
    match state:
        State.WINDUP:
            candidates = ["Bow_Aim", "Bow_Idle", "Crossbow_Shoot", "Idle"]
        State.RECOVERY:
            candidates = ["Bow_Shoot", "Bow_Idle", "Zombie_Idle", "Idle"]
    for clip in candidates:
        if enemy_animation_player.has_animation(clip):
            if clip != current_enemy_animation:
                enemy_animation_player.play(clip, 0.12)
                current_enemy_animation = clip
            return
    super._update_enemy_animation()

func _create_archer_kit() -> void:
    # Cloth hood, mantle and a back quiver distinguish the ranged hunter at distance.
    _add_archer_piece("ArcherAshHood", SphereMesh.new(), Vector3(0.0, 1.78, 0.02), Vector3(0.42, 0.38, 0.4), Color(0.16, 0.105, 0.075), 0.0)
    _add_archer_piece("ArcherShoulderMantle", BoxMesh.new(), Vector3(0.0, 1.42, 0.12), Vector3(0.94, 0.34, 0.26), Color(0.25, 0.12, 0.075), 0.0)
    _add_archer_piece("ArcherBackQuiver", CylinderMesh.new(), Vector3(-0.43, 1.34, 0.24), Vector3(0.15, 0.43, 0.15), Color(0.11, 0.075, 0.05), 0.0)
    _add_archer_piece("ArcherBelt", BoxMesh.new(), Vector3(0.0, 0.91, 0.0), Vector3(0.62, 0.12, 0.3), Color(0.12, 0.075, 0.045), 0.0)

func _add_archer_piece(node_name: String, mesh: Mesh, piece_position: Vector3, piece_scale: Vector3, color: Color, metalness: float) -> MeshInstance3D:
    var piece := MeshInstance3D.new()
    piece.name = node_name
    if mesh is BoxMesh:
        (mesh as BoxMesh).size = piece_scale
        piece.scale = Vector3.ONE
    elif mesh is CylinderMesh:
        (mesh as CylinderMesh).top_radius = piece_scale.x
        (mesh as CylinderMesh).bottom_radius = piece_scale.x * 1.15
        (mesh as CylinderMesh).height = piece_scale.y * 2.0
    else:
        piece.scale = piece_scale
    piece.mesh = mesh
    piece.position = piece_position
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metalness
    material.roughness = 0.86
    piece.material_override = material
    add_child(piece)
    return piece
