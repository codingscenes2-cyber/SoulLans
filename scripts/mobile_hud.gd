extends CanvasLayer

const JOYSTICK_SCRIPT = preload("res://scripts/mobile_joystick.gd")

var player: Node
var status_label: Label
var message_label: Label
var quest_label: Label
var boss_label: Label
var boss_health_bar: ProgressBar
var message_timer := 0.0

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    root.gui_input.connect(_on_root_gui_input)
    add_child(root)

    status_label = Label.new()
    status_label.position = Vector2(22, 18)
    status_label.size = Vector2(680, 58)
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
    root.add_child(status_label)

    message_label = Label.new()
    message_label.position = Vector2(22, 78)
    message_label.size = Vector2(620, 90)
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.add_theme_font_size_override("font_size", 17)
    message_label.add_theme_color_override("font_color", Color(0.98, 0.84, 0.62))
    message_label.visible = false
    root.add_child(message_label)

    quest_label = Label.new()
    quest_label.position = Vector2(22, 174)
    quest_label.size = Vector2(520, 34)
    quest_label.add_theme_font_size_override("font_size", 16)
    quest_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.78))
    quest_label.visible = false
    root.add_child(quest_label)

    boss_label = Label.new()
    boss_label.anchor_left = 0.5
    boss_label.anchor_right = 0.5
    boss_label.offset_left = -230.0
    boss_label.offset_right = 230.0
    boss_label.offset_top = 62.0
    boss_label.offset_bottom = 88.0
    boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    boss_label.add_theme_font_size_override("font_size", 20)
    boss_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.58))
    boss_label.visible = false
    root.add_child(boss_label)

    boss_health_bar = ProgressBar.new()
    boss_health_bar.anchor_left = 0.5
    boss_health_bar.anchor_right = 0.5
    boss_health_bar.offset_left = -220.0
    boss_health_bar.offset_right = 220.0
    boss_health_bar.offset_top = 91.0
    boss_health_bar.offset_bottom = 108.0
    boss_health_bar.show_percentage = false
    boss_health_bar.visible = false
    root.add_child(boss_health_bar)

    _add_button(root, "ATTACK", Vector2(-142, -150), "attack", Vector2(112, 68), true)
    _add_button(root, "HEAVY", Vector2(-142, -225), "heavy_attack", Vector2(112, 56), true)
    _add_button(root, "BLOCK", Vector2(-270, -150), "block", Vector2(104, 58), true)
    _add_button(root, "PARRY", Vector2(-270, -218), "parry", Vector2(104, 54), true)
    _add_button(root, "DODGE", Vector2(-265, -78), "dodge", Vector2(104, 62), true)
    _add_button(root, "LOCK", Vector2(-142, -286), "lock_on", Vector2(96, 54), true)
    _add_button(root, "REST / USE", Vector2(-270, -286), "interact", Vector2(112, 54), true)
    _add_button(root, "WEAPON", Vector2(-142, -350), "switch_weapon", Vector2(96, 52), true)
    _add_button(root, "FLASK", Vector2(-265, -350), "heal", Vector2(104, 52), true)
    var joystick := Control.new()
    joystick.name = "MovementJoystick"
    joystick.set_script(JOYSTICK_SCRIPT)
    joystick.anchor_top = 1.0
    joystick.anchor_bottom = 1.0
    joystick.position = Vector2(22.0, -195.0)
    joystick.custom_minimum_size = Vector2(170.0, 170.0)
    joystick.size = Vector2(170.0, 170.0)
    root.add_child(joystick)
    var level_controls := HBoxContainer.new()
    level_controls.position = Vector2(-365.0, 86.0)
    level_controls.anchor_left = 1.0
    level_controls.anchor_right = 1.0
    level_controls.size = Vector2(350.0, 42.0)
    level_controls.add_theme_constant_override("separation", 5)
    root.add_child(level_controls)
    _add_level_button(level_controls, "VIG", "level_vigor")
    _add_level_button(level_controls, "END", "level_endurance")
    _add_level_button(level_controls, "STR", "level_strength")
    _add_level_button(level_controls, "DEX", "level_dexterity")
    _add_button(root, "RUN", Vector2(205, -92), "sprint", Vector2(86, 52), false)

