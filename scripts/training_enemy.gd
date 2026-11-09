extends CharacterBody3D

# Ashen Hollow: a readable melee enemy prototype. NavigationAgent3D is used
# when a NavigationRegion3D is present; direct steering remains the fallback.
enum State { IDLE, PATROL, INVESTIGATE, CHASE, WINDUP, RECOVERY, STAGGER, DEAD }

@export var max_health := 120.0
@export var max_poise := 36.0
@export var attack_damage := 10.0
@export var soul_reward := 20
@export var detection_range := 10.0
@export var lose_target_range := 15.0
@export var attack_range := 2.0
@export var chase_speed := 2.1
@export var patrol_speed := 1.0
@export var attack_windup_duration := 0.52
@export var attack_recovery_duration := 0.68
@export var stagger_duration := 0.42
@export var patrol_radius := 4.0

var health := 120.0
var poise := 36.0
var state := State.IDLE
var player: Node3D
var state_timer := 0.0
var death_timer := 0.0
var idle_timer := 0.0
var patrol_origin := Vector3.ZERO
var patrol_target := Vector3.ZERO
var last_known_player_position := Vector3.ZERO
var enemy_visual: Node3D
var enemy_material: StandardMaterial3D
var enemy_animation_player: AnimationPlayer
var enemy_weapon_attachment: BoneAttachment3D
var current_enemy_animation := ""
var navigation_agent: NavigationAgent3D

func _ready() -> void:
    add_to_group("enemies")
    health = max_health
    poise = max_poise
    patrol_origin = global_position
    patrol_target = patrol_origin
    player = get_tree().get_first_node_in_group("player")
    _create_placeholder_enemy()
    navigation_agent = NavigationAgent3D.new()
    navigation_agent.name = "NavigationAgent3D"
    navigation_agent.path_desired_distance = 0.5
    navigation_agent.target_desired_distance = 0.8
    navigation_agent.radius = 0.45
    add_child(navigation_agent)

func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        death_timer = maxf(0.0, death_timer - delta)
        if death_timer <= 0.0:
            queue_free()
        return
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
    state_timer = maxf(0.0, state_timer - delta)
    idle_timer = maxf(0.0, idle_timer - delta)

    var distance := INF
    if is_instance_valid(player):
        distance = global_position.distance_to(player.global_position)
        if distance <= detection_range:
            last_known_player_position = player.global_position

    _face_toward(last_known_player_position if state in [State.INVESTIGATE, State.CHASE, State.WINDUP, State.RECOVERY] else patrol_target, delta)

    match state:
        State.IDLE:
            _stop_horizontal_motion(delta)
            if distance <= detection_range:
                state = State.CHASE
            elif idle_timer <= 0.0:
                _choose_patrol_target()
                state = State.PATROL
        State.PATROL:
            if distance <= detection_range:
                state = State.CHASE
            elif _move_toward_point(patrol_target, patrol_speed, delta):
                state = State.IDLE
                idle_timer = randf_range(0.7, 1.8)
        State.INVESTIGATE:
            if distance <= detection_range:
                state = State.CHASE
            elif _move_toward_point(last_known_player_position, patrol_speed * 1.25, delta):
                state = State.IDLE
                idle_timer = 1.0
        State.CHASE:
            if distance > lose_target_range:
                state = State.INVESTIGATE
                _set_navigation_target(last_known_player_position)
            elif distance <= attack_range:
                state = State.WINDUP
                state_timer = attack_windup_duration
                _stop_horizontal_motion(delta)
                _set_telegraph(true)
            else:
                _move_toward_point(player.global_position, chase_speed, delta)
        State.WINDUP:
            _stop_horizontal_motion(delta)
            if state_timer <= 0.0:
                if is_instance_valid(player) and global_position.distance_to(player.global_position) <= attack_range + 0.5 and player.has_method("take_damage"):
                    player.take_damage(attack_damage)
                _set_telegraph(false)
                state = State.RECOVERY
                state_timer = attack_recovery_duration
        State.RECOVERY:
            _stop_horizontal_motion(delta)
            if state_timer <= 0.0:
                state = State.CHASE if is_instance_valid(player) and distance <= lose_target_range else State.INVESTIGATE
        State.STAGGER:
            _stop_horizontal_motion(delta)
            if state_timer <= 0.0:
                poise = max_poise
                state = State.CHASE if is_instance_valid(player) and distance <= lose_target_range else State.IDLE

    if not is_on_floor():
        velocity.y -= 24.0 * delta
    else:
        velocity.y = -0.5
    move_and_slide()
    _update_enemy_animation()

func _move_toward_point(point: Vector3, speed: float, delta: float) -> bool:
    var destination := point
    if is_instance_valid(navigation_agent) and navigation_agent.is_inside_tree():
        if navigation_agent.target_position.distance_to(point) > 0.75:
            navigation_agent.target_position = point
        if not navigation_agent.is_navigation_finished():
            var next_position := navigation_agent.get_next_path_position()
            # An unbaked navigation map can return the agent's own position;
            # direct steering prevents the enemy becoming permanently stuck.
            if next_position.distance_to(global_position) > 0.15:
                destination = next_position
    var direction := destination - global_position
    direction.y = 0.0
    if direction.length() <= 0.7:
        _stop_horizontal_motion(delta)
        return true
    direction = direction.normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    return false

func _set_navigation_target(point: Vector3) -> void:
    if is_instance_valid(navigation_agent):
        navigation_agent.target_position = point

func _choose_patrol_target() -> void:
    var angle := randf_range(0.0, TAU)
    var radius := randf_range(1.0, patrol_radius)
    patrol_target = patrol_origin + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
    _set_navigation_target(patrol_target)

