extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    GameState.set_world_flag("ashen_vanguard_defeated", false)
    var player := Node3D.new()
    player.name = "VanguardTestPlayer"
    player.add_to_group("player")
    root.add_child(player)

    var vanguard := CharacterBody3D.new()
    vanguard.name = "AshenVanguardTest"
    vanguard.set_script(load("res://scripts/ashen_vanguard.gd"))
    root.add_child(vanguard)
    await process_frame

    if not is_equal_approx(vanguard.max_health, 285.0) or not is_equal_approx(vanguard.soul_reward, 0.0):
        push_error("Ashen Vanguard must load its elite health and base soul reward.")
        quit(1)
        return
    if not is_instance_valid(vanguard.elite_aura) or not vanguard.elite_aura.visible:
        push_error("Ashen Vanguard must show its distinct ember aura.")
        quit(1)
        return

    vanguard._begin_attack(2.0)
    if vanguard.current_attack_kind != "vanguard_cleave" or vanguard.current_attack_damage <= vanguard.attack_damage:
        push_error("Vanguard cleave must use its dedicated elite attack profile.")
        quit(1)
        return
    vanguard.state = vanguard.State.IDLE
    vanguard.attack_pattern_index = 1
    vanguard._begin_attack(2.0)
    if vanguard.current_attack_kind != "vanguard_crush" or vanguard.current_attack_damage < 30.0:
        push_error("Vanguard crush must be a slower, high-damage elite attack.")
        quit(1)
        return

    var plates_before := GameState.get_item_count("tempered_plate")
    vanguard.take_damage(1000.0, 1000.0)
    if vanguard.state != vanguard.State.DEAD:
        push_error("A lethal hit must defeat the Vanguard.")
        quit(1)
        return
    if not bool(GameState.data.get("world_flags", {}).get("ashen_vanguard_defeated", false)):
        push_error("Vanguard defeat must persist its world flag.")
        quit(1)
        return
    if GameState.get_item_count("tempered_plate") != plates_before + 3:
        push_error("Vanguard defeat must grant exactly three Tempered Plates.")
        quit(1)
        return
    vanguard.take_damage(1000.0, 1000.0)
    if GameState.get_item_count("tempered_plate") != plates_before + 3:
        push_error("Vanguard rewards must not be granted more than once.")
        quit(1)
        return

    print("PASS: Ashen Vanguard elite profile, signature attacks, persistent one-time reward")
    quit(0)
