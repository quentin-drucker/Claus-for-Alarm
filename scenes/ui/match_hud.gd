extends CanvasLayer
## Match HUD (Dev 13 "ski lodge" sidebar). Reads match state and calls match controls; it never changes rules itself.
## Refreshes on `match.changed` (event-driven), except the hero strip (cooldown seconds) and the dev-only debug overlay.
## Layout: full-height right sidebar (portrait-card shop <-> selected-tower details, hero strip, wave controls), compact
## stat bar at the playfield top. The gameplay camera keeps the whole route inside the remaining playfield.

const PATH_NAMES: PackedStringArray = ["Top", "Middle", "Bottom"]
const PRIORITY_NAMES: PackedStringArray = ["First", "Last", "Close", "Strong"]  # Targeting.Priority order
## Sidebar width in UI units (base 1152 wide: ~270 px at 1280x720).
const SIDEBAR_W: float = 248.0
const PORTRAIT: String = "res://assets/ui/portraits/%s.png"
const T := preload("res://scripts/ui/lodge_theme.gd")
const FRAME := preload("res://scripts/ui/lodge_frame.gd")

var match_node: Node3D
var _shop_buttons: Array[Button] = []
var _shop_price: Array[Label] = []
var _upgrade_buttons: Array[Button] = []
var _portraits: Dictionary[StringName, Texture2D] = {}
# Sidebar.
var _sidebar: FRAME = FRAME.new()
var _shop_view: VBoxContainer = VBoxContainer.new()
var _details: VBoxContainer = VBoxContainer.new()
var _det_portrait: TextureRect = TextureRect.new()
var _det_name: Label = Label.new()
var _det_sub: Label = Label.new()
var _det_pops: Label = Label.new()
var _info_text: Label = Label.new()
var _target: Button = Button.new()
var _sell: Button = Button.new()
var _back: Button = Button.new()
## Hero strip (P10-T10): shown while Camel Claus is on the course.
var _hero_panel: PanelContainer = PanelContainer.new()
var _hero_text: Label = Label.new()
var _hero_xp: ProgressBar = ProgressBar.new()
var _frenzy: Button = Button.new()
var _focus: Button = Button.new()
var _start: Button = Button.new()
var _pause: Button = Button.new()
var _speed: Button = Button.new()
# Top stat bar.
var _stats: PanelContainer = PanelContainer.new()
var _lives: Label = Label.new()
var _cash: Label = Label.new()
var _round: Label = Label.new()
var _phase: Label = Label.new()
var _last_cash: int = -1
var _hint: Label = Label.new()
## Special-snowball introduction (P13-T05): modal notice until Continue / Space.
var _intro_panel: FRAME = FRAME.new()
var _intro_title: Label = Label.new()
var _intro_text: Label = Label.new()
var _intro_continue: Button = Button.new()
## Event feedback (P13-T06): floating text + banner.
var feedback: Control = preload("res://scenes/ui/feedback_layer.gd").new()

@onready var _debug_panel: PanelContainer = %DebugPanel
@onready var _debug_text: Label = %DebugText
@onready var _overlay: Control = %Overlay
@onready var _overlay_title: Label = %OverlayTitle
@onready var _resume: Button = %ResumeButton
@onready var _restart: Button = %RestartButton
@onready var _menu: Button = %MenuButton


func _ready() -> void:
	match_node = get_parent()
	await match_node.ready  # children are ready before their parent; the match builds shop/clock in its _ready
	feedback.camera = match_node.camera
	add_child(feedback)
	move_child(feedback, 0)  # under the HUD controls
	feedback.offset_right = -SIDEBAR_W  # banners centre over the playfield
	_build_sidebar()
	_build_stats()
	_build_intro_panel()
	_style_overlay()
	feedback.flash_target = _lives
	for c: Node in get_children():
		if c is Control:
			(c as Control).theme = T.get_theme()
	match_node.camera.reserved_right = SIDEBAR_W
	match_node.camera.fit()
	_resume.pressed.connect(match_node.set_paused.bind(false))
	_restart.pressed.connect(match_node.restart)
	_menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn"))
	match_node.changed.connect(_refresh)
	_debug_panel.visible = false
	_debug_text.theme_type_variation = &"Dense"
	_debug_panel.offset_top = 64.0
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and key.keycode == KEY_F3 and OS.is_debug_build():
		_debug_panel.visible = not _debug_panel.visible


