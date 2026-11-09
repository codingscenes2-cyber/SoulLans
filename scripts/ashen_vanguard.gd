extends "res://scripts/training_enemy.gd"

var reward_granted := false
var elite_aura: MeshInstance3D

func _ready() -> void:
    super._ready()
    max_health = 285.0
    health = max_health
    max_poise = 92.0
    poise = max_poise
    attack_damage = 18.0
    current_attack_damage = attack_damage
    soul_reward = 0
    detection_range = 17.0
    lose_target_range = 24.0
    group_alert_radius = 18.0
    if is_instance_valid(enemy_material):
        enemy_material.albedo_color = Color(0.32, 0.19, 0.11)
        enemy_material.metallic = 0.48
        enemy_material.emission_enabled = true
        enemy_material.emission = Color(0.55, 0.12, 0.025)
        enemy_material.emission_energy_multiplier = 0.55
    _create_elite_aura()

func _configure_attack_pattern(_distance: float) -> void:
    attack_pattern_index += 1
    current_attack_kind = "vanguard_crush" if attack_pattern_index % 2 == 0 else "vanguard_cleave"
    current_attack_damage = attack_damage * (1.85 if current_attack_kind == "vanguard_crush" else 1.3)
    current_attack_range = attack_range + (0.55 if current_attack_kind == "vanguard_crush" else 0.2)
    attack_windup = 1.05 if current_attack_kind == "vanguard_crush" else 0.68
    attack_recovery = 1.35 if current_attack_kind == "vanguard_crush" else 0.82

func take_damage(amount: float, poise_damage: float = 12.0) -> void:
    if state == State.DEAD:
        return
    super.take_damage(amount, poise_damage)
    if state == State.DEAD and not reward_granted:
        reward_granted = true
        GameState.set_world_flag("ashen_vanguard_defeated", true)
        GameState.add_item("tempered_plate", 3)
        GameState.award_soul_essence(180)
        GameState.save_game()
        _set_elite_aura(false)

func _create_elite_aura() -> void:
    elite_aura = MeshInstance3D.new()
    elite_aura.name = "VanguardEmberAura"
    var ring := TorusMesh.new()
    ring.inner_radius = 0.78
    ring.outer_radius = 0.91
    elite_aura.mesh = ring
    elite_aura.position = Vector3(0.0, 0.09, 0.0)
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = Color(1.0, 0.24, 0.055, 0.72)
    material.emission_enabled = true
    material.emission = Color(1.0, 0.12, 0.025)
    material.emission_energy_multiplier = 1.8
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    elite_aura.material_override = material
    add_child(elite_aura)

func _set_elite_aura(active: bool) -> void:
    if is_instance_valid(elite_aura):
        elite_aura.visible = active
