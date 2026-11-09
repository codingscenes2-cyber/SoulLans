extends CanvasLayer

var player: Node
var status_label: Label

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    root.gui_input.connect(_on_root_gui_input)
    add_child(root)

    status_label = Label.new()
    status_label.position = Vector2(22, 18)
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
    root.add_child(status_label)

    _add_button(root, "ATTACK", Vector2(-142, -150), "attack", Vector2(112, 68), true)
    _add_button(root, "DODGE", Vector2(-265, -78), "dodge", Vector2(104, 62), true)
    _add_button(root, "LOCK", Vector2(-142, -258), "lock_on", Vector2(96, 54), true)
    _add_button(root, "REST / USE", Vector2(-270, -258), "interact", Vector2(112, 54), true)
    _add_button(root, "↑", Vector2(92, -192), "move_forward", Vector2(58, 58), false)
    _add_button(root, "↓", Vector2(92, -66), "move_back", Vector2(58, 58), false)
    _add_button(root, "←", Vector2(28, -129), "move_left", Vector2(58, 58), false)
    _add_button(root, "→", Vector2(156, -129), "move_right", Vector2(58, 58), false)
    _add_button(root, "RUN", Vector2(28, -260), "sprint", Vector2(86, 52), false)

func _process(_delta: float) -> void:
    if is_instance_valid(player) and player.has_method("get_status"):
        var data: Dictionary = player.get_status()
        status_label.text = "SOUL LAND   HP %d/%d   STAMINA %d/%d   SOUL ESSENCE %d" % [
            int(data.health), int(data.max_health), int(data.stamina), int(data.max_stamina), GameState.get_soul_essence()
        ]

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
