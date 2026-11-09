extends "res://scripts/training_enemy.gd"

# Regional boss: Ashen Regent. The encounter is gated by Warden Eira's
# completed quest and permanently records defeat in GameState.
const BOSS_ID := "ashen_regent"
const UNLOCK_FLAG := "ashen_regent_unlocked"

signal boss_defeated

var phase_index := 0
var encounter_active := false
var boss_title := "ASHEN REGENT"

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
    encounter_active = _is_unlocked() and not _is_defeated()
    if not encounter_active:
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
    encounter_active = _is_unlocked()
    if not encounter_active:
        velocity = Vector3.ZERO
        return
    _update_phase()
    super._physics_process(delta)

func take_damage(amount: float, poise_damage: float = 12.0) -> void:
    if not encounter_active or state == State.DEAD:
        return
    super.take_damage(amount, poise_damage)
    if state == State.DEAD:
        _record_defeat()
        return
    _update_phase()

func receive_parry() -> void:
    if not encounter_active:
        return
    super.receive_parry()

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

func _record_defeat() -> void:
    var defeated: Array = GameState.data.get("defeated_bosses", [])
    if not defeated.has(BOSS_ID):
        defeated.append(BOSS_ID)
    GameState.data["defeated_bosses"] = defeated
    var flags: Dictionary = GameState.data.get("world_flags", {})
    flags["ashen_regent_defeated"] = true
    GameState.data["world_flags"] = flags
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