func receive_parry() -> void:
    if state == State.DEAD:
        return
    state = State.STAGGER
    state_timer = stagger_duration * 1.8
    poise = max_poise
    velocity = Vector3.ZERO
    _set_telegraph(false)
    _flash_hit()

func take_damage(amount: float, poise_damage: float = 12.0) -> void:
    if state == State.DEAD or amount <= 0.0:
        return
    health = maxf(0.0, health - amount)
    poise = maxf(0.0, poise - poise_damage)
    if health <= 0.0:
        state = State.DEAD
        velocity = Vector3.ZERO
        death_timer = 1.65
        GameState.award_soul_essence(soul_reward)
        _update_enemy_animation()
        return
    if poise <= 0.0:
        state = State.STAGGER
        state_timer = stagger_duration
        _set_telegraph(false)
        _flash_hit()

func _face_toward(point: Vector3, delta: float) -> void:
    var direction := point - global_position
    direction.y = 0.0
    if direction.length() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 8.0 * delta)

func _stop_horizontal_motion(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
    velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)

func _set_telegraph(active: bool) -> void:
    if not is_instance_valid(enemy_visual):
        return
    enemy_visual.scale = Vector3(1.12, 0.94, 1.12) if active else Vector3.ONE
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.9, 0.22, 0.08) if active else Color(0.42, 0.13, 0.11)

func _flash_hit() -> void:
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.95, 0.75, 0.35)

func _create_placeholder_enemy() -> void:
    enemy_material = StandardMaterial3D.new()
    enemy_material.albedo_color = Color(0.34, 0.16, 0.14)
    enemy_material.metallic = 0.16
    enemy_material.roughness = 0.78

    var model_path := "res://assets/characters/ashen_hero_animated.glb"
    if ResourceLoader.exists(model_path):
        var packed := load(model_path) as PackedScene
        if packed != null:
            enemy_visual = packed.instantiate() as Node3D
            if enemy_visual != null:
                enemy_visual.name = "AshenHollowRig"
                enemy_visual.scale = Vector3.ONE
                _apply_enemy_material(enemy_visual)
                add_child(enemy_visual)
                enemy_animation_player = _find_enemy_animation_player(enemy_visual)
                _attach_enemy_weapon(enemy_visual)
                if is_instance_valid(enemy_animation_player) and enemy_animation_player.has_animation("Zombie_Idle"):
                    enemy_animation_player.play("Zombie_Idle")
                    current_enemy_animation = "Zombie_Idle"

    if not is_instance_valid(enemy_visual):
        var fallback := MeshInstance3D.new()
        var capsule := CapsuleMesh.new()
        capsule.radius = 0.45
        capsule.height = 1.9
        fallback.mesh = capsule
        fallback.position.y = 0.95
        fallback.material_override = enemy_material
        add_child(fallback)
        enemy_visual = fallback

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.9
    collision.shape = shape
    collision.position.y = 0.95
    add_child(collision)

func _apply_enemy_material(node: Node) -> void:
    for child in node.get_children():
        if child is MeshInstance3D and child.mesh != null:
            child.material_override = enemy_material
        _apply_enemy_material(child)

func _attach_enemy_weapon(model: Node) -> void:
    var skeleton := _find_enemy_skeleton(model)
    if skeleton == null or skeleton.find_bone("hand_r") < 0:
        return
    enemy_weapon_attachment = BoneAttachment3D.new()
    enemy_weapon_attachment.name = "HollowRustBladeAttachment"
    enemy_weapon_attachment.bone_name = "hand_r"
    skeleton.add_child(enemy_weapon_attachment)
    var weapon := Node3D.new()
    weapon.name = "RustBlade"
    enemy_weapon_attachment.add_child(weapon)

    var blade := MeshInstance3D.new()
    var blade_mesh := BoxMesh.new()
    blade_mesh.size = Vector3(0.09, 0.78, 0.04)
    blade.mesh = blade_mesh
    blade.position.z = -0.48
    var blade_material := StandardMaterial3D.new()
    blade_material.albedo_color = Color(0.28, 0.22, 0.2)
    blade_material.metallic = 0.72
    blade_material.roughness = 0.58
    blade.material_override = blade_material
    weapon.add_child(blade)

    var guard := MeshInstance3D.new()
    var guard_mesh := BoxMesh.new()
    guard_mesh.size = Vector3(0.34, 0.06, 0.08)
    guard.mesh = guard_mesh
    guard.position.z = -0.04
    guard.material_override = blade_material
    weapon.add_child(guard)

func _find_enemy_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node
    for child in node.get_children():
        var found := _find_enemy_skeleton(child)
        if found != null:
            return found
    return null

func _find_enemy_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node
    for child in node.get_children():
        var found := _find_enemy_animation_player(child)
        if found != null:
            return found
    return null

func _update_enemy_animation() -> void:
    if not is_instance_valid(enemy_animation_player):
        return
    var candidates: Array[String] = ["Zombie_Idle", "Idle"]
    match state:
        State.PATROL, State.INVESTIGATE:
            candidates = ["Zombie_Walk_Fwd", "Walk", "Jog_Fwd"]
        State.CHASE:
            candidates = ["Jog_Fwd", "Sprint"]
        State.WINDUP:
            candidates = ["Sword_Regular_A", "Sword_Attack", "Punch_Cross", "Punch_Jab"]
        State.RECOVERY:
            candidates = ["Zombie_Idle", "Sword_Idle", "Idle"]
        State.STAGGER:
            candidates = ["Hit_Chest", "Hit_Head", "Hit_Knockback"]
        State.DEAD:
            candidates = ["Death01"]
    for clip in candidates:
        if enemy_animation_player.has_animation(clip):
            if clip != current_enemy_animation:
                enemy_animation_player.play(clip, 0.16)
                current_enemy_animation = clip
            return
