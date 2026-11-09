extends Node

const HOLLOW_SCRIPT = preload("res://scripts/training_enemy.gd")
const GUARD_SCRIPT = preload("res://scripts/shield_guard.gd")
const ARCHER_SCRIPT = preload("res://scripts/ashen_archer.gd")

enum EncounterState { DORMANT, ACTIVE, INTERMISSION, COMPLETE }

const ENCOUNTER_FLAG := "ashen_courtyard_waves_cleared"
const TRIGGER_POSITION := Vector3(8.0, 0.0, -55.0)
const TRIGGER_RADIUS := 4.8
const WAVE_GAP := 3.0

# Each wave is a compact, authored enemy composition with fixed spawn points.
const WAVES := [
    [
        {"kind": "hollow", "offset": Vector3(-2.8, 1.0, -1.5)},
        {"kind": "hollow", "offset": Vector3(2.8, 1.0, -1.5)}
    ],
    [
        {"kind": "guard", "offset": Vector3(-3.2, 1.0, 0.0)},
        {"kind": "archer", "offset": Vector3(3.2, 1.0, -2.0)}
    ],
    [
        {"kind": "hollow", "offset": Vector3(-3.0, 1.0, -2.5)},
        {"kind": "guard", "offset": Vector3(3.0, 1.0, -2.5)},
        {"kind": "archer", "offset": Vector3(0.0, 1.0, 2.5)}
    ]
]

var encounter_state := EncounterState.DORMANT
var current_wave := 0
var intermission_timer := 0.0
var active_enemies: Array[Node] = []
var world_root: Node3D
var player: Node3D
var hud: Node

func configure(root: Node3D, player_node: Node3D, hud_node: Node) -> void:
    world_root = root
    player = player_node
    hud = hud_node
    if _is_complete_in_save():
        encounter_state = EncounterState.COMPLETE

func update_encounter(delta: float) -> void:
    if encounter_state == EncounterState.COMPLETE or not is_instance_valid(player):
        return
    if encounter_state == EncounterState.DORMANT:
        if player.global_position.distance_to(TRIGGER_POSITION) <= TRIGGER_RADIUS:
            _start_encounter()
        return
    if encounter_state == EncounterState.INTERMISSION:
        intermission_timer = maxf(0.0, intermission_timer - delta)
        if intermission_timer <= 0.0:
            _spawn_next_wave()
        return
    _remove_defeated_enemies()
    if active_enemies.is_empty():
        if current_wave >= WAVES.size():
            _complete_encounter()
        else:
            encounter_state = EncounterState.INTERMISSION
            intermission_timer = WAVE_GAP
            _show_message("Wave %d cleared. Reinforcements approaching..." % current_wave)

func _start_encounter() -> void:
    encounter_state = EncounterState.ACTIVE
    current_wave = 0
    _show_message("ASHEN COURTYARD: Hold the road. Three waves incoming.")
    _spawn_next_wave()

func _spawn_next_wave() -> void:
    if current_wave >= WAVES.size():
        _complete_encounter()
        return
    current_wave += 1
    active_enemies.clear()
    var wave: Array = WAVES[current_wave - 1]
    for spawn_data in wave:
        var enemy := _create_enemy(str(spawn_data["kind"]))
        if enemy == null:
            continue
        enemy.name = "CourtyardWave%d_%s" % [current_wave, str(spawn_data["kind"]).capitalize()]
        enemy.position = TRIGGER_POSITION + spawn_data["offset"]
        world_root.add_child(enemy)
        active_enemies.append(enemy)
    _show_message("ASHEN COURTYARD — WAVE %d / %d" % [current_wave, WAVES.size()])

func _create_enemy(kind: String) -> CharacterBody3D:
    var enemy := CharacterBody3D.new()
    match kind:
        "guard":
            enemy.set_script(GUARD_SCRIPT)
        "archer":
            enemy.set_script(ARCHER_SCRIPT)
        _:
            enemy.set_script(HOLLOW_SCRIPT)
    return enemy

func _remove_defeated_enemies() -> void:
    var remaining: Array[Node] = []
    for enemy in active_enemies:
        if not is_instance_valid(enemy):
            continue
        if int(enemy.get("state")) == 7:
            continue
        remaining.append(enemy)
    active_enemies = remaining

func _complete_encounter() -> void:
    if encounter_state == EncounterState.COMPLETE:
        return
    encounter_state = EncounterState.COMPLETE
    GameState.set_world_flag(ENCOUNTER_FLAG, true)
    GameState.add_item("ashen_scrap", 4)
    GameState.add_item("tempered_plate", 2)
    GameState.award_soul_essence(250)
    GameState.save_game()
    _show_message("COURTYARD SECURED — +250 Soul Essence, 4 Ashen Scrap, 2 Tempered Plates.")
    active_enemies.clear()

func reset_encounter() -> void:
    for enemy in active_enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    active_enemies.clear()
    current_wave = 0
    intermission_timer = 0.0
    encounter_state = EncounterState.COMPLETE if _is_complete_in_save() else EncounterState.DORMANT

func _is_complete_in_save() -> bool:
    return bool(GameState.data.get("world_flags", {}).get(ENCOUNTER_FLAG, false))

func _show_message(message: String) -> void:
    if is_instance_valid(hud) and hud.has_method("show_message"):
        hud.show_message(message)
