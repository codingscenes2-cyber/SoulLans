extends CharacterBody3D

signal stats_changed(health: float, stamina: float)
signal died

@export var move_speed := 5.0
@export var sprint_speed := 7.2
@export var dodge_speed := 10.0
@export var max_health := 100.0
@export var max_stamina := 100.0
@export var attack_damage := 25.0
@export var look_sensitivity := 0.006
@export var min_camera_pitch := -0.75
@export var max_camera_pitch := 0.35

var health := 100.0
var stamina := 100.0
var target: Node3D
var camera: Camera3D
var camera_pivot: Node3D
var dodge_timer := 0.0
var attack_cooldown := 0.0
var attack_windup := 0.0
var attack_active_timer := 0.0
var attack_has_hit := false
var dodge_direction := Vector3.FORWARD
var locked_on := false
var camera_yaw := 0.0
var camera_pitch := -0.12
var invulnerability_timer := 0.0

func _ready() -> void:
    add_to_group("player")
    health = max_health
    stamina = max_stamina
    _setup_input_map()
    _create_placeholder_body()
    _create_camera_rig()

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if attack_windup > 0.0:
        attack_windup -= delta
        if attack_windup <= 0.0:
            attack_active_timer = 0.11
            attack_has_hit = false
    if attack_active_timer > 0.0:
        attack_active_timer = maxf(0.0, attack_active_timer - delta)
        if not attack_has_hit:
            _resolve_melee_hit()
            attack_has_hit = true
    dodge_timer = maxf(0.0, dodge_timer - delta)
    invulnerability_timer = maxf(0.0, invulnerability_timer - delta)
    stamina = minf(max_stamina, stamina + 17.0 * delta)

    if Input.is_action_just_pressed("dodge"):
        perform_dodge()
    if Input.is_action_just_pressed("attack"):
        perform_attack()
    if Input.is_action_just_pressed("interact"):
        _interact_with_world()
    if Input.is_action_just_pressed("lock_on"):
        locked_on = is_instance_valid(target) and not locked_on

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var camera_forward := -camera.global_transform.basis.z
    var camera_right := camera.global_transform.basis.x
    camera_forward.y = 0.0
    camera_right.y = 0.0
    var direction := (camera_right.normalized() * input_vector.x - camera_forward.normalized() * input_vector.y).normalized()

    if dodge_timer > 0.0:
        velocity.x = dodge_direction.x * dodge_speed
        velocity.z = dodge_direction.z * dodge_speed
    else:
        var sprinting := Input.is_action_pressed("sprint") and stamina > 1.0 and direction.length() > 0.1
        var speed := sprint_speed if sprinting else move_speed
        if sprinting:
            stamina = maxf(0.0, stamina - 12.0 * delta)
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        if direction.length() > 0.1 and not locked_on:
            rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 12.0 * delta)

    if locked_on and is_instance_valid(target):
        var look_direction := target.global_position - global_position
        look_direction.y = 0.0
        if look_direction.length() > 0.1:
            rotation.y = lerp_angle(rotation.y, atan2(-look_direction.x, -look_direction.z), 10.0 * delta)
            camera_yaw = atan2(-look_direction.x, -look_direction.z) - rotation.y

    if not is_on_floor():
        velocity.y -= 24.0 * delta
    else:
        velocity.y = -0.5
    move_and_slide()
    _update_camera()
    stats_changed.emit(health, stamina)

func add_camera_look(relative_motion: Vector2) -> void:
    if locked_on:
        return
    camera_yaw -= relative_motion.x * look_sensitivity
    camera_pitch = clampf(camera_pitch - relative_motion.y * look_sensitivity, min_camera_pitch, max_camera_pitch)
    _update_camera()

