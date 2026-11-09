extends Resource
class_name WeaponData

@export var weapon_id: StringName = &""
@export var display_name := "Unnamed Weapon"
@export_enum("straight_sword", "greatsword", "dagger", "katana", "spear", "axe", "hammer", "scythe", "staff", "bow") var weapon_type := "straight_sword"
@export_range(1.0, 500.0, 0.5) var base_damage := 10.0
@export_range(0.0, 200.0, 0.5) var poise_damage := 10.0
@export_range(1.0, 100.0, 0.5) var stamina_cost := 10.0
@export_range(0.5, 5.0, 0.05) var attack_range := 2.0
@export_range(0.05, 1.5, 0.01) var light_windup := 0.15
@export_range(0.03, 0.5, 0.01) var light_active := 0.1
@export_range(0.05, 2.0, 0.01) var light_recovery := 0.35
@export_range(0.0, 2.0, 0.05) var strength_scaling := 0.5
@export_range(0.0, 2.0, 0.05) var dexterity_scaling := 0.5
@export_multiline var description := ""
