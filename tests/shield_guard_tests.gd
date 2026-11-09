extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player := Node3D.new()
    player.name = "GuardCombatTestPlayer"
    player.add_to_group("player")
    player.position = Vector3(0.0, 0.0, -2.0)
    root.add_child(player)

    var guard := CharacterBody3D.new()
    guard.name = "GuardFrontTest"
    guard.set_script(load("res://scripts/shield_guard.gd"))
    root.add_child(guard)
    await process_frame

    var starting_health: float = guard.health
    guard.take_damage(40.0, 20.0)
    if guard.hit_flash_timer <= 0.0:
        push_error("A mitigated frontal hit must trigger visible hit feedback.")
        quit(1)
        return
    if not is_equal_approx(guard.health, starting_health - 14.0):
        push_error("Shield Guard must mitigate the first frontal hit to 35% damage.")
        quit(1)
        return
    if guard.guard_open_timer > 0.0:
        push_error("Shield Guard opened after only one frontal hit.")
        quit(1)
        return

    guard.take_damage(40.0, 20.0)
    if not is_equal_approx(guard.health, starting_health - 28.0):
        push_error("Shield Guard must mitigate the second frontal hit before opening.")
        quit(1)
        return
    if guard.guard_open_timer <= 0.0:
        push_error("Two frontal hits must open the Shield Guard's guard.")
        quit(1)
        return
    if is_instance_valid(guard.shield_visual) and guard.shield_visual.visible:
        push_error("Shield visual must hide during the guard-open punish window.")
        quit(1)
        return

    var open_health: float = guard.health
    guard.take_damage(40.0, 20.0)
    if guard.hit_flash_timer <= 0.0:
        push_error("An exposed Shield Guard hit must trigger visible hit feedback.")
        quit(1)
        return
    if not is_equal_approx(guard.health, open_health - 40.0):
        push_error("Shield Guard must take full damage during its guard-open window.")
        quit(1)
        return

    guard.queue_free()
    await process_frame
    player.position = Vector3(0.0, 0.0, 2.0)

    var rear_guard := CharacterBody3D.new()
    rear_guard.name = "GuardRearTest"
    rear_guard.set_script(load("res://scripts/shield_guard.gd"))
    root.add_child(rear_guard)
    await process_frame
    rear_guard.take_damage(40.0, 20.0)
    if rear_guard.hit_flash_timer <= 0.0:
        push_error("A rear hit must trigger visible hit feedback.")
        quit(1)
        return
    if not is_equal_approx(rear_guard.health, rear_guard.max_health - 40.0):
        push_error("Rear attacks must bypass Shield Guard frontal mitigation.")
        quit(1)
        return

    print("PASS: Shield Guard frontal mitigation, two-hit opening, punish damage and rear vulnerability")
    quit(0)
