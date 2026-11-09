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
@export var enable_visual_body := true
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
var hud: Node
var camera: Camera3D
var camera_pivot: Node3D
var hero_animation_player: AnimationPlayer
var weapon_attachment: BoneAttachment3D
var weapon_visual_root: Node3D
var current_hero_animation := ""
var dodge_timer := 0.0
var attack_cooldown := 0.0
var attack_windup := 0.0
var attack_active_timer := 0.0
var attack_has_hit := false
var attack_movement_multiplier := 1.0
var dodge_direction := Vector3.FORWARD
var locked_on := false
var camera_yaw := 0.0
var camera_pitch := -0.12
var invulnerability_timer := 0.0
var parry_timer := 0.0
var is_blocking := false
var guard_broken_timer := 0.0
var armor_defense := 0.0
var equip_load := 0.0
var equip_load_tier := "light"
var game_state: Variant

func _ready() -> void:
    game_state = get_node("/root/GameState")
    add_to_group("player")
    health = max_health
    stamina = max_stamina
    equipped_weapon = WEAPON_CATALOG[weapon_index]
    equip_weapon_by_id(game_state.get_equipped_weapon_id(), false)
    _apply_attributes(false)
    _refresh_armor_stats()
    _setup_input_map()
    if enable_visual_body:
        _create_placeholder_body()
    else:
        _create_player_collision()
    _create_camera_rig()

func _physics_process(delta: float) -> void:
    if is_instance_valid(hud) and ((hud.has_method("is_inventory_open") and hud.is_inventory_open()) or (hud.has_method("is_quest_journal_open") and hud.is_quest_journal_open())):
        velocity = Vector3.ZERO
        move_and_slide()
        _update_camera()
        return
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
    if Input.is_action_just_pressed("inventory") and is_instance_valid(hud) and hud.has_method("toggle_inventory"):
        hud.toggle_inventory()
    if Input.is_action_just_pressed("quest_journal") and is_instance_valid(hud) and hud.has_method("toggle_quest_journal"):
        hud.toggle_quest_journal()
    if Input.is_action_just_pressed("level_vigor"):
        level_up_attribute("vigor")
    if Input.is_action_just_pressed("level_endurance"):
        level_up_attribute("endurance")
    if Input.is_action_just_pressed("level_strength"):
        level_up_attribute("strength")
    if Input.is_action_just_pressed("level_dexterity"):
        level_up_attribute("dexterity")
    if Input.is_action_just_pressed("lock_on"):
        _cycle_lock_target()

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var camera_forward := -camera.global_transform.basis.z
    var camera_right := camera.global_transform.basis.x
    camera_forward.y = 0.0
    camera_right.y = 0.0
    var direction := (camera_right.normalized() * input_vector.x - camera_forward.normalized() * input_vector.y).normalized()
    var sprinting := Input.is_action_pressed("sprint") and stamina > 1.0 and direction.length() > 0.1

    if dodge_timer > 0.0:
        var dodge_multiplier := get_dodge_load_multiplier()
        velocity.x = dodge_direction.x * dodge_speed * dodge_multiplier
        velocity.z = dodge_direction.z * dodge_speed * dodge_multiplier
    else:
        var speed := sprint_speed if sprinting else move_speed
        speed *= get_movement_load_multiplier()
        if attack_cooldown > 0.0:
            speed *= attack_movement_multiplier
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
    _update_hero_animation(input_vector, sprinting)
    _update_camera()
    stats_changed.emit(health, stamina)

func _cycle_lock_target() -> void:
    var candidates := get_tree().get_nodes_in_group("enemies")
    var chosen: Node3D
    var best_distance := INF
    for candidate in candidates:
        if not is_instance_valid(candidate) or not candidate is Node3D or candidate.is_queued_for_deletion():
            continue
        if locked_on and is_instance_valid(target) and candidate == target and candidates.size() > 1:
            continue
        var distance := global_position.distance_squared_to(candidate.global_position)
        if distance < best_distance and distance <= 400.0:
            best_distance = distance
            chosen = candidate
    if is_instance_valid(chosen):
        target = chosen
        locked_on = true
    else:
        locked_on = false

