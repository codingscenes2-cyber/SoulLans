extends CanvasLayer

const JOYSTICK_SCRIPT = preload("res://scripts/mobile_joystick.gd")

var player: Node
var status_label: Label
var message_label: Label
var quest_label: Label
var boss_label: Label
var boss_health_bar: ProgressBar
var inventory_panel: PanelContainer
var inventory_list: VBoxContainer
var inventory_refresh_timer := 0.0
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
    _add_button(root, "BAG", Vector2(-270, -415), "inventory", Vector2(104, 48), true)
    _create_inventory_panel(root)
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
    if inventory_panel.visible:
        inventory_refresh_timer += delta
        if inventory_refresh_timer >= 0.5:
            inventory_refresh_timer = 0.0
            _refresh_inventory_panel()
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

func _create_inventory_panel(root: Control) -> void:
    inventory_panel = PanelContainer.new()
    inventory_panel.name = "InventoryPanel"
    inventory_panel.anchor_left = 0.5
    inventory_panel.anchor_right = 0.5
    inventory_panel.anchor_top = 0.5
    inventory_panel.anchor_bottom = 0.5
    inventory_panel.offset_left = -245.0
    inventory_panel.offset_right = 245.0
    inventory_panel.offset_top = -225.0
    inventory_panel.offset_bottom = 225.0
    inventory_panel.visible = false
    root.add_child(inventory_panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 10)
    inventory_panel.add_child(layout)
    var heading := HBoxContainer.new()
    layout.add_child(heading)
    var title := Label.new()
    title.text = "INVENTORY  /  EQUIPMENT"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_size_override("font_size", 20)
    heading.add_child(title)
    var close_button := Button.new()
    close_button.text = "CLOSE"
    close_button.pressed.connect(func() -> void: toggle_inventory(false))
    heading.add_child(close_button)

    var hint := Label.new()
    hint.text = "Weapons change your damage, reach and attack timing. Materials are saved automatically."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint.add_theme_font_size_override("font_size", 13)
    layout.add_child(hint)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)
    inventory_list = VBoxContainer.new()
    inventory_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(inventory_list)

func is_inventory_open() -> bool:
    return is_instance_valid(inventory_panel) and inventory_panel.visible

func toggle_inventory(force_open: bool = false) -> void:
    if not is_instance_valid(inventory_panel):
        return
    inventory_panel.visible = force_open or not inventory_panel.visible
    if inventory_panel.visible:
        _refresh_inventory_panel()