func _process(_delta: float) -> void:
	if _debug_panel.visible:
		_debug_text.text = _debug_lines()
	if _hero_panel.visible:
		_refresh_hero()  # cooldown seconds change every tick; reading state only


# --- Build ---------------------------------------------------------------------------------------------------------

func _label(variation: StringName = &"", text: String = "") -> Label:
	var l: Label = Label.new()
	l.theme_type_variation = variation
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _button(text: String, on_press: Callable, variation: StringName = &"", lift: float = 1.02) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_NONE  # Space/keys must reach the match, not re-press a button
	b.pressed.connect(on_press)
	T.juice(b, lift)
	return b


func _portrait(id: StringName) -> Texture2D:
	if not _portraits.has(id):
		_portraits[id] = load(PORTRAIT % id) if ResourceLoader.exists(PORTRAIT % id) else null
	return _portraits[id]


## "Ski Resort Ticket Booth" -> "Ticket Booth": drop leading words until it fits a card.
static func short_name(full: String) -> String:
	var words: PackedStringArray = full.split(" ")
	while words.size() > 1 and " ".join(words).length() > 12:
		words.remove_at(0)
	return " ".join(words)


func _build_sidebar() -> void:
	add_child(_sidebar)
	_sidebar.snow_cap = true
	_sidebar.anchor_left = 1.0
	_sidebar.anchor_right = 1.0
	_sidebar.anchor_bottom = 1.0
	_sidebar.offset_left = -SIDEBAR_W
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 8)
	_sidebar.add_child(column)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var views: VBoxContainer = VBoxContainer.new()
	views.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(views)
	views.add_child(_shop_view)
	views.add_child(_details)
	# Shop: title + two-column portrait cards.
	_shop_view.add_theme_constant_override(&"separation", 6)
	var title: Label = _label(&"Heading", "DEFENDERS")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shop_view.add_child(title)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 6)
	grid.add_theme_constant_override(&"v_separation", 6)
	_shop_view.add_child(grid)
	for i: int in match_node.shop.size():
		var def: TowerDefinition = match_node.shop[i]
		grid.add_child(_card(i, def))
	_build_details()
	_build_hero_panel()
	column.add_child(_hero_panel)
	# Wave controls: festive-red primary Start, Pause + Speed beside each other.
	_start = _button("Start round", func() -> void: match_node.start_round(), &"PrimaryButton")
	_start.custom_minimum_size.y = 44
	column.add_child(_start)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 6)
	_pause = _button("Pause", func() -> void: match_node.set_paused(not match_node.clock.paused))
	_speed = _button("Speed 1x", match_node.toggle_speed)
	for b: Button in [_pause, _speed]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 34
		row.add_child(b)
	column.add_child(row)


func _card(i: int, def: TowerDefinition) -> Button:
	var b: Button = _button("", match_node.begin_placing.bind(def), &"CardButton", 1.05)
	b.custom_minimum_size = Vector2(0, 88)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.set_meta(&"tip", "%s  $%d\n%s\n%s" % [def.display_name, def.price, def.role, _stats_text(def)])
	b.tooltip_text = b.get_meta(&"tip")
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_top = 3
	box.offset_bottom = -5
	box.add_theme_constant_override(&"separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(box)
	var pic: TextureRect = TextureRect.new()
	pic.texture = _portrait(def.id)
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(pic)
	var name_label: Label = _label(&"Small", short_name(def.display_name))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_label)
	var price: Label = _label(&"Price", "$%d" % def.price)
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(price)
	var key: Label = _label(&"Small", str(i + 1))
	key.position = Vector2(6, 3)
	key.add_theme_color_override(&"font_color", T.GOLD)
	key.add_theme_constant_override(&"outline_size", 4)
	key.add_theme_color_override(&"font_outline_color", T.INSET)
	b.add_child(key)
	_shop_buttons.append(b)
	_shop_price.append(price)
	return b