func _process(delta: float) -> void:
    if message_timer > 0.0:
        message_timer = maxf(0.0, message_timer - delta)
        if message_timer <= 0.0:
            message_label.visible = false
    _update_boss_hud()
    var quest: Dictionary = GameState.get_quest_state("ashen_sigils")
    var quest_status := str(quest.get("status", "not_started"))
    if quest_status == "active":
        quest_label.text = "QUEST  Ashes on the Road  %d/%d foes defeated" % [int(quest.get("progress", 0)), int(quest.get("target", 3))]
        quest_label.visible = true
    elif quest_status == "completed":
        quest_label.text = "QUEST COMPLETE  Ashes on the Road"
        quest_label.visible = true
    else:
        quest_label.visible = false

    if is_instance_valid(player) and player.has_method("get_status"):
        var data: Dictionary = player.get_status()
        status_label.text = "SOUL LAND   LVL %d   HP %d/%d   STA %d/%d   SOULS %d   NEXT %d   FLASKS %d/%d" % [
            int(data.level), int(data.health), int(data.max_health), int(data.stamina), int(data.max_stamina), int(data.soul_essence), int(data.next_level_cost), int(data.healing_flasks), int(data.max_healing_flasks)
        ]
        if player.has_method("get_weapon_name"):
            status_label.text += "   " + player.get_weapon_name()

func _update_boss_hud() -> void:
    var visible_boss: Node
    for candidate in get_tree().get_nodes_in_group("bosses"):
        if is_instance_valid(candidate) and candidate.has_method("get_boss_status"):
            var candidate_status: Dictionary = candidate.get_boss_status()
            if bool(candidate_status.get("active", false)):
                visible_boss = candidate
                break
    if not is_instance_valid(visible_boss):
        boss_label.visible = false
        boss_health_bar.visible = false
        return
    var status: Dictionary = visible_boss.get_boss_status()
    var maximum := maxf(1.0, float(status.get("max_health", 1.0)))
    boss_label.text = "%s  -  PHASE %d" % [str(status.get("name", "BOSS")), int(status.get("phase", 1))]
    boss_health_bar.max_value = maximum
    boss_health_bar.value = clampf(float(status.get("health", 0.0)), 0.0, maximum)
    boss_label.visible = true
    boss_health_bar.visible = true

func show_message(message: String) -> void:
    if not is_instance_valid(message_label):
        return
    message_label.text = message
    message_label.visible = true
    message_timer = 7.0

func _on_root_gui_input(event: InputEvent) -> void:
    if event is InputEventScreenDrag:
        var viewport_width := get_viewport().get_visible_rect().size.x
        if event.position.x > viewport_width * 0.42 and is_instance_valid(player) and player.has_method("add_camera_look"):
            player.add_camera_look(event.relative)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        if is_instance_valid(player) and player.has_method("add_camera_look"):
            player.add_camera_look(event.relative)

func _add_button(parent: Control, caption: String, offset: Vector2, action: String, button_size: Vector2, right_side: bool) -> void:
    var button := Button.new()
    button.text = caption
    button.size = button_size
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    if right_side:
        button.anchor_left = 1.0
        button.anchor_right = 1.0
        button.position = offset
    else:
        button.position = Vector2(25.0 + offset.x, offset.y)
    button.add_theme_font_size_override("font_size", 16)
    button.add_theme_color_override("font_color", Color(0.96, 0.92, 0.84))
    button.add_theme_color_override("font_hover_color", Color(1.0, 0.8, 0.42))
    button.modulate = Color(1.0, 1.0, 1.0, 0.86)
    parent.add_child(button)
    button.button_down.connect(func() -> void: Input.action_press(action))
    button.button_up.connect(func() -> void: Input.action_release(action))

func _add_level_button(parent: HBoxContainer, caption: String, action: String) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(78.0, 40.0)
    button.add_theme_font_size_override("font_size", 13)
    parent.add_child(button)
    button.button_down.connect(func() -> void: Input.action_press(action))
    button.button_up.connect(func() -> void: Input.action_release(action))