func add_camera_look(relative_motion: Vector2) -> void:
    if locked_on:
        return
    camera_yaw -= relative_motion.x * look_sensitivity
    camera_pitch = clampf(camera_pitch - relative_motion.y * look_sensitivity, min_camera_pitch, max_camera_pitch)
    _update_camera()

func perform_dodge() -> void:
    # Recovery is cancellable; wind-up and active strike are committed.
    if stamina < 25.0 or dodge_timer > 0.0 or is_blocking:
        return
    if attack_windup > 0.0 or attack_active_timer > 0.0:
        return
    if attack_cooldown > 0.0:
        attack_cooldown = 0.0
        attack_movement_multiplier = 1.0
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

func get_owned_weapon_ids() -> Array[String]:
    var owned: Array[String] = []
    for entry in game_state.get_inventory():
        if not entry is Dictionary:
            continue
        var item_id := str(entry.get("id", ""))
        if str(game_state.get_item_info(item_id).get("type", "")) == "weapon":
            owned.append(item_id)
    return owned

func equip_weapon_by_id(item_id: String, persist: bool = true) -> bool:
    if attack_cooldown > 0.0 and persist:
        return false
    if not game_state.equip_weapon(item_id):
        return false
    for index in range(WEAPON_CATALOG.size()):
        if str(WEAPON_CATALOG[index].get("weapon_id")) == item_id:
            weapon_index = index
            equipped_weapon = WEAPON_CATALOG[index]
            _refresh_weapon_visual()
            stats_changed.emit(health, stamina)
            return true
    return false

func switch_weapon() -> void:
    if attack_cooldown > 0.0:
        return
    var owned := get_owned_weapon_ids()
    if owned.size() < 2:
        return
    var current_id: String = str(game_state.get_equipped_weapon_id())
    var current_index := owned.find(current_id)
    var next_index := (current_index + 1) % owned.size()
    equip_weapon_by_id(owned[next_index])

func is_near_blacksmith() -> bool:
    for candidate in get_tree().get_nodes_in_group("blacksmiths"):
        if is_instance_valid(candidate) and candidate is Node3D and global_position.distance_to(candidate.global_position) <= 3.5:
            return true
    return false

func upgrade_weapon_by_id(item_id: String) -> bool:
    if not is_near_blacksmith():
        return false
    if not game_state.upgrade_weapon(item_id):
        return false
    stats_changed.emit(health, stamina)
    return true

func upgrade_armor_by_id(item_id: String) -> bool:
    if not is_near_blacksmith() or not game_state.upgrade_armor(item_id):
        return false
    _refresh_armor_stats()
    stats_changed.emit(health, stamina)
    return true

func equip_armor_by_id(item_id: String) -> bool:
    if attack_cooldown > 0.0 or not game_state.equip_armor(item_id):
        return false
    _refresh_armor_stats()
    stats_changed.emit(health, stamina)
    return true

func _refresh_armor_stats() -> void:
    var armor: Dictionary = game_state.get_armor_stats()
    armor_defense = maxf(0.0, float(armor.get("defense", 0.0)))
    equip_load = maxf(0.0, float(armor.get("weight", 0.0)))
    equip_load_tier = "light" if equip_load <= 6.0 else ("medium" if equip_load <= 12.0 else "heavy")

func get_movement_load_multiplier() -> float:
    match equip_load_tier:
        "medium": return 0.92
        "heavy": return 0.78
    return 1.0

func get_dodge_load_multiplier() -> float:
    match equip_load_tier:
        "medium": return 0.86
        "heavy": return 0.68
    return 1.0

func get_damage_reduction() -> float:
    return minf(0.65, armor_defense / (armor_defense + 100.0))

