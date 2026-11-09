extends Area3D

@export var speed := 11.0
@export var lifetime := 4.0
@export var damage := 14.0

var direction := Vector3.FORWARD
var attacker: Node3D
var remaining_lifetime := 4.0
var has_hit := false

func _ready() -> void:
    remaining_lifetime = lifetime
    collision_layer = 0
    collision_mask = 1
    monitoring = true
    monitorable = false
    body_entered.connect(_on_body_entered)
    var collision := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 0.24
    collision.shape = sphere
    add_child(collision)
    var visual := MeshInstance3D.new()
    var orb := SphereMesh.new()
    orb.radius = 0.2
    orb.height = 0.4
    visual.mesh = orb
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 0.24, 0.055)
    material.emission_enabled = true
    material.emission = Color(1.0, 0.12, 0.025)
    material.emission_energy_multiplier = 3.0
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    visual.material_override = material
    add_child(visual)

func configure(origin: Vector3, target: Vector3, source: Node3D, hit_damage: float) -> void:
    global_position = origin
    direction = (target - origin).normalized()
    attacker = source
    damage = hit_damage
    if direction.length() > 0.01:
        look_at(global_position + direction, Vector3.UP)

func _physics_process(delta: float) -> void:
    if has_hit:
        return
    global_position += direction * speed * delta
    remaining_lifetime -= delta
    if remaining_lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node3D) -> void:
    if has_hit or not is_instance_valid(body):
        return
    if body == attacker:
        return
    has_hit = true
    if body.is_in_group("player") and body.has_method("take_damage"):
        body.take_damage(damage, attacker)
    queue_free()
