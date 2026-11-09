extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := CharacterBody3D.new()
    player.name = "ArcherRegressionPlayer"
    player.set_script(load("res://scripts/player_controller.gd"))
    player.set("enable_visual_body", false)
    player.add_to_group("player")
    root.add_child(player)
    await process_frame
    player.global_position = Vector3(0.0, 0.0, -7.0)

    var archer := CharacterBody3D.new()
    archer.name = "AshenEmberArcherTest"
    archer.set_script(load("res://scripts/ashen_archer.gd"))
    root.add_child(archer)
    await process_frame
    if not is_equal_approx(archer.max_health, 92.0) or not is_equal_approx(archer.attack_range, 8.5):
        push_error("Ashen Ember Archer must initialize its ranged combat profile.")
        quit(1)
        return
    if archer.can_hit_player():
        push_error("Archer wind-up must not apply instant melee damage.")
        quit(1)
        return
    var projectiles := get_nodes_in_group("enemy_projectiles")
    if projectiles.size() != 1:
        push_error("Archer attack must create exactly one ember projectile.")
        quit(1)
        return
    var bolt: Area3D = projectiles[0]
    if bolt.damage != archer.projectile_damage or bolt.speed != archer.projectile_speed:
        push_error("Ember projectile must inherit configured damage and speed.")
        quit(1)
        return
    var starting_health: float = player.health
    bolt._on_body_entered(player)
    if not is_equal_approx(player.health, starting_health - archer.projectile_damage):
        push_error("A projectile collision with the player must apply ranged damage.")
        quit(1)
        return
    if not bolt.has_hit:
        push_error("Projectile must become spent after its first impact.")
        quit(1)
        return

    archer.take_damage(1000.0)
    if archer.state != archer.State.DEAD:
        push_error("Archer must use inherited health, death and stagger lifecycle.")
        quit(1)
        return
    if GameState.get_item_count("ashen_scrap") < 1:
        push_error("Archer death must use the inherited Ashen Scrap drop.")
        quit(1)
        return

    print("PASS: Ashen Ember Archer ranged projectile, damage, single impact and inherited death rewards")
    quit(0)
