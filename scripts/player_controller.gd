extends CharacterBody3D

const WEAPON_CATALOG = [preload("res://resources/weapons/ashen_iron_sword.tres"), preload("res://resources/weapons/ashen_iron_dagger.tres")]

signal stats_changed(health: float, stamina: float)
signal died

@export var move_speed := 5.0
@export var sprint_speed := 7.2
@export var dodge_speed := 10.0
@export var max_health := 100.0
@export var max_stamina := 100.0
@export var stamina_regen_rate := 20.0
@export var stamina_regen_delay := 0.8
@export var attack_damage := 25.0
@export var look_sensitivity := 0.006
@export var min_camera_pitch := -0.75
@export var max_camera_pitch := 0.35

var equipped_weapon: Resource
var weapon_index := 0
var current_attack_damage := 25.0
var current_attack_poise_damage := 12.0
var current_attack_range := 2.5
var attack_active_duration := 0.11
var health := 100.0
var stamina := 100.0
var stamina_regen_timer := 0.0
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
var parry_timer := 0.0
var is_blocking := false
var guard_broken_timer := 0.0

func _ready() -> void:
    add_to_group("player")
    health = max_health
    stamina = max_stamina
    equipped_weapon = WEAPON_CATALOG[weapon_index]
    _apply_attributes(false)
    _setup_input_map()
    _create_placeholder_body()
    _create_camera_rig()

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if attack_windup > 0.0:
        attack_windup -= delta
        if attack_windup <= 0.0:
            attack_active_timer = attack_active_duration
            attack_has_hit = false
    if attack_active_timer > 0.0:
        attack_active_timer = maxf(0.0, attack_active_timer - delta)
        if not attack_has_hit:
            _resolve_melee_hit()
            attack_has_hit = true
    dodge_timer = maxf(0.0, dodge_timer - delta)
    invulnerability_timer = maxf(0.0, invulnerability_timer - delta)
    parry_timer = maxf(0.0, parry_timer - delta)
    guard_broken_timer = maxf(0.0, guard_broken_timer - delta)
    is_blocking = Input.is_action_pressed("block") and guard_broken_timer <= 0.0 and dodge_timer <= 0.0
    if Input.is_action_just_pressed("parry") and guard_broken_timer <= 0.0 and dodge_timer <= 0.0 and attack_cooldown <= 0.0:
        parry_timer = 0.22
        is_blocking = true
    stamina_regen_timer = maxf(0.0, stamina_regen_timer - delta)
    if stamina_regen_timer <= 0.0:
        stamina = minf(max_stamina, stamina + stamina_regen_rate * delta)

    if Input.is_action_just_pressed("dodge"):
        perform_dodge()
    if Input.is_action_just_pressed("attack") and not is_blocking:
        perform_attack()
    if Input.is_action_just_pressed("heavy_attack") and not is_blocking:
        perform_heavy_attack()
    if Input.is_action_just_pressed("heal"):
        use_healing_flask()
    if Input.is_action_just_pressed("interact"):
        _interact_with_world()
    if Input.is_action_just_pressed("switch_weapon"):
        switch_weapon()
    if Input.is_action_just_pressed("level_vigor"):
        level_up_attribute("vigor")
    if Input.is_action_just_pressed("level_endurance"):
        level_up_attribute("endurance")
    if Input.is_action_just_pressed("level_strength"):
        level_up_attribute("strength")
    if Input.is_action_just_pressed("level_dexterity"):
        level_up_attribute("dexterity")
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
            stamina_regen_timer = stamina_regen_delay * 0.65
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
    if stamina < 25.0 or dodge_timer > 0.0 or is_blocking:
        return
    stamina -= 25.0
    stamina_regen_timer = stamina_regen_delay
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

func switch_weapon() -> void:
    if attack_cooldown > 0.0 or WEAPON_CATALOG.is_empty():
        return
    weapon_index = (weapon_index + 1) % WEAPON_CATALOG.size()
    equipped_weapon = WEAPON_CATALOG[weapon_index]
    stats_changed.emit(health, stamina)

func level_up_attribute(attribute_id: String) -> bool:
    if global_position.distance_to(GameState.get_sanctuary_position()) > 3.0:
        return false
    if not GameState.level_up_attribute(attribute_id):
        return false
    _apply_attributes(true)
    return true

func _apply_attributes(keep_current_ratio: bool) -> void:
    var old_health := max_health
    var old_stamina := max_stamina
    var attributes := GameState.get_player_attributes()
    max_health = 100.0 + float(attributes.get("vigor", 10) - 10) * 15.0
    max_stamina = 100.0 + float(attributes.get("endurance", 10) - 10) * 10.0
    if keep_current_ratio:
        health = minf(max_health, health + max_health - old_health)
        stamina = minf(max_stamina, stamina + max_stamina - old_stamina)
    else:
        health = minf(health, max_health)
        stamina = minf(stamina, max_stamina)

func _get_scaled_weapon_damage() -> float:
    if not is_instance_valid(equipped_weapon):
        return attack_damage
    var attributes := GameState.get_player_attributes()
    var strength := maxf(0.0, float(attributes.get("strength", 10)) - 10.0)
    var dexterity := maxf(0.0, float(attributes.get("dexterity", 10)) - 10.0)
    var scaling := float(equipped_weapon.get("strength_scaling")) * strength
    scaling += float(equipped_weapon.get("dexterity_scaling")) * dexterity
    return float(equipped_weapon.get("base_damage")) * (1.0 + scaling * 0.025)

func get_weapon_name() -> String:
    if is_instance_valid(equipped_weapon):
        return str(equipped_weapon.get("display_name"))
    return "Unarmed"