func perform_dodge() -> void:
    if stamina < 25.0 or dodge_timer > 0.0:
        return
    stamina -= 25.0
    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if input_vector.length() < 0.1:
        dodge_direction = -global_transform.basis.z
    else:
        var basis := camera.global_transform.basis
        var forward := -basis.z
        var right := basis.x
        forward.y = 0.0
        right.y = 0.0
        dodge_direction = (right.normalized() * input_vector.x - forward.normalized() * input_vector.y).normalized()
    dodge_timer = 0.36
    invulnerability_timer = 0.22

func perform_attack() -> void:
    if attack_cooldown > 0.0 or stamina < 12.0 or dodge_timer > 0.0:
        return
    stamina -= 12.0
    attack_cooldown = 0.65
    attack_windup = 0.13

func _resolve_melee_hit() -> void:
    var hit_shape := SphereShape3D.new()
    hit_shape.radius = 0.95
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = hit_shape
    query.transform = Transform3D(
        Basis.IDENTITY,
        global_position - global_transform.basis.z * 1.25 + Vector3.UP * 1.0
    )
    query.collision_mask = 1
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]
    var hits := get_world_3d().direct_space_state.intersect_shape(query, 8)
    for hit in hits:
        var collider: Object = hit.get("collider")
        if is_instance_valid(collider) and collider.has_method("take_damage"):
            collider.take_damage(attack_damage)

func take_damage(amount: float) -> void:
    if invulnerability_timer > 0.0 or health <= 0.0:
        return
    health = maxf(0.0, health - amount)
    if health <= 0.0:
        died.emit()

func restore_at_sanctuary() -> void:
    health = max_health
    stamina = max_stamina
    velocity = Vector3.ZERO
    stats_changed.emit(health, stamina)

func respawn_at(position: Vector3) -> void:
    global_position = position
    restore_at_sanctuary()
    invulnerability_timer = 1.5

func _interact_with_world() -> void:
    if global_position.distance_to(GameState.get_sanctuary_position()) <= 3.0:
        GameState.rest_at_sanctuary(GameState.get_sanctuary_position(), self)
    else:
        GameState.try_recover_souls(global_position)

func apply_saved_state(saved: Dictionary) -> void:
    health = clampf(float(saved.get("health", max_health)), 0.0, max_health)
    stamina = clampf(float(saved.get("stamina", max_stamina)), 0.0, max_stamina)
    stats_changed.emit(health, stamina)

func get_status() -> Dictionary:
    return {"health": health, "max_health": max_health, "stamina": stamina, "max_stamina": max_stamina}

func _create_placeholder_body() -> void:
    var visual := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    visual.mesh = capsule
    visual.position.y = 0.9
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.28, 0.32, 0.38)
    material.metallic = 0.2
    visual.material_override = material
    add_child(visual)
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func _create_camera_rig() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.name = "CameraPivot"
    camera_pivot.position.y = 1.45
    add_child(camera_pivot)
    var spring := SpringArm3D.new()
    spring.spring_length = 5.0
    spring.margin = 0.2
    camera_pivot.add_child(spring)
    camera = Camera3D.new()
    camera.current = true
    spring.add_child(camera)
    _update_camera()

func _update_camera() -> void:
    if not is_instance_valid(camera_pivot):
        return
    camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _setup_input_map() -> void:
    _ensure_key_action("move_forward", KEY_W)
    _ensure_key_action("move_back", KEY_S)
    _ensure_key_action("move_left", KEY_A)
    _ensure_key_action("move_right", KEY_D)
    _ensure_key_action("sprint", KEY_SHIFT)
    _ensure_key_action("dodge", KEY_SPACE)
    _ensure_key_action("lock_on", KEY_TAB)
    _ensure_key_action("interact", KEY_E)
    if not InputMap.has_action("attack"):
        InputMap.add_action("attack")
        var mouse := InputEventMouseButton.new()
        mouse.button_index = MOUSE_BUTTON_LEFT
        InputMap.action_add_event("attack", mouse)

func _ensure_key_action(action_name: String, keycode: Key) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
    var event := InputEventKey.new()
    event.physical_keycode = keycode
    InputMap.action_add_event(action_name, event)