func _build_details() -> void:
	_details.add_theme_constant_override(&"separation", 6)
	_back = _button("< Shop  (Esc)", func() -> void: match_node.select(null))
	_back.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_details.add_child(_back)
	var head: HBoxContainer = HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 8)
	var frame: PanelContainer = PanelContainer.new()
	frame.theme_type_variation = &"LodgeInset"
	_det_portrait.custom_minimum_size = Vector2(64, 64)
	_det_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_det_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_det_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.add_child(_det_portrait)
	head.add_child(frame)
	var names: VBoxContainer = VBoxContainer.new()
	names.add_theme_constant_override(&"separation", 0)
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_det_name = _label(&"Heading")
	_det_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_det_sub = _label(&"Muted")
	_det_pops = _label(&"Price")
	for l: Label in [_det_name, _det_sub, _det_pops]:
		names.add_child(l)
	head.add_child(names)
	_details.add_child(head)
	_info_text = _label(&"Dense")
	_info_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details.add_child(_info_text)
	_target = _button("Target: First (T)", func() -> void: match_node.cycle_priority(match_node.selected))
	_details.add_child(_target)
	for path: int in 3:
		var b: Button = _button("", func() -> void: match_node.buy_upgrade(match_node.selected, path))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size.y = 46
		b.add_theme_font_size_override(&"font_size", 16)
		_details.add_child(b)
		_upgrade_buttons.append(b)
	_sell = _button("Sell", func() -> void: match_node.sell(match_node.selected))
	_sell.add_theme_color_override(&"font_color", T.GOLD)
	_details.add_child(_sell)
	_details.visible = false


func _build_hero_panel() -> void:
	_hero_panel.theme_type_variation = &"LodgeInset"
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 3)
	_hero_panel.add_child(box)
	var head: HBoxContainer = HBoxContainer.new()
	var pic: TextureRect = TextureRect.new()
	pic.texture = _portrait(&"camel_claus")
	pic.custom_minimum_size = Vector2(38, 38)
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	head.add_child(pic)
	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override(&"separation", 2)
	_hero_text = _label(&"Small")
	_hero_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hero_xp.show_percentage = false
	_hero_xp.custom_minimum_size.y = 8.0
	text_box.add_child(_hero_text)
	text_box.add_child(_hero_xp)
	head.add_child(text_box)
	box.add_child(head)
	_frenzy = _button("", func() -> void: match_node.use_frenzy())
	_focus = _button("", func() -> void: match_node.toggle_focus())
	var abilities: HBoxContainer = HBoxContainer.new()
	abilities.add_theme_constant_override(&"separation", 4)
	box.add_child(abilities)
	for b: Button in [_frenzy, _focus]:
		b.add_theme_font_size_override(&"font_size", 14)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 40)
		abilities.add_child(b)
	_hero_panel.tooltip_text = "Camel Claus earns XP at the end of every round and levels up on his own."
	_hero_panel.visible = false


func _build_stats() -> void:
	add_child(_stats)
	_stats.theme_type_variation = &"TopBar"
	_stats.position = Vector2(10, 8)
	_stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stats.add_child(row)
	_lives = _label(&"", "150")
	_cash = _label(&"", "$650")
	_round = _label(&"", "Round 1 / 25")
	_phase = _label(&"Muted", "")
	for l: Label in [_lives, _cash, _round]:
		l.theme_type_variation = &"Dense"
		l.add_theme_font_size_override(&"font_size", 19)
	_cash.add_theme_color_override(&"font_color", T.GOLD)
	row.add_child(_icon(0))
	row.add_child(_lives)
	row.add_child(_icon(1))
	row.add_child(_cash)
	row.add_child(_icon(2))
	row.add_child(_round)
	row.add_child(_phase)
	_phase.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_hint)
	_hint.theme_type_variation = &"Muted"
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.anchor_top = 1.0
	_hint.anchor_bottom = 1.0
	_hint.offset_left = 12.0
	_hint.offset_top = -26.0
	_hint.add_theme_color_override(&"font_color", Color(T.CREAM, 0.9))
	_hint.add_theme_constant_override(&"outline_size", 5)
	_hint.add_theme_color_override(&"font_outline_color", Color(T.INSET, 0.85))
	_hint.text = "1-7 buy · click place/select · hover tickets · T target · Q Frenzy · E Focus · Space start · P pause · F speed"
	if OS.is_debug_build():
		_hint.text += " · F3 debug"


