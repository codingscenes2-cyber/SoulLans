extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    GameState.set_world_flag("ashen_courtyard_waves_cleared", false)
    var world := Node3D.new()
    root.add_child(world)
    var player := Node3D.new()
    player.add_to_group("player")
    player.global_position = Vector3(8.0, 0.0, -55.0)
    world.add_child(player)
    var director: Variant = load("res://scripts/encounter_director.gd").new()
    world.add_child(director)
    director.configure(world, player, null)

    director.update_encounter(0.016)
    if director.encounter_state != director.EncounterState.ACTIVE or director.current_wave != 1:
        push_error("Entering the courtyard must start wave one.")
        quit(1)
        return
    if director.active_enemies.size() != 2:
        push_error("Wave one must spawn two Ashen Hollows.")
        quit(1)
        return
    for enemy in director.active_enemies:
        enemy.call("take_damage", 10000.0, 10000.0)
    director.update_encounter(0.016)
    if director.encounter_state != director.EncounterState.INTERMISSION:
        push_error("Clearing a wave must enter the reinforcement intermission.")
        quit(1)
        return
    director.update_encounter(4.0)
    if director.current_wave != 2 or director.active_enemies.size() != 2:
        push_error("Wave two must spawn a Shield Guard and Ember Archer.")
        quit(1)
        return
    for enemy in director.active_enemies:
        enemy.take_damage(10000.0, 10000.0)
    director.update_encounter(0.016)
    director.update_encounter(4.0)
    if director.current_wave != 3 or director.active_enemies.size() != 3:
        push_error("Wave three must spawn the final mixed enemy group.")
        quit(1)
        return
    for enemy in director.active_enemies:
        enemy.take_damage(10000.0, 10000.0)
    director.update_encounter(0.016)
    if director.encounter_state != director.EncounterState.COMPLETE:
        push_error("The third wave must complete the encounter.")
        quit(1)
        return
    if not bool(GameState.data.get("world_flags", {}).get("ashen_courtyard_waves_cleared", false)):
        push_error("Encounter completion must persist in the world save.")
        quit(1)
        return
    var scrap_after := GameState.get_item_count("ashen_scrap")
    var plates_after := GameState.get_item_count("tempered_plate")
    director.reset_encounter()
    director.update_encounter(0.016)
    if director.encounter_state != director.EncounterState.COMPLETE:
        push_error("A completed encounter must not restart after reset or reload.")
        quit(1)
        return
    if GameState.get_item_count("ashen_scrap") != scrap_after or GameState.get_item_count("tempered_plate") != plates_after:
        push_error("Encounter completion must not grant repeat rewards.")
        quit(1)
        return

    print("PASS: three-wave courtyard encounter, wave transitions, persistent one-time rewards")
    quit(0)