func _refresh_inventory_panel() -> void:
    if not is_instance_valid(inventory_list):
        return
    for child in inventory_list.get_children():
        inventory_list.remove_child(child)
        child.queue_free()
    var equipped_id := GameState.get_equipped_weapon_id()
    var equipment_title := Label.new()
    equipment_title.text = "EQUIPPED  " + str(GameState.get_item_info(equipped_id).get("name", "Unarmed"))
    if is_instance_valid(player) and player.has_method("get_status"):
        var player_status: Dictionary = player.get_status()
        equipment_title.text += "\nARMOUR  DEF %.0f  |  DMG REDUCTION %.1f%%  |  LOAD %.1f (%s)" % [float(player_status.get("armor_defense", 0.0)), float(player_status.get("damage_reduction", 0.0)) * 100.0, float(player_status.get("equip_load", 0.0)), str(player_status.get("equip_load_tier", "light")).to_upper()]
    equipment_title.add_theme_color_override("font_color", Color(0.95, 0.78, 0.48))
    inventory_list.add_child(equipment_title)
    for entry in GameState.get_inventory():
        if not entry is Dictionary:
            continue
        var item_id := str(entry.get("id", ""))
        var quantity := int(entry.get("quantity", 0))
        var info := GameState.get_item_info(item_id)
        if info.is_empty() or quantity <= 0:
            continue
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 8)
        inventory_list.add_child(row)
        var details := Label.new()
        var item_title := str(info.get("name", item_id))
        var detail_text := "%s  x%d\n%s" % [item_title, quantity, str(info.get("description", ""))]
        if str(info.get("type", "")) == "weapon":
            var upgrade_level := GameState.get_weapon_upgrade_level(item_id)
            var costs := GameState.get_weapon_upgrade_cost(item_id)
            detail_text = "%s +%d  x%d\n%s" % [item_title, upgrade_level, quantity, str(info.get("description", ""))]
            if not costs.is_empty():
                var cost_parts: Array[String] = []
                for material_id in costs:
                    cost_parts.append("%s x%d" % [str(GameState.get_item_info(str(material_id)).get("name", material_id)), int(costs[material_id])])
                detail_text += "\nNext: " + ", ".join(cost_parts)
            else:
                detail_text += "\nMAX UPGRADE"
        details.text = detail_text
        details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        details.custom_minimum_size = Vector2(260.0, 48.0)
        details.add_theme_font_size_override("font_size", 14)
        row.add_child(details)
        var item_type := str(info.get("type", ""))
        if item_type == "armor":
            var armor_slot := str(info.get("slot", ""))
            var armor_equipped := GameState.get_equipped_armor(armor_slot) == item_id
            var armor_level := GameState.get_armor_upgrade_level(item_id)
            var armor_costs := GameState.get_armor_upgrade_cost(item_id)
            details.text = "%s +%d  |  %s\\nDEF %.0f  |  WEIGHT %.1f\\n%s" % [item_title, armor_level, armor_slot.to_upper(), GameState.get_armor_defense(item_id), float(info.get("weight", 0.0)), str(info.get("description", ""))]
            if armor_costs.is_empty():
                details.text += "\\nMAX REINFORCEMENT"
            else:
                var armor_cost_parts: Array[String] = []
                for material_id in armor_costs:
                    armor_cost_parts.append("%s x%d" % [str(GameState.get_item_info(str(material_id)).get("name", material_id)), int(armor_costs[material_id])])
                details.text += "\\nNext: " + ", ".join(armor_cost_parts)
            var armor_button := Button.new()
            armor_button.text = "WORN" if armor_equipped else "EQUIP"
            armor_button.disabled = armor_equipped
            armor_button.pressed.connect(_on_inventory_armor.bind(item_id))
            row.add_child(armor_button)
            var at_blacksmith_for_armor := is_instance_valid(player) and player.has_method("is_near_blacksmith") and player.is_near_blacksmith()
            var armor_upgrade_button := Button.new()
            armor_upgrade_button.text = "REINFORCE"
            armor_upgrade_button.disabled = not at_blacksmith_for_armor or not GameState.can_upgrade_armor(item_id)
            armor_upgrade_button.pressed.connect(_on_inventory_armor_upgrade.bind(item_id))
            row.add_child(armor_upgrade_button)
        elif item_type == "weapon":
            var equip_button := Button.new()
            equip_button.text = "EQUIPPED" if item_id == equipped_id else "EQUIP"
            equip_button.disabled = item_id == equipped_id
            equip_button.pressed.connect(_on_inventory_equip.bind(item_id))
            row.add_child(equip_button)
            var at_blacksmith := is_instance_valid(player) and player.has_method("is_near_blacksmith") and player.is_near_blacksmith()
            var upgrade_button := Button.new()
            upgrade_button.text = "UPGRADE"
            upgrade_button.disabled = not at_blacksmith or not GameState.can_upgrade_weapon(item_id)
            upgrade_button.pressed.connect(_on_inventory_upgrade.bind(item_id))
            row.add_child(upgrade_button)
        elif item_type == "consumable" and item_id == "ashen_tonic":
            var use_button := Button.new()
            use_button.text = "USE"
            use_button.pressed.connect(_on_inventory_use.bind(item_id))
            row.add_child(use_button)

func _on_inventory_armor_upgrade(item_id: String) -> void:
    if is_instance_valid(player) and player.has_method("upgrade_armor_by_id"):
        if player.upgrade_armor_by_id(item_id):
            show_message("Armour reinforced to +" + str(GameState.get_armor_upgrade_level(item_id)) + ".")
            _refresh_inventory_panel()

func _on_inventory_armor(item_id: String) -> void:
    if is_instance_valid(player) and player.has_method("equip_armor_by_id"):
        if player.equip_armor_by_id(item_id):
            show_message("Armour equipped. Defence and movement load recalculated.")
            _refresh_inventory_panel()

func _on_inventory_equip(item_id: String) -> void:
    if is_instance_valid(player) and player.has_method("equip_weapon_by_id"):
        if player.equip_weapon_by_id(item_id):
            show_message("Equipped " + str(GameState.get_item_info(item_id).get("name", item_id)) + ".")
            _refresh_inventory_panel()

func _on_inventory_upgrade(item_id: String) -> void:
    if is_instance_valid(player) and player.has_method("upgrade_weapon_by_id"):
        if player.upgrade_weapon_by_id(item_id):
            show_message("Weapon upgraded to +" + str(GameState.get_weapon_upgrade_level(item_id)) + ".")
            _refresh_inventory_panel()
        else:
            show_message("Visit the Ashen Blacksmith and bring the required materials.")

func _on_inventory_use(item_id: String) -> void:
    if is_instance_valid(player) and player.has_method("use_inventory_item"):
        if player.use_inventory_item(item_id):
            show_message("Used " + str(GameState.get_item_info(item_id).get("name", item_id)) + ".")
            _refresh_inventory_panel()
        else:
            show_message("Cannot use this item right now.")

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
