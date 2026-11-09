extends SceneTree

const BOSS_SCRIPT = preload("res://scripts/ashen_regent.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    GameState.data["world_flags"] = {}
    GameState.data["defeated_bosses"] = []
    var boss := CharacterBody3D.new()
    boss.name = "AshenRegentTest"
    boss.set_script(BOSS_SCRIPT)
    root.add_child(boss)
    await process_frame

    _expect(not bool(boss.get_boss_status().get("active", true)), "boss remains dormant before Warden unlock")
    var initial_health := boss.health
    boss.take_damage(100.0)
    _expect(is_equal_approx(boss.health, initial_health), "dormant boss cannot be damaged")

    var flags: Dictionary = GameState.data.get("world_flags", {})
    flags["ashen_regent_unlocked"] = true
    GameState.data["world_flags"] = flags
    await physics_frame
    _expect(bool(boss.get_boss_status().get("active", false)), "boss activates after quest unlock")

    boss.health = boss.max_health * 0.59
    boss._update_phase()
    _expect(int(boss.get_boss_status().get("phase", 0)) == 2, "boss enters phase two below 60 percent health")
    _expect(is_equal_approx(boss.attack_damage, 27.0), "phase two increases attack damage")

    boss.health = boss.max_health * 0.24
    boss._update_phase()
    _expect(int(boss.get_boss_status().get("phase", 0)) == 3, "boss enters final phase below 25 percent health")
    _expect(is_equal_approx(boss.attack_damage, 34.0), "final phase increases attack damage")

    boss.queue_free()
    await process_frame
    if failures.is_empty():
        print("SOUL LAND Ashen Regent encounter tests: PASS")
        quit(0)
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, description: String) -> void:
    if condition:
        print("PASS: " + description)
    else:
        failures.append("FAIL: " + description)
