extends "res://scripts/training_enemy.gd"

# A slower, shielded Ashen Watch veteran. Front-facing hits are heavily
# mitigated until repeated pressure breaks its guard and opens a punish window.
var guard_pressure := 0
var guard_open_timer := 0.0
var shield_visual: MeshInstance3D
var shield_material: StandardMaterial3D

func _ready() -> void:
    max_health = 165.0
    max_poise = 54.0
    attack_damage = 13.0
    soul_reward = 35
    detection_range = 11.0
    attack_range = 2.15
    chase_speed = 1.75
    attack_windup_duration = 0.68
    attack_recovery_duration = 0.82
    super._ready()
    _create_shield()

func _physics_process(delta: float) -> void:
    guard_open_timer = maxf(0.0, guard_open_timer - delta)
    super._physics_process(delta)
    if is_instance_valid(shield_visual):
        shield_visual.visible = guard_open_timer <= 0.0

func take_damage(amount: float, poise_damage: float = 12.0) -> void:
    if state == State.DEAD or amount <= 0.0:
        return
    var frontal := false
    if is_instance_valid(player):
        var toward_player := player.global_position - global_position
        toward_player.y = 0.0
        if toward_player.length() > 0.01:
            frontal = (-global_transform.basis.z).dot(toward_player.normalized()) >= 0.2
    if frontal and guard_open_timer <= 0.0 and state != State.STAGGER:
        guard_pressure += 1
        health = maxf(0.0, health - amount * 0.35)
        poise = maxf(0.0, poise - poise_damage * 0.25)
        if guard_pressure >= 2:
            guard_pressure = 0
            guard_open_timer = 1.35
            if is_instance_valid(shield_visual):
                shield_visual.visible = false
            _flash_hit()
        elif is_instance_valid(shield_material):
            shield_material.albedo_color = Color(0.75, 0.72, 0.62)
        if health <= 0.0:
            _die_guard()
        elif poise <= 0.0:
            state = State.STAGGER
            state_timer = stagger_duration
            poise = max_poise
            _set_telegraph(false)
        return
    health = maxf(0.0, health - amount)
    poise = maxf(0.0, poise - poise_damage)
    if health <= 0.0:
        _die_guard()
    elif poise <= 0.0:
        state = State.STAGGER
        state_timer = stagger_duration
        poise = max_poise
        _set_telegraph(false)
        _flash_hit()

func _die_guard() -> void:
    state = State.DEAD
    velocity = Vector3.ZERO
    GameState.award_soul_essence(soul_reward)
    queue_free()

func _create_shield() -> void:
    shield_visual = MeshInstance3D.new()
    shield_visual.name = "AshenWatchShield"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.9, 1.25, 0.18)
    shield_visual.mesh = mesh
    shield_visual.position = Vector3(0.0, 1.0, -0.58)
    shield_material = StandardMaterial3D.new()
    shield_material.albedo_color = Color(0.28, 0.32, 0.36)
    shield_material.metallic = 0.72
    shield_material.roughness = 0.38
    shield_visual.material_override = shield_material
    add_child(shield_visual)