## Tiny drawn stat icons (0 heart, 1 coin, 2 flag): original, no font glyphs needed in the browser.
func _icon(kind: int) -> Control:
	var c: Control = Control.new()
	c.custom_minimum_size = Vector2(20, 20)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(_draw_icon.bind(c, kind))
	return c


func _draw_icon(c: Control, kind: int) -> void:
	match kind:
		0:
			c.draw_circle(Vector2(6, 8), 4.6, T.RED_HI)
			c.draw_circle(Vector2(14, 8), 4.6, T.RED_HI)
			c.draw_colored_polygon(PackedVector2Array([Vector2(1.6, 9.5), Vector2(18.4, 9.5), Vector2(10, 18)]), T.RED_HI)
			c.draw_circle(Vector2(5.5, 6.5), 1.4, Color(1, 1, 1, 0.7))
		1:
			c.draw_circle(Vector2(10, 10), 8.5, T.BRASS)
			c.draw_circle(Vector2(10, 10), 6.5, T.GOLD)
			c.draw_rect(Rect2(8.6, 5, 2.8, 10), T.BRASS)
		2:
			c.draw_rect(Rect2(4, 2, 2, 16), T.CREAM)
			c.draw_colored_polygon(PackedVector2Array([Vector2(6, 2), Vector2(17, 6), Vector2(6, 10)]), T.RED_HI)


func _build_intro_panel() -> void:
	add_child(_intro_panel)
	_intro_panel.snow_cap = true
	_intro_panel.garland = true
	_intro_panel.anchor_left = 0.5
	_intro_panel.anchor_right = 0.5
	_intro_panel.anchor_top = 0.5
	_intro_panel.anchor_bottom = 0.5
	_intro_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_intro_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_intro_panel.offset_left = -SIDEBAR_W / 2.0 - 250.0  # centred over the playfield
	_intro_panel.offset_right = -SIDEBAR_W / 2.0 + 250.0
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 10)
	_intro_panel.add_child(box)
	box.add_child(Control.new())  # clears the garland
	_intro_title.add_theme_font_size_override(&"font_size", 24)
	_intro_title.theme_type_variation = &"Heading"
	_intro_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_continue.theme_type_variation = &"PrimaryButton"
	_intro_continue.focus_mode = Control.FOCUS_NONE  # Space reaches the match, which acknowledges exactly once
	_intro_continue.pressed.connect(func() -> void: match_node.acknowledge_intro())
	T.juice(_intro_continue, 1.02)
	for c: Control in [_intro_title, _intro_text, _intro_continue]:
		box.add_child(c)
	_intro_panel.visible = false


## Pause / victory / defeat: the scene's overlay box inside a lodge frame, centred over the playfield.
func _style_overlay() -> void:
	var center: Control = _overlay.get_node("Center")
	center.offset_right = -SIDEBAR_W
	var box: Control = center.get_node("Box")
	var frame: FRAME = FRAME.new()
	frame.snow_cap = true
	frame.garland = true
	frame.custom_minimum_size.x = 380
	center.remove_child(box)
	frame.add_child(box)
	center.add_child(frame)
	box.add_theme_constant_override(&"separation", 12)
	box.add_child(Control.new())
	box.move_child(box.get_child(-1), 0)  # clears the garland
	_overlay_title.theme_type_variation = &"Heading"
	_overlay_title.add_theme_font_size_override(&"font_size", 28)
	_overlay_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_overlay_title.custom_minimum_size.x = 340
	(_overlay as ColorRect).color = Color(0.03, 0.07, 0.1, 0.72)
	_resume.theme_type_variation = &"PrimaryButton"
	for b: Button in [_resume, _restart, _menu]:
		b.custom_minimum_size.y = 42
		T.juice(b, 1.03)


