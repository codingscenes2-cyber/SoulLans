extends CharacterBody3D

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_health := 120.0
@export var attack_damage := 10.0
@export var detection_range := 9.0
@export var attack_range := 1.8
var health := 120.0
var state := State.IDLE
var player: Node3D
var attack_cooldown := 0.0

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
    var distance := global_position.distance_to(player.global_position)
    if distance > detection_range:
        state = State.IDLE
        velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
    elif distance > attack_range:
        state = State.CHASE
        var direction := player.global_position - global_position
        direction.y = 0.0
        direction = direction.normalized()
        velocity.x = direction.x * 2.1
        velocity.z = direction.z * 2.1
        look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
    else:
        state = State.ATTACK
        velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
        if attack_cooldown <= 0.0:
            if player.has_method("take_damage"):
                player.take_damage(attack_damage)
            attack_cooldown = 2.0
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

func _create_placeholder_enemy() -> void:
    var visual := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.45
    capsule.height = 1.9
    visual.mesh = capsule
    visual.position.y = 0.95
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.42, 0.13, 0.11)
    visual.material_override = material
    add_child(visual)
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.45
    shape.height = 1.9
    collision.shape = shape
    collision.position.y = 0.95
    add_child(collision)