func use_inventory_item(item_id: String) -> bool:
    if item_id == "ashen_tonic":
        if health >= max_health or not game_state.remove_item(item_id, 1):
            return false
        health = minf(max_health, health + 45.0)
        stats_changed.emit(health, stamina)
        return true
    return false

func level_up_attribute(attribute_id: String) -> bool:
    if global_position.distance_to(game_state.get_sanctuary_position()) > 3.0:
        return false
    if not game_state.level_up_attribute(attribute_id):
        return false
    _apply_attributes(true)
    return true

func _apply_attributes(keep_current_ratio: bool) -> void:
    var old_health := max_health
    var old_stamina := max_stamina
    var attributes: Dictionary = game_state.get_player_attributes()
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
    var attributes: Dictionary = game_state.get_player_attributes()
    var strength := maxf(0.0, float(attributes.get("strength", 10)) - 10.0)
    var dexterity := maxf(0.0, float(attributes.get("dexterity", 10)) - 10.0)
    var scaling := float(equipped_weapon.get("strength_scaling")) * strength
    scaling += float(equipped_weapon.get("dexterity_scaling")) * dexterity
    var upgrade_level: int = int(game_state.get_weapon_upgrade_level(str(equipped_weapon.get("weapon_id"))))
    return float(equipped_weapon.get("base_damage")) * (1.0 + scaling * 0.025) * (1.0 + float(upgrade_level) * 0.12)

func get_weapon_name() -> String:
    if is_instance_valid(equipped_weapon):
        var weapon_name := str(equipped_weapon.get("display_name"))
        var upgrade_level: int = int(game_state.get_weapon_upgrade_level(str(equipped_weapon.get("weapon_id"))))
        return weapon_name + (" +" + str(upgrade_level) if upgrade_level > 0 else "")
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
    attack_movement_multiplier = 0.55
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
    attack_movement_multiplier = 0.35
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
        if not is_instance_valid(collider) or not collider.has_method("take_damage"):
            continue
        if collider is Node3D and is_target_in_melee_arc(collider.global_position):
            collider.take_damage(current_attack_damage, current_attack_poise_damage)

# Broad-phase overlap finds nearby enemies; this narrow-phase check prevents
# sword strikes from damaging targets behind the player or outside the swing.
func is_target_in_melee_arc(target_position: Vector3) -> bool:
    var offset := target_position - global_position
    if absf(offset.y) > 1.6:
        return false
    offset.y = 0.0
    var distance := offset.length()
    if distance > current_attack_range + 0.35:
        return false
    if distance <= 0.01:
        return true
    var forward := -global_transform.basis.z
    forward.y = 0.0
    return forward.normalized().dot(offset / distance) >= cos(deg_to_rad(65.0))

func use_healing_flask() -> bool:
    if health >= max_health or dodge_timer > 0.0 or attack_cooldown > 0.0:
        return false
    if not game_state.consume_healing_flask():
        return false
    health = minf(max_health, health + 45.0)
    stats_changed.emit(health, stamina)
    return true

func take_damage(amount: float, attacker: Node3D = null) -> void:
    if invulnerability_timer > 0.0 or health <= 0.0 or amount <= 0.0:
        return
    var attack_source: Node3D = attacker if is_instance_valid(attacker) else (target if is_instance_valid(target) else null)
    var facing_target := false
    if is_instance_valid(attack_source):
        var toward_attacker := attack_source.global_position - global_position
        toward_attacker.y = 0.0
        if toward_attacker.length() > 0.01:
            facing_target = (-global_transform.basis.z).dot(toward_attacker.normalized()) >= 0.25
    if parry_timer > 0.0 and facing_target:
        parry_timer = 0.0
        is_blocking = false
        if is_instance_valid(attack_source) and attack_source.has_method("receive_parry"):
            attack_source.receive_parry()
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
        health = maxf(0.0, health - minf(amount, overflow / 1.35 + amount * 0.25) * (1.0 - get_damage_reduction()))
    else:
        health = maxf(0.0, health - amount * (1.0 - get_damage_reduction()))
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
    if global_position.distance_to(game_state.get_sanctuary_position()) <= 3.0:
        game_state.rest_at_sanctuary(game_state.get_sanctuary_position(), self)
        return

    var nearest: Node3D
    var nearest_distance := 3.0
    for candidate in get_tree().get_nodes_in_group("interactables"):
        if not is_instance_valid(candidate) or not candidate is Node3D:
            continue
        var distance := global_position.distance_to(candidate.global_position)
        if distance <= nearest_distance:
            nearest = candidate
            nearest_distance = distance
    if is_instance_valid(nearest) and nearest.has_method("interact"):
        var message := str(nearest.interact())
        if is_instance_valid(hud) and hud.has_method("show_message"):
            hud.show_message(message)
        return

    game_state.try_recover_souls(global_position)