# --- Refresh -------------------------------------------------------------------------------------------------------

func _refresh() -> void:
	var m: Node3D = match_node
	var over: bool = m.is_over()
	var state_name: String = m.State.keys()[m.state]
	_phase.text = {"PREPARE": "Build phase", "ROUND_SPAWN": "Wave incoming", "ROUND_CLEANUP": "Clearing wave",
			"ROUND_REWARD": "Wave cleared", "WON": "Victory", "LOST": "Defeat"}.get(state_name, state_name.capitalize())
	_lives.text = str(m.lives)
	_cash.text = "$%d" % m.ledger.cash
	if _last_cash >= 0 and m.ledger.cash < _last_cash and not T.reduced_motion():
		_cash.pivot_offset = _cash.size / 2.0  # purchase: brief squeeze of the cash figure
		_cash.scale = Vector2(1.18, 1.18)
		_cash.create_tween().tween_property(_cash, ^"scale", Vector2.ONE, 0.18)
	_last_cash = m.ledger.cash
	_round.text = "Round %d / %d" % [maxi(m.round_index + 1, 1) if m.state != m.State.PREPARE else m.round_index + 2,
			Content.rounds.size()]
	var hero_out: bool = m.hero_node() != null
	for i: int in _shop_buttons.size():
		var def: TowerDefinition = m.shop[i]
		var b: Button = _shop_buttons[i]
		var price: Label = _shop_price[i]
		var owned: bool = def is HeroDefinition and hero_out
		var short: bool = m.ledger.cash < def.price
		price.text = "On the course" if owned else "$%d" % def.price
		b.tooltip_text = b.get_meta(&"tip") + ("\nNeed $%d more" % (def.price - m.ledger.cash) if short and not owned else "")
		price.add_theme_color_override(&"font_color", T.MUTED if owned else T.BAD if short else T.GOLD)
		b.disabled = over or short or owned
		b.modulate = Color(1, 1, 1, 0.55) if owned else Color(0.78, 0.78, 0.8) if short else Color.WHITE
		_mark_selected(b, m.placing == def)
	_start.disabled = not m.can_start_round()
	if over:
		_start.text = "Match over"
	elif m.clock.paused:
		_start.text = "Paused"
	elif m.intro != &"":
		_start.text = "Read the notice"
	elif m.state != m.State.PREPARE:
		_start.text = "Round in progress"
	else:
		_start.text = "Start round %d (Space)" % (m.round_index + 2)
	_pause.disabled = over
	_pause.text = "Resume (P)" if m.clock.paused else "Pause (P)"
	_speed.text = "Speed %dx (F)" % m.clock.speed
	_refresh_info()
	_refresh_hero()
	var was_visible: bool = _intro_panel.visible
	_intro_panel.visible = m.intro != &"" and not over
	if _intro_panel.visible:
		var info: Array = m.INTROS[m.intro]
		_intro_title.text = "New in round %d: %s" % [m.round_index + 2, info[0]]
		_intro_text.text = info[1]
		_intro_continue.text = "Continue - start round %d (Space)" % (m.round_index + 2)
		_intro_continue.disabled = m.clock.paused
		if not was_visible:
			_pop_in(_intro_panel)
	var overlay_was: bool = _overlay.visible
	_overlay.visible = over or m.clock.paused
	if _overlay.visible and not overlay_was:
		_pop_in(_overlay)
	_resume.visible = not over
	if m.state == m.State.WON:
		_overlay_title.text = "Victory! The finish line held for all %d rounds." % Content.rounds.size()
	elif m.state == m.State.LOST:
		_overlay_title.text = "Defeat - the snowballs broke through in round %d." % (m.round_index + 1)
	else:
		_overlay_title.text = "Paused"


## Readable notice transition: quick fade in (no motion when reduced motion is requested).
func _pop_in(c: CanvasItem) -> void:
	if T.reduced_motion():
		return
	c.modulate.a = 0.0
	c.create_tween().tween_property(c, ^"modulate:a", 1.0, 0.15)


