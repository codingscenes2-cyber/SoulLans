extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hollow := CharacterBody3D.new()
    hollow.name = "AttackPatternHollow"
    hollow.set_script(load("res://scripts/training_enemy.gd"))
    root.add_child(hollow)
    await process_frame

    hollow._begin_attack(1.5)
    if hollow.current_attack_kind != "quick_slash":
        push_error("The first Hollow attack must be a quick slash.")
        quit(1)
        return
    if not is_equal_approx(hollow.current_attack_damage, hollow.attack_damage):
        push_error("Quick slash must use the archetype's base damage.")
        quit(1)
        return
    var quick_windup := hollow.state_timer
    var quick_recovery := hollow.attack_recovery_duration
    if hollow.attack_telegraph == null or not hollow.attack_telegraph.visible:
        push_error("Enemy wind-up must display a ground-ring telegraph.")
        quit(1)
        return

    hollow._begin_attack(1.5)
    if hollow.current_attack_kind != "heavy_overhead":
        push_error("The second Hollow attack must be a heavy overhead.")
        quit(1)
        return
    if hollow.current_attack_damage <= hollow.attack_damage * 1.5:
        push_error("Heavy overhead must deal substantially more damage than a quick slash.")
        quit(1)
        return
    if hollow.state_timer <= quick_windup or hollow.attack_recovery_duration <= quick_recovery:
        push_error("Heavy overhead must expose a longer, readable wind-up and recovery.")
        quit(1)
        return
    if hollow.attack_telegraph_material.albedo_color.r < 0.9 or hollow.attack_telegraph_material.albedo_color.g > 0.3:
        push_error("Heavy overhead telegraph must use the stronger danger colour.")
        quit(1)
        return
    if hollow.attacks_started != 2:
        push_error("Attack pattern selection must count both committed attacks.")
        quit(1)
        return

    var archer := CharacterBody3D.new()
    archer.name = "AttackPatternArcher"
    archer.set_script(load("res://scripts/ashen_archer.gd"))
    root.add_child(archer)
    await process_frame
    archer._begin_attack(7.0)
    if archer.current_attack_kind != "ember_bolt":
        push_error("Archer must retain its dedicated ranged attack profile.")
        quit(1)
        return
    if not is_equal_approx(archer.state_timer, 0.9) or not is_equal_approx(archer.current_attack_range, archer.preferred_range):
        push_error("Archer must preserve its ranged wind-up and preferred range.")
        quit(1)
        return

    if not archer.attack_telegraph.visible:
        push_error("Archer ember-bolt wind-up must display its own telegraph.")
        quit(1)
        return

    print("PASS: Hollow attack variety, visual telegraphs and Archer ranged profile")
    quit(0)
