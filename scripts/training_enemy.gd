extends CharacterBody3D

enum State { IDLE, CHASE, WINDUP, RECOVERY, DEAD }

@export var max_health := 120.0
@export var attack_damage := 10.0
@export var detection_range := 9.0
@export var attack_range := 2.0
@export var chase_speed := 2.1
@export var attack_windup_duration := 0.48
@export var attack_recovery_duration := 0.62

var health := 120.0
var state := State.IDLE
var player: Node3D
var attack_cooldown := 0.0
var state_timer := 0.0
var enemy_visual: MeshInstance3D
var enemy_material: StandardMaterial3D

func _ready() -> void:
    health = max_health
    player = get_tree().get_first_node_in_group("player")
    _create_placeholder_enemy()

func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        return
    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
        return

    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    state_timer = maxf(0.0, state_timer - delta)
    var distance := global_position.distance_to(player.global_position)
    _face_player(delta)

    match state:
        State.IDLE:
            _stop_horizontal_motion(delta)
            if distance <= detection_range:
                state = State.CHASE
        State.CHASE:
            if distance > detection_range * 1.35:
                state = State.IDLE
                _stop_horizontal_motion(delta)
            elif distance <= attack_range and attack_cooldown <= 0.0:
                state = State.WINDUP
                state_timer = attack_windup_duration
                attack_cooldown = 1.65
                _stop_horizontal_motion(delta)
                _set_telegraph(true)
            else:
                var direction := player.global_position - global_position
                direction.y = 0.0
                direction = direction.normalized()
                velocity.x = direction.x * chase_speed
                velocity.z = direction.z * chase_speed
        State.WINDUP:
            _stop_horizontal_motion(delta)
            if state_timer <= 0.0:
                if distance <= attack_range + 0.45 and player.has_method("take_damage"):
                    player.take_damage(attack_damage)
                _set_telegraph(false)
                state = State.RECOVERY
                state_timer = attack_recovery_duration
        State.RECOVERY:
            _stop_horizontal_motion(delta)
            if state_timer <= 0.0:
                state = State.CHASE if distance <= detection_range else State.IDLE

    if not is_on_floor():
        velocity.y -= 24.0 * delta
    else:
        velocity.y = -0.5
    move_and_slide()

func take_damage(amount: float) -> void:
    if state == State.DEAD:
        return
    health = maxf(0.0, health - amount)
    if health <= 0.0:
        state = State.DEAD
        queue_free()

func _face_player(delta: float) -> void:
    if not is_instance_valid(player):
        return
    var direction := player.global_position - global_position
    direction.y = 0.0
    if direction.length() > 0.05:
        var desired_yaw := atan2(-direction.x, -direction.z)
        rotation.y = lerp_angle(rotation.y, desired_yaw, 8.0 * delta)

func _stop_horizontal_motion(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
    velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)

func _set_telegraph(active: bool) -> void:
    if not is_instance_valid(enemy_visual):
        return
    enemy_visual.scale = Vector3(1.12, 0.94, 1.12) if active else Vector3.ONE
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.8, 0.24, 0.12) if active else Color(0.42, 0.13, 0.11)

func _create_placeholder_enemy() -> void:
    enemy_visual = MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.45
    capsule.height = 1.9
    enemy_visual.mesh = capsule
    enemy_visual.position.y = 0.95
    enemy_material = StandardMaterial3D.new()
    enemy_material.albedo_color = Color(0.42, 0.13, 0.11)
    enemy_visual.material_override = enemy_material
    add_child(enemy_visual)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.9
    collision.shape = shape
    collision.position.y = 0.95
    add_child(collision)