## Selected card (the defender being placed): red/gold outline that stays while placing.
func _mark_selected(b: Button, on: bool) -> void:
	if not on:
		b.remove_theme_stylebox_override(&"normal")
		b.remove_theme_stylebox_override(&"hover")
		return
	var s: StyleBoxFlat = (T.get_theme().get_stylebox(&"hover", &"CardButton") as StyleBoxFlat).duplicate()
	s.bg_color = Color("3a2a2c")
	s.border_color = T.GOLD
	s.set_border_width_all(3)
	b.add_theme_stylebox_override(&"normal", s)
	b.add_theme_stylebox_override(&"hover", s)


## Selected tower details (P04-T04) with one upgrade button per path (P09-T10): replaces the shop in the sidebar.
func _refresh_info() -> void:
	var tower: Node3D = match_node.selected
	var on: bool = is_instance_valid(tower)
	_details.visible = on
	_shop_view.visible = not on
	if not on:
		return
	var def: TowerDefinition = tower.def
	var is_hero: bool = def is HeroDefinition
	_det_portrait.texture = _portrait(def.id)
	_det_name.text = def.display_name
	_det_sub.text = "Level %d hero" % tower.level if is_hero else "Upgrades %d-%d-%d" % [tower.tiers.x, tower.tiers.y, tower.tiers.z]
	_det_pops.text = "Pops: %d" % tower.pops
	var lines: PackedStringArray = []
	if is_hero:
		lines.append("Levels up from rounds, no upgrades")
	if def.global_range:
		lines.append("Range: whole map (line of sight)")
	elif tower.range_units > 0.0:
		lines.append("Range: %s (%.1f m)" % [tower.range_units, tower.range_units * GameDefinition.UNIT_M])
	_target.visible = not def.attacks.is_empty()
	_target.text = "Target: %s (T)" % PRIORITY_NAMES[tower.priority]
	if def.attacks.is_empty():
		lines.append("Income: %d tickets x $%d per round" % [tower.pickups_per_round, tower.cash_per_pickup])
	lines.append("Invested $%d" % tower.spent)
	for path: int in 3:
		var button: Button = _upgrade_buttons[path]
		button.visible = not is_hero
		var next: UpgradeDefinition = def.get_upgrade(path, tower.tiers[path] + 1)
		var state: String = match_node.upgrade_state(tower, path)
		var head: String = "%s %d/5" % [PATH_NAMES[path], tower.tiers[path]]
		match state:
			"max":
				button.text = "%s  max" % head
			"locked":
				button.text = "%s  locked: only one path past tier 2" % head if tower.tiers[path] >= 2 \
						else "%s  locked: only two paths per defender" % head
			"soon":
				button.text = "%s  %s - coming soon" % [head, next.display_name]
			"unaffordable":
				button.text = "%s  %s\n$%d (need $%d)" % [head, next.display_name, next.price, next.price - match_node.ledger.cash]
			_:
				button.text = "%s  %s\n$%d" % [head, next.display_name, next.price]
		button.tooltip_text = "" if next == null else "%s  $%d\n%s" % [next.display_name, next.price, _effects_text(next, def)]
		button.disabled = state != "ok" or match_node.is_over()
	_info_text.text = "\n".join(lines)
	_sell.text = "Sell for $%d" % match_node.sell_value(tower)
	_sell.disabled = match_node.is_over()


## Level, XP to next level, next milestone, Frenzy ready/active/cooldown, Focus on/off (state from the match).
func _refresh_hero() -> void:
	var hero: Node3D = match_node.hero_node()
	_hero_panel.visible = hero != null
	if hero == null:
		return
	var def: HeroDefinition = hero.def
	var lines: PackedStringArray = []
	if hero.level < def.level_xp.size():
		var lo: int = def.level_xp[hero.level - 1]
		var hi: int = def.level_xp[hero.level]
		_hero_xp.min_value = lo
		_hero_xp.max_value = hi
		_hero_xp.value = hero.xp
		lines.append("Level %d   XP %d/%d" % [hero.level, hero.xp, hi])
		_hero_xp.tooltip_text = "Next: %s" % def.level_changes[hero.level].get("summary", "")
	else:
		_hero_xp.value = _hero_xp.max_value
		lines.append("Level %d (max)" % hero.level)
	_hero_text.text = "\n".join(lines)
	var over: bool = match_node.is_over()
	match match_node.frenzy_state():
		"locked":
			_frenzy.text = "Frenzy (Q)