func perform_attack() -> void:
    var stamina_cost := float(equipped_weapon.get("stamina_cost")) if is_instance_valid(equipped_weapon) else 12.0
    var windup := float(equipped_weapon.get("light_windup")) if is_instance_valid(equipped_weapon) else 0.13
    var active := float(equipped_weapon.get("light_active")) if is_instance_valid(equipped_weapon) else 0.11
    var recovery := float(equipped_weapon.get("light_recovery")) if is_instance_valid(equipped_weapon) else 0.41
    if attack_cooldown > 0.0 or stamina < stamina_cost or dodge_timer > 0.0 or is_blocking:
        return
    stamina -= stamina_cost
    stamina_regen_timer = stamina_regen_delay
    current_attack_damage = _get_scaled_weapon_damage()
    current_attack_poise_damage = float(equipped_weapon.get("poise_damage")) if is_instance_valid(equipped_weapon) else 12.0
    current_attack_range = float(equipped_weapon.get("attack_range")) if is_instance_valid(equipped_weapon) else 2.5
    attack_active_duration = active
    attack_cooldown = windup + active + recovery
    attack_windup = windup

func perform_heavy_attack() -> void:
    var base_cost := float(equipped_weapon.get("stamina_cost")) if is_instance_valid(equipped_weapon) else 12.0
    var base_windup := float(equipped_weapon.get("light_windup")) if is_instance_valid(equipped_weapon) else 0.13
    var base_active := float(equipped_weapon.get("light_active")) if is_instance_valid(equipped_weapon) else 0.11
    var base_recovery := float(equipped_weapon.get("light_recovery")) if is_instance_valid(equipped_weapon) else 0.41
    var stamina_cost := base_cost * 1.7
    var windup := base_windup + 0.28
    var active := base_active + 0.07
    var recovery := base_recovery + 0.34
    if attack_cooldown > 0.0 or stamina < stamina_cost or dodge_timer > 0.0 or is_blocking:
        return
    stamina -= stamina_cost
    stamina_regen_timer = stamina_regen_delay
    current_attack_damage = _get_scaled_weapon_damage() * 1.65
    current_attack_poise_damage = (float(equipped_weapon.get("poise_damage")) if is_instance_valid(equipped_weapon) else 12.0) * 2.1
    current_attack_range = (float(equipped_weapon.get("attack_range")) if is_instance_valid(equipped_weapon) else 2.5) + 0.2
    attack_active_duration = active
    attack_cooldown = windup + active + recovery
    attack_windup = windup

func _resolve_melee_hit() -> void:
    var hit_shape := SphereShape3D.new()
    hit_shape.radius = maxf(0.7, current_attack_range * 0.38)
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = hit_shape
    query.transform = Transform3D(
        Basis.IDENTITY,
        global_position - global_transform.basis.z * (current_attack_range * 0.5) + Vector3.UP * 1.0
    )
    query.collision_mask = 1
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]
    var hits := get_world_3d().direct_space_state.intersect_shape(query, 8)
    for hit in hits:
        var collider: Object = hit.get("collider")
        if is_instance_valid(collider) and collider.has_method("take_damage"):
            collider.take_damage(current_attack_damage, current_attack_poise_damage)

func use_healing_flask() -> bool:
    if health >= max_health or dodge_timer > 0.0 or attack_cooldown > 0.0:
        return false
    if not GameState.consume_healing_flask():
        return false
    health = minf(max_health, health + 45.0)
    stats_changed.emit(health, stamina)
    return true

func take_damage(amount: float) -> void:
    if invulnerability_timer > 0.0 or health <= 0.0 or amount <= 0.0:
        return
    var facing_target := false
    if is_instance_valid(target):
        var toward_attacker := target.global_position - global_position
        toward_attacker.y = 0.0
        if toward_attacker.length() > 0.01:
            facing_target = (-global_transform.basis.z).dot(toward_attacker.normalized()) >= 0.25
    if parry_timer > 0.0 and facing_target:
        parry_timer = 0.0
        is_blocking = false
        if is_instance_valid(target) and target.has_method("receive_parry"):
            target.receive_parry()
        stamina = minf(max_stamina, stamina + 8.0)
        stats_changed.emit(health, stamina)
        return
    if is_blocking and facing_target:
        var guard_cost := amount * 1.35
        if stamina >= guard_cost:
            stamina -= guard_cost
            stamina_regen_timer = stamina_regen_delay
            stats_changed.emit(health, stamina)
            return
        var overflow := guard_cost - stamina
        stamina = 0.0
        guard_broken_timer = 1.1
        is_blocking = false
        health = maxf(0.0, health - minf(amount, overflow / 1.35 + amount * 0.25))
    else:
        health = maxf(0.0, health - amount)
    stats_changed.emit(health, stamina)
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
    return {"health": health, "max_health": max_health, "stamina": stamina, "max_stamina": max_stamina, "level": GameState.get_player_level(), "soul_essence": GameState.get_soul_essence(), "next_level_cost": GameState.get_next_level_cost(), "healing_flasks": GameState.get_healing_flasks(), "max_healing_flasks": GameState.get_max_healing_flasks()}

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
    _ensure_key_action("heal", KEY_R)
    _ensure_key_action("lock_on", KEY_TAB)
    _ensure_key_action("block", KEY_F)
    _ensure_key_action("heavy_attack", KEY_H)
    _ensure_key_action("parry", KEY_G)
    _ensure_key_action("interact", KEY_E)
    _ensure_key_action("switch_weapon", KEY_Q)
    _ensure_key_action("level_vigor", KEY_1)
    _ensure_key_action("level_endurance", KEY_2)
    _ensure_key_action("level_strength", KEY_3)
    _ensure_key_action("level_dexterity", KEY_4)
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