func apply_saved_state(saved: Dictionary) -> void:
    health = clampf(float(saved.get("health", max_health)), 0.0, max_health)
    stamina = clampf(float(saved.get("stamina", max_stamina)), 0.0, max_stamina)
    stats_changed.emit(health, stamina)

func get_status() -> Dictionary:
    return {"health": health, "max_health": max_health, "stamina": stamina, "max_stamina": max_stamina, "level": game_state.get_player_level(), "soul_essence": game_state.get_soul_essence(), "next_level_cost": game_state.get_next_level_cost(), "healing_flasks": game_state.get_healing_flasks(), "max_healing_flasks": game_state.get_max_healing_flasks(), "armor_defense": armor_defense, "damage_reduction": get_damage_reduction(), "equip_load": equip_load, "equip_load_tier": equip_load_tier}

func _create_placeholder_body() -> void:
    # Load the licensed humanoid when the asset pipeline has supplied it.
    # Keep a collision capsule for predictable mobile combat physics.
    var model_path := "res://assets/characters/ashen_hero_animated.glb"
    var model_loaded := false
    if ResourceLoader.exists(model_path):
        var model_scene := load(model_path) as PackedScene
        if model_scene != null:
            var hero_rig := model_scene.instantiate()
            hero_rig.name = "AshenHeroRig"
            hero_rig.position = Vector3.ZERO
            hero_rig.scale = Vector3.ONE
            _sanitize_hero_meshes(hero_rig)
            _apply_hero_material(hero_rig)
            add_child(hero_rig)
            hero_animation_player = _find_animation_player(hero_rig)
            _attach_weapon_to_hand(hero_rig)
            if is_instance_valid(hero_animation_player):
                _play_hero_animation(["Idle", "Sword_Idle", "Sword_Block"])
            model_loaded = true
    if not model_loaded:
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
    _create_player_collision()

func _create_player_collision() -> void:
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.78
    collision.shape = shape
    collision.position.y = 0.89
    add_child(collision)

func _find_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node
    for child in node.get_children():
        var found := _find_skeleton(child)
        if found != null:
            return found
    return null

func _attach_weapon_to_hand(hero_rig: Node) -> void:
    var skeleton := _find_skeleton(hero_rig)
    if skeleton == null or skeleton.find_bone("hand_r") < 0:
        return
    weapon_attachment = BoneAttachment3D.new()
    weapon_attachment.name = "RightHandWeaponAttachment"
    weapon_attachment.bone_name = "hand_r"
    skeleton.add_child(weapon_attachment)
    weapon_visual_root = Node3D.new()
    weapon_visual_root.name = "EquippedWeaponVisual"
    weapon_attachment.add_child(weapon_visual_root)
    _refresh_weapon_visual()