Level %d unlock" % _unlock_level(def, "snowball_frenzy")
		"active":
			_frenzy.text = "Frenzy (Q)
active %.1f s" % hero.frenzy_left
		"cooldown":
			_frenzy.text = "Frenzy (Q)
recharge %d s" % ceili(hero.frenzy_cooldown_left)
		_:
			_frenzy.text = "Frenzy (Q)
READY: 3x speed"
	_frenzy.disabled = over or match_node.clock.paused or match_node.frenzy_state() != "ready"
	var variation: StringName = &"PrimaryButton" if not _frenzy.disabled else &""
	if _frenzy.theme_type_variation != variation:
		_frenzy.theme_type_variation = variation
	if hero.has_unlock("focused_shot"):
		_focus.text = "Focus (E)
%s" % ("ON" if hero.focus else "off")
	else:
		_focus.text = "Focus (E)
Level %d unlock" % _unlock_level(def, "focused_shot")
	_focus.disabled = over or not hero.has_unlock("focused_shot")


func _unlock_level(def: HeroDefinition, what: String) -> int:
	for i: int in def.level_changes.size():
		if what in [def.level_changes[i].get("unlock_ability", ""), def.level_changes[i].get("unlock_stance", "")]:
			return i + 1
	return 0


## Plain stats line for a shop tooltip (from the data, never hard-coded).
func _stats_text(def: TowerDefinition) -> String:
	if def.attacks.is_empty():
		return "%d tickets x $%d per round" % [def.pickups_per_round, def.cash_per_pickup]
	var a: AttackDefinition = def.attacks[0]
	var reach: String = "whole map" if def.global_range else str(def.range_units)
	return "Range %s · every %s s · damage %d · pierce %d" % [reach, a.interval_s, a.damage, a.pierce]


## What an upgrade changes, generated from its effects (e.g. "pierce +1, interval x0.5, adds wall").
func _effects_text(upgrade: UpgradeDefinition, def: TowerDefinition) -> String:
	var parts: PackedStringArray = []
	for e: UpgradeEffect in upgrade.effects:
		var field: String = String(e.field).replace("_units", "").replace("_s", "").replace("_", " ")
		match e.op:
			UpgradeEffect.Op.ADD:
				parts.append("%s %s%s" % [field, "+" if e.value >= 0.0 else "", snappedf(e.value, 0.01)])
			UpgradeEffect.Op.MULTIPLY:
				parts.append("%s x%s" % [field, snappedf(e.value, 0.01)])
			UpgradeEffect.Op.SET:
				parts.append("%s = %s" % [field, e.text if e.text != &"" else str(snappedf(e.value, 0.01))])
			UpgradeEffect.Op.APPEND:
				parts.append("adds " + String(e.attack.id).trim_prefix(String(def.id) + "_").replace("_", " "))
	return ", ".join(parts) if not parts.is_empty() else "coming soon"


## Dev-only overlay (P04-T06): F3 in debug builds; absent from release exports.
func _debug_lines() -> String:
	var m: Node3D = match_node
	var lines: PackedStringArray = [
		"tick %d   speed %sx   paused %s" % [m.clock.tick, m.clock.speed, m.clock.paused],
		"state %s   round %d   spawned %d/%d" % [m.State.keys()[m.state], m.round_index + 1, m._spawn_cursor, m._schedule.size()],
		"snowballs %d   towers %d   shots %d" % [m.snowballs.size(), m.towers_root.get_child_count(), m.shots.size()],
		"last transactions:",
	]
	for t: Dictionary in m.ledger.transactions.slice(-5):
		lines.append("  t%d %s %+d -> $%d (src %d)" % [t.tick, t.reason, t.amount, t.balance, t.source_id])
	return "\n".join(lines)
