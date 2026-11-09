extends SceneTree

const BOSS_SCRIPT = preload("res://scripts/ashen_regent.gd")
const WARDEN_SCRIPT = preload("res://scripts/warden_eira.gd")

var failures: Array[String] = []
var boss_defeat_events := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    GameState.data["world_flags"] = {}
    GameState.data["defeated_bosses"] = []
    var boss: Variant = CharacterBody3D.new()
    boss.name = "AshenRegentTest"
    boss.set_script(BOSS_SCRIPT)
    root.add_child(boss)
    boss.connect("boss_defeated", _on_boss_defeated)
    await process_frame

    _expect(not bool(boss.get_boss_status().get("active", true)), "boss remains dormant before Warden unlock")
    var initial_health := boss.health
    boss.take_damage(100.0)
    _expect(is_equal_approx(boss.health, initial_health), "dormant boss cannot be damaged")

    GameState.data["quests"] = {
        "ashen_sigils": {
            "status": "completed",
            "progress": 3,
            "target": 3,
            "reward": 120,
            "reward_claimed": true
        }
    }
    var warden: Variant = StaticBody3D.new()
    warden.set_script(WARDEN_SCRIPT)
    root.add_child(warden)
    await process_frame
    var warden_message: String = warden.interact()
    _expect(warden_message.contains("Ashen Regent"), "Warden reveals the regional boss after quest completion")
    await physics_frame
    _expect(bool(boss.get_boss_status().get("active", false)), "boss activates through Warden interaction")
    warden.queue_free()

    boss.health = boss.max_health * 0.59
    boss._update_phase()
    _expect(int(boss.get_boss_status().get("phase", 0)) == 2, "boss enters phase two below 60 percent health")
    _expect(is_equal_approx(boss.attack_damage, 27.0), "phase two increases attack damage")

    boss.health = boss.max_health * 0.24
    boss._update_phase()
    _expect(int(boss.get_boss_status().get("phase", 0)) == 3, "boss enters final phase below 25 percent health")
    _expect(is_equal_approx(boss.attack_damage, 34.0), "final phase increases attack damage")

    var essence_before := GameState.get_soul_essence()
    boss.take_damage(5000.0)
    _expect(float(boss.get("health")) <= 0.0, "boss can be defeated")
    var defeated_bosses: Array = GameState.data.get("defeated_bosses", [])
    _expect(defeated_bosses.has("ashen_regent"), "boss defeat is recorded permanently")
    var final_flags: Dictionary = GameState.data.get("world_flags", {})
    _expect(bool(final_flags.get("ashen_regent_defeated", false)), "boss defeat sets a persistent world flag")
    _expect(boss_defeat_events == 1, "boss emits one defeat event for the world gate")
    _expect(GameState.get_soul_essence() >= essence_before + 300, "boss awards its 300 Soul Essence reward")

    boss.queue_free()
    await process_frame
    if failures.is_empty():
        print("SOUL LAND Ashen Regent encounter tests: PASS")
        quit(0)
    for failure in failures:
        push_error(failure)
    quit(1)

func _on_boss_defeated() -> void:
    boss_defeat_events += 1

func _expect(condition: bool, description: String) -> void:
    if condition:
        print("PASS: " + description)
    else:
        failures.append("FAIL: " + description)
