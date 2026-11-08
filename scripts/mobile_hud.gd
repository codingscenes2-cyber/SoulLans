extends CanvasLayer

var player: Node
var status_label: Label

func _ready() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    status_label = Label.new()
    status_label.position = Vector2(24, 20)
    status_label.add_theme_font_size_override("font_size", 20)
    root.add_child(status_label)
    _add_button(root, "ATTACK", Vector2(-150, -145), "attack", Vector2(112, 68), true)
    _add_button(root, "DODGE", Vector2(-270, -75), "dodge", Vector2(105, 64), true)
    _add_button(root, "LOCK", Vector2(-150, -265), "lock_on", Vector2(100, 58), true)
    _add_button(root, "↑", Vector2(95, -190), "move_forward", Vector2(58, 58), false)
    _add_button(root, "↓", Vector2(95, -65), "move_back", Vector2(58, 58), false)
    _add_button(root, "←", Vector2(30, -128), "move_left", Vector2(58, 58), false)
    _add_button(root, "→", Vector2(160, -128), "move_right", Vector2(58, 58), false)

func _process(_delta: float) -> void:
    if is_instance_valid(player) and player.has_method("get_status"):
        var data: Dictionary = player.get_status()
        status_label.text = "SOUL LAND   HP %d/%d   STAMINA %d/%d" % [
            int(data.health), int(data.max_health), int(data.stamina), int(data.max_stamina)
        ]

func _add_button(parent: Control, caption: String, offset: Vector2, action: String, button_size: Vector2, right_side: bool) -> void:
    var button := Button.new()
    button.text = caption
    button.size = button_size
    if right_side:
        button.anchor_left = 1.0
        button.anchor_right = 1.0
        button.position = offset
    else:
        button.anchor_top = 1.0
        button.anchor_bottom = 1.0
        button.position = Vector2(25.0 + offset.x, offset.y)
    button.add_theme_font_size_override("font_size", 16)
    parent.add_child(button)
    button.button_down.connect(func() -> void: Input.action_press(action))
    button.button_up.connect(func() -> void: Input.action_release(action))
