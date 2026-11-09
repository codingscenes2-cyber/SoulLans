extends "res://scripts/training_enemy.gd"

# Regional boss: Ashen Regent. The encounter is gated by Warden Eira's
# completed quest and permanently records defeat in GameState.
const BOSS_ID := "ashen_regent"
const UNLOCK_FLAG := "ashen_regent_unlocked"

signal boss_defeated

var phase_index := 0
var encounter_active := false
var boss_title := "ASHEN REGENT"
var special_attack_cooldown := 5.0
var special_attack_windup := 0.0
var special_attack_radius := 4.8
var special_attack_ring: MeshInstance3D

func _ready() -> void:
    max_health = 1200.0
    max_poise = 110.0
    attack_damage = 22.0
    soul_reward = 300
    detection_range = 18.0
    lose_target_range = 24.0
    attack_range = 2.7
    chase_speed = 1.65
    patrol_speed = 0.0
    attack_windup_duration = 0.92
    attack_recovery_duration = 1.05
    stagger_duration = 0.3
    super._ready()
    add_to_group("bosses")
    scale = Vector3(1.42, 1.42, 1.42)
    if is_instance_valid(enemy_visual):
        enemy_visual.scale = Vector3.ONE
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.19, 0.12, 0.16)
        enemy_material.metallic = 0.32
        enemy_material.roughness = 0.66
    _add_regent_crown()
    _create_special_attack_ring()
    encounter_active = _is_unlocked() and not _is_defeated()
    if not encounter_active:
        remove_from_group("enemies")
        state = State.IDLE
        velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
    if _is_defeated():
        if state != State.DEAD:
            state = State.DEAD
            death_timer = 1.65
        death_timer = maxf(0.0, death_timer - delta)
        if death_timer <= 0.0:
            queue_free()
        return
    var unlocked_now := _is_unlocked()
    if unlocked_now and not encounter_active:
        add_to_group("enemies")
    encounter_active = unlocked_now
    if not encounter_active:
        velocity = Vector3.ZERO
        return
    _update_phase()
    _update_special_attack(delta)
    super._physics_process(delta)

func take_damage(amount: float, poise_damage: float = 12.0) -> void:
    if not encounter_active or state == State.DEAD:
        return
    super.take_damage(amount, poise_damage)
    if state == State.DEAD:
        _record_defeat()
        return
    if state == State.STAGGER:
        _cancel_special_attack()
    _update_phase()

func receive_parry() -> void:
    if not encounter_active:
        return
    super.receive_parry()
    _cancel_special_attack()

func get_boss_status() -> Dictionary:
    return {
        "name": boss_title,
        "health": health,
        "max_health": max_health,
        "phase": phase_index + 1,
        "active": encounter_active and state != State.DEAD
    }

func _is_unlocked() -> bool:
    var flags: Dictionary = GameState.data.get("world_flags", {})
    return bool(flags.get(UNLOCK_FLAG, false))

func _is_defeated() -> bool:
    var defeated: Array = GameState.data.get("defeated_bosses", [])
    return defeated.has(BOSS_ID)

func _update_phase() -> void:
    if health <= 0.0:
        return
    var next_phase := 0
    if health <= max_health * 0.25:
        next_phase = 2
    elif health <= max_health * 0.6:
        next_phase = 1
    if next_phase == phase_index:
        return
    phase_index = next_phase
    _set_telegraph(false)
    match phase_index:
        1:
            attack_damage = 27.0
            chase_speed = 2.0
            attack_range = 3.0
            attack_windup_duration = 0.76
            attack_recovery_duration = 0.9
            max_poise = 125.0
            poise = max_poise
            if is_instance_valid(enemy_material):
                enemy_material.albedo_color = Color(0.36, 0.12, 0.11)
        2:
            attack_damage = 34.0
            chase_speed = 2.35
            attack_range = 3.25
            attack_windup_duration = 0.58
            attack_recovery_duration = 0.72
            max_poise = 145.0
            poise = max_poise
            if is_instance_valid(enemy_material):
                enemy_material.albedo_color = Color(0.52, 0.16, 0.07)
    state = State.STAGGER
    state_timer = 0.85
    velocity = Vector3.ZERO
    _cancel_special_attack()

