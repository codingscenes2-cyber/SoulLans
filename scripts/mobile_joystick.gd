extends Control

@export var joystick_radius := 68.0
@export var deadzone := 0.22

var touch_index := -1
var active := false
var knob_offset := Vector2.ZERO
var held_actions: Array[StringName] = []

func _ready() -> void:
    custom_minimum_size = Vector2(170.0, 170.0)
    size = custom_minimum_size
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index == -1:
            touch_index = event.index
            active = true
            _update_stick(event.position)
            accept_event()
        elif not event.pressed and event.index == touch_index:
            _release_stick()
            accept_event()
    elif event is InputEventScreenDrag and event.index == touch_index:
        _update_stick(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            active = true
            _update_stick(event.position)
        else:
            _release_stick()
        accept_event()
    elif event is InputEventMouseMotion and active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        _update_stick(event.position)
        accept_event()

func _update_stick(pointer_position: Vector2) -> void:
    var center := size * 0.5
    var offset := pointer_position - center
    if offset.length() > joystick_radius:
        offset = offset.normalized() * joystick_radius
    knob_offset = offset
    _apply_direction(offset / joystick_radius)
    queue_redraw()

func _apply_direction(direction: Vector2) -> void:
    var next_actions: Array[StringName] = []
    if direction.x < -deadzone:
        next_actions.append(&"move_left")
    elif direction.x > deadzone:
        next_actions.append(&"move_right")
    if direction.y < -deadzone:
        next_actions.append(&"move_forward")
    elif direction.y > deadzone:
        next_actions.append(&"move_back")
    for action in held_actions:
        if not next_actions.has(action):
            Input.action_release(action)
    for action in next_actions:
        if not held_actions.has(action):
            Input.action_press(action)
    held_actions = next_actions

func _release_stick() -> void:
    active = false
    touch_index = -1
    knob_offset = Vector2.ZERO
    for action in held_actions:
        Input.action_release(action)
    held_actions.clear()
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    draw_circle(center, joystick_radius, Color(0.06, 0.07, 0.09, 0.52))
    draw_arc(center, joystick_radius, 0.0, TAU, 48, Color(0.82, 0.76, 0.64, 0.65), 2.0)
    draw_circle(center + knob_offset, 29.0, Color(0.78, 0.72, 0.62, 0.72))
    draw_arc(center + knob_offset, 29.0, 0.0, TAU, 32, Color(1.0, 0.92, 0.78, 0.9), 2.0)

func _exit_tree() -> void:
    _release_stick()