func _refresh_weapon_visual() -> void:
    if not is_instance_valid(weapon_visual_root):
        return
    for child in weapon_visual_root.get_children():
        weapon_visual_root.remove_child(child)
        child.queue_free()

    var is_dagger := is_instance_valid(equipped_weapon) and str(equipped_weapon.get("weapon_id")).contains("dagger")
    var blade_length := 0.52 if is_dagger else 0.88
    var blade_width := 0.075 if is_dagger else 0.105
    var blade := MeshInstance3D.new()
    var blade_mesh := BoxMesh.new()
    blade_mesh.size = Vector3(blade_width, blade_length, 0.035)
    blade.mesh = blade_mesh
    blade.position = Vector3(0.0, 0.0, -blade_length * 0.62)
    var blade_material := StandardMaterial3D.new()
    blade_material.albedo_color = Color(0.46, 0.5, 0.56)
    blade_material.metallic = 0.88
    blade_material.roughness = 0.24
    blade.material_override = blade_material
    weapon_visual_root.add_child(blade)

    var guard := MeshInstance3D.new()
    var guard_mesh := BoxMesh.new()
    guard_mesh.size = Vector3(0.42 if not is_dagger else 0.28, 0.055, 0.085)
    guard.mesh = guard_mesh
    guard.position.z = -0.045
    var guard_material := StandardMaterial3D.new()
    guard_material.albedo_color = Color(0.24, 0.2, 0.14)
    guard_material.metallic = 0.78
    guard_material.roughness = 0.34
    guard.material_override = guard_material
    weapon_visual_root.add_child(guard)

    var grip := MeshInstance3D.new()
    var grip_mesh := CylinderMesh.new()
    grip_mesh.top_radius = 0.035
    grip_mesh.bottom_radius = 0.045
    grip_mesh.height = 0.24
    grip.mesh = grip_mesh
    grip.rotation.x = PI * 0.5
    grip.position.z = 0.105
    var grip_material := StandardMaterial3D.new()
    grip_material.albedo_color = Color(0.12, 0.075, 0.045)
    grip_material.roughness = 0.92
    grip.material_override = grip_material
    weapon_visual_root.add_child(grip)

    var pommel := MeshInstance3D.new()
    var pommel_mesh := SphereMesh.new()
    pommel_mesh.radius = 0.065
    pommel_mesh.height = 0.13
    pommel.mesh = pommel_mesh
    pommel.position.z = 0.235
    pommel.material_override = guard_material
    weapon_visual_root.add_child(pommel)

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null

func _update_hero_animation(input_vector: Vector2, sprinting: bool) -> void:
    if not is_instance_valid(hero_animation_player):
        return
    var candidates: Array[String] = ["Idle", "Sword_Idle", "Sword_Block"]
    if health <= 0.0:
        candidates = ["Death01"]
    elif dodge_timer > 0.0:
        candidates = ["Roll"]
    elif attack_windup > 0.0 or attack_active_timer > 0.0:
        candidates = ["Sword_Attack", "Sword_Regular_A"]
    elif attack_cooldown > 0.0:
        candidates = ["Sword_Idle", "Idle"]
    elif is_blocking:
        candidates = ["Sword_Block", "Sword_Idle", "Idle"]
    elif input_vector.length() > 0.12:
        candidates = ["Sprint", "Jog_Fwd"] if sprinting else ["Jog_Fwd", "Walk"]
    _play_hero_animation(candidates)

func _play_hero_animation(candidates: Array[String]) -> void:
    if not is_instance_valid(hero_animation_player):
        return
    for clip in candidates:
        if hero_animation_player.has_animation(clip):
            if clip != current_hero_animation:
                hero_animation_player.play(clip, 0.14)
                current_hero_animation = clip
            return

func _sanitize_hero_meshes(root: Node) -> void:
    for child in root.get_children():
        if child is MeshInstance3D and child.mesh == null:
            root.remove_child(child)
            child.free()
        else:
            _sanitize_hero_meshes(child)

func _apply_hero_material(root: Node) -> void:
    var armor_material := StandardMaterial3D.new()
    armor_material.albedo_color = Color(0.16, 0.19, 0.24)
    armor_material.metallic = 0.48
    armor_material.roughness = 0.62
    for child in root.get_children():
        if child is MeshInstance3D and child.mesh != null:
            child.material_override = armor_material
        _apply_hero_material(child)

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
    _ensure_key_action("inventory", KEY_I)
    _ensure_key_action("quest_journal", KEY_J)
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