func _cancel_special_attack() -> void:
    special_attack_windup = 0.0
    if is_instance_valid(special_attack_ring):
        special_attack_ring.visible = false
    _set_telegraph(false)

func _update_special_attack(delta: float) -> void:
    if phase_index < 1 or not encounter_active or state == State.DEAD:
        return
    if special_attack_windup > 0.0:
        special_attack_windup = maxf(0.0, special_attack_windup - delta)
        if is_instance_valid(player):
            _face_toward(player.global_position, delta * 2.0)
        if special_attack_windup <= 0.0:
            if is_instance_valid(special_attack_ring):
                special_attack_ring.visible = false
            _set_telegraph(false)
            if is_instance_valid(player) and global_position.distance_to(player.global_position) <= special_attack_radius and absf(player.global_position.y - global_position.y) <= 2.0:
                var slam_damage := 25.0 if phase_index == 1 else 34.0
                if player.has_method("take_damage"):
                    player.take_damage(slam_damage, self)
            special_attack_cooldown = 7.0 if phase_index == 1 else 5.0
        return
    special_attack_cooldown = maxf(0.0, special_attack_cooldown - delta)
    if special_attack_cooldown > 0.0 or not is_instance_valid(player):
        return
    if state in [State.WINDUP, State.RECOVERY, State.STAGGER]:
        return
    if global_position.distance_to(player.global_position) > special_attack_radius + 3.0:
        return
    special_attack_windup = 1.15 if phase_index == 1 else 0.9
    state = State.RECOVERY
    state_timer = special_attack_windup
    velocity = Vector3.ZERO
    _set_telegraph(true)
    if is_instance_valid(special_attack_ring):
        special_attack_ring.visible = true

func _create_special_attack_ring() -> void:
    special_attack_ring = MeshInstance3D.new()
    special_attack_ring.name = "RegentSlamTelegraph"
    var disk := CylinderMesh.new()
    disk.top_radius = 3.35
    disk.bottom_radius = 3.35
    disk.height = 0.025
    special_attack_ring.mesh = disk
    special_attack_ring.position.y = 0.08
    var warning := StandardMaterial3D.new()
    warning.albedo_color = Color(0.95, 0.12, 0.04, 0.28)
    warning.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    warning.emission_enabled = true
    warning.emission = Color(0.9, 0.08, 0.02)
    warning.emission_energy_multiplier = 1.1
    warning.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    special_attack_ring.material_override = warning
    special_attack_ring.visible = false
    add_child(special_attack_ring)

func _record_defeat() -> void:
    var defeated: Array = GameState.data.get("defeated_bosses", [])
    if not defeated.has(BOSS_ID):
        defeated.append(BOSS_ID)
    GameState.data["defeated_bosses"] = defeated
    var flags: Dictionary = GameState.data.get("world_flags", {})
    flags["ashen_regent_defeated"] = true
    GameState.data["world_flags"] = flags
    GameState.add_item("regent_core", 1)
    GameState.save_game()
    boss_defeated.emit()

func _add_regent_crown() -> void:
    var crown := MeshInstance3D.new()
    crown.name = "RegentCrown"
    var crown_mesh := BoxMesh.new()
    crown_mesh.size = Vector3(0.95, 0.16, 0.24)
    crown.mesh = crown_mesh
    crown.position = Vector3(0.0, 2.02, 0.0)
    var crown_material := StandardMaterial3D.new()
    crown_material.albedo_color = Color(0.58, 0.34, 0.12)
    crown_material.metallic = 0.82
    crown_material.roughness = 0.32
    crown.material_override = crown_material
    add_child(crown)
    for side in [-1.0, 1.0]:
        var horn := MeshInstance3D.new()
        var horn_mesh := CylinderMesh.new()
        horn_mesh.top_radius = 0.015
        horn_mesh.bottom_radius = 0.12
        horn_mesh.height = 0.72
        horn.mesh = horn_mesh
        horn.position = Vector3(side * 0.36, 2.35, 0.0)
        horn.rotation.z = deg_to_rad(side * -28.0)
        horn.material_override = crown_material
        add_child(horn)
