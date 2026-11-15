extends CanvasLayer
## Placeholder match HUD (P04). Reads match state and calls match controls; it never changes rules itself.
## Refreshes on `match.changed` (event-driven), except the dev-only debug overlay which updates per frame.

const PATH_NAMES: PackedStringArray = ["Top", "Middle", "Bottom"]
const PRIORITY_NAMES: PackedStringArray = ["First", "Last", "Close", "Strong"]  # Targeting.Priority order

var match_node: Node3D
var _shop_buttons: Array[Button] = []
var _upgrade_buttons: Array[Button] = []
## Hero panel (P10-T10), bottom-left, shown while Camel Claus is on the course.
var _hero_panel: PanelContainer = PanelContainer.new()
var _hero_text: Label = Label.new()
var _hero_xp: ProgressBar = ProgressBar.new()
var _frenzy: Button = Button.new()
var _focus: Button = Button.new()
## Special-snowball introduction (P13-T05): modal notice until Continue / Space.
var _intro_panel: PanelContainer = PanelContainer.new()
var _intro_title: Label = Label.new()
var _intro_text: Label = Label.new()
var _intro_continue: Button = Button.new()
## Placeholder event feedback (P13-T06): floating text + banner.
var feedback: Control = preload("res://scenes/ui/feedback_layer.gd").new()

@onready var _stats: Label = %Stats
@onready var _shop: VBoxContainer = %Shop
@onready var _info_panel: PanelContainer = %InfoPanel
@onready var _info_text: Label = %InfoText
@onready var _sell: Button = %SellButton
@onready var _target: Button = %TargetButton
@onready var _start: Button = %StartButton
@onready var _pause: Button = %PauseButton
@onready var _speed: Button = %SpeedButton
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
	for i: int in match_node.shop.size():
		var def: TowerDefinition = match_node.shop[i]
		var button: Button = Button.new()
		button.text = "%d  %s  $%d" % [i + 1, def.display_name, def.price]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE  # Space/keys must reach the match, not re-press a button
		button.pressed.connect(match_node.begin_placing.bind(def))
		button.tooltip_text = "%s  $%d
%s
%s" % [def.display_name, def.price, def.role, _stats_text(def)]
		_shop.add_child(button)
		_shop_buttons.append(button)
	for path: int in 3:
		var button: Button = Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: match_node.buy_upgrade(match_node.selected, path))
		_target.add_sibling(button)
		_target.get_parent().move_child(button, _target.get_index())
		_upgrade_buttons.append(button)
	_build_hero_panel()
	_build_intro_panel()
	_apply_theme()
	feedback.camera = match_node.camera
	feedback.flash_target = _stats
	add_child(feedback)
	move_child(feedback, 0)  # under the HUD controls
	_start.pressed.connect(match_node.start_round)
	_pause.pressed.connect(func() -> void: match_node.set_paused(not match_node.clock.paused))
	_speed.pressed.connect(match_node.toggle_speed)
	_sell.pressed.connect(func() -> void: match_node.sell(match_node.selected))
	_target.pressed.connect(func() -> void: match_node.cycle_priority(match_node.selected))
	_resume.pressed.connect(match_node.set_paused.bind(false))
	_restart.pressed.connect(match_node.restart)
	_menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn"))
	match_node.changed.connect(_refresh)
	_debug_panel.visible = false
	if not OS.is_debug_build():
		$Hint.text = $Hint.text.replace(" · F3 debug", "")
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and key.keycode == KEY_F3 and OS.is_debug_build():
		_debug_panel.visible = not _debug_panel.visible


func _process(_delta: float) -> void:
	if _debug_panel.visible:
		_debug_text.text = _debug_lines()
	if _info_panel.visible:  # the card sits under the shop, whatever height the shop has (no overlap)
		var shop: Control = $ShopPanel
		_info_panel.position.y = shop.position.y + shop.size.y + 6.0
	if _hero_panel.visible:
		_refresh_hero()  # cooldown seconds change every tick; reading state only


## Winter HUD skin (Dev 12, A-01 tokens): navy panels, spruce-blue buttons, gold pressed/hover accent.
func _apply_theme() -> void:
	var theme: Theme = Theme.new()
	var panel: StyleBoxFlat = _box(Color(0.09, 0.21, 0.28, 0.9), Color(0.56, 0.85, 0.91, 0.35))
	theme.set_stylebox(&"panel", &"PanelContainer", panel)
	theme.set_stylebox(&"panel", &"Panel", panel)
	for pair: Array in [[&"normal", Color("20517a")], [&"hover", Color("2b6a9c")], [&"pressed", Color("b98a3a")],
			[&"disabled", Color(0.09, 0.21, 0.28, 0.75)], [&"focus", Color(0, 0, 0, 0)]]:
		var b: StyleBoxFlat = _box(pair[1], Color(0.976, 0.788, 0.427, 0.9) if pair[0] == &"focus" else Color(0, 0, 0, 0))
		if pair[0] == &"focus":
			b.draw_center = false
		theme.set_stylebox(pair[0], &"Button", b)
	theme.set_color(&"font_color", &"Button", Color("eef6fa"))
	theme.set_color(&"font_hover_color", &"Button", Color.WHITE)
	theme.set_color(&"font_pressed_color", &"Button", Color.WHITE)
	theme.set_color(&"font_disabled_color", &"Button", Color(0.75, 0.8, 0.85, 0.55))
	theme.set_color(&"font_color", &"Label", Color("eef6fa"))
	for c: Node in get_children():
		if c is Control and c != feedback:
			(c as Control).theme = theme


func _box(color: Color, border: Color) -> StyleBoxFlat:
	var b: StyleBoxFlat = StyleBoxFlat.new()
	b.bg_color = color
	b.set_corner_radius_all(6)
	b.set_content_margin_all(3)
	b.content_margin_left = 10
	b.content_margin_right = 10
	if border.a > 0.0:
		b.set_border_width_all(1)
		b.border_color = border
	return b


func _build_intro_panel() -> void:
	add_child(_intro_panel)
	_intro_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_intro_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_intro_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_intro_panel.custom_minimum_size = Vector2(460, 0)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 10)
	_intro_panel.add_child(box)
	_intro_title.add_theme_font_size_override(&"font_size", 26)
	_intro_title.add_theme_color_override(&"font_color", Color("f9c96d"))
	_intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_text.custom_minimum_size.x = 440
	_intro_continue.focus_mode = Control.FOCUS_NONE  # Space reaches the match, which acknowledges exactly once
	_intro_continue.pressed.connect(func() -> void: match_node.acknowledge_intro())
	for c: Control in [_intro_title, _intro_text, _intro_continue]:
		box.add_child(c)
	_intro_panel.visible = false


func _build_hero_panel() -> void:
	add_child(_hero_panel)
	_hero_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_hero_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hero_panel.offset_left = 12.0
	_hero_panel.offset_bottom = -42.0
	_hero_panel.custom_minimum_size.x = 280.0
	var box: VBoxContainer = VBoxContainer.new()
	_hero_panel.add_child(box)
	_hero_xp.show_percentage = false
	_hero_xp.custom_minimum_size.y = 10.0
	for c: Control in [_hero_text, _hero_xp, _frenzy, _focus]:
		box.add_child(c)
	for b: Button in [_frenzy, _focus]:
		b.focus_mode = Control.FOCUS_NONE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_frenzy.pressed.connect(match_node.use_frenzy)
	_focus.pressed.connect(match_node.toggle_focus)
	_hero_panel.visible = false


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
		lines.append("%s  Lv %d   XP %d / %d" % [def.display_name, hero.level, hero.xp, hi])
		lines.append("Next: %s" % def.level_changes[hero.level].get("summary", ""))
	else:
		_hero_xp.value = _hero_xp.max_value
		lines.append("%s  Lv %d (max)" % [def.display_name, hero.level])
	_hero_panel.tooltip_text = "Camel Claus earns XP at the end of every round and levels up on his own."
	_hero_text.text = "
".join(lines)
	var over: bool = match_node.is_over()
	match match_node.frenzy_state():
		"locked":
			_frenzy.text = "Snowball Frenzy (Q) - unlocks at level %d" % _unlock_level(def, "snowball_frenzy")
		"active":
			_frenzy.text = "Snowball Frenzy - active %.1f s" % hero.frenzy_left
		"cooldown":
			_frenzy.text = "Snowball Frenzy - recharging %d s (during rounds)" % ceili(hero.frenzy_cooldown_left)
		_:
			_frenzy.text = "Snowball Frenzy (Q) - READY: 3x attack speed"
	_frenzy.disabled = over or match_node.clock.paused or match_node.frenzy_state() != "ready"
	if hero.has_unlock("focused_shot"):
		_focus.text = "Focused Shot (E): %s" % ("ON - slower, faster shots, more range" if hero.focus else "off")
	else:
		_focus.text = "Focused Shot (E) - unlocks at level %d" % _unlock_level(def, "focused_shot")
	_focus.disabled = over or not hero.has_unlock("focused_shot")


func _unlock_level(def: HeroDefinition, what: String) -> int:
	for i: int in def.level_changes.size():
		if what in [def.level_changes[i].get("unlock_ability", ""), def.level_changes[i].get("unlock_stance", "")]:
			return i + 1
	return 0


func _refresh() -> void:
	var m: Node3D = match_node
	var over: bool = m.is_over()
	var state_name: String = m.State.keys()[m.state]
	var phase: String = {"PREPARE": "Build phase", "ROUND_SPAWN": "Wave incoming", "ROUND_CLEANUP": "Clearing wave",
			"ROUND_REWARD": "Wave cleared", "WON": "Victory", "LOST": "Defeat"}.get(state_name, state_name.capitalize())
	_stats.text = "Lives %d    Cash $%d    Round %d / %d    %s" % [m.lives, m.ledger.cash,
			maxi(m.round_index + 1, 1) if m.state != m.State.PREPARE else m.round_index + 2, Content.rounds.size(), phase]
	for i: int in _shop_buttons.size():
		var def: TowerDefinition = m.shop[i]
		var text: String = "%d  %s  $%d" % [i + 1, def.display_name, def.price]
		if def is HeroDefinition and m.hero_node() != null:
			text = "%d  %s  (on the course)" % [i + 1, def.display_name]
		elif m.ledger.cash < def.price:
			text += "  need $%d" % (def.price - m.ledger.cash)
		_shop_buttons[i].text = text
		_shop_buttons[i].disabled = over or m.ledger.cash < def.price or (def is HeroDefinition and m.hero_node() != null)
	_start.disabled = not m.can_start_round()
	if over:
		_start.text = "Match over"
	elif m.clock.paused:
		_start.text = "Paused (P to resume)"
	elif m.intro != &"":
		_start.text = "Read the notice (Space)"
	elif m.state != m.State.PREPARE:
		_start.text = "Round in progress"
	else:
		_start.text = "Start round %d (Space)" % (m.round_index + 2)
	_pause.disabled = over
	_pause.text = "Resume (P)" if m.clock.paused else "Pause (P)"
	_speed.text = "Speed %dx (F)" % m.clock.speed
	_refresh_info()
	_refresh_hero()
	_intro_panel.visible = m.intro != &"" and not over
	if _intro_panel.visible:
		var info: Array = m.INTROS[m.intro]
		_intro_title.text = "New in round %d: %s" % [m.round_index + 2, info[0]]
		_intro_text.text = info[1]
		_intro_continue.text = "Continue - start round %d (Space)" % (m.round_index + 2)
		_intro_continue.disabled = m.clock.paused
	_overlay.visible = over or m.clock.paused
	_resume.visible = not over
	if m.state == m.State.WON:
		_overlay_title.text = "Victory! The finish line held for all %d rounds." % Content.rounds.size()
	elif m.state == m.State.LOST:
		_overlay_title.text = "Defeat — the snowballs broke through in round %d." % (m.round_index + 1)
	else:
		_overlay_title.text = "Paused"


## Selected tower card (P04-T04) with one upgrade button per path (P09-T10).
func _refresh_info() -> void:
	var tower: Node3D = match_node.selected
	_info_panel.visible = is_instance_valid(tower)
	if not _info_panel.visible:
		return
	var def: TowerDefinition = tower.def
	var is_hero: bool = def is HeroDefinition
	var lines: PackedStringArray = ["%s  %d-%d-%d" % [def.display_name, tower.tiers.x, tower.tiers.y, tower.tiers.z]]
	if is_hero:
		lines = ["%s  Level %d" % [def.display_name, tower.level], "Hero: levels up from rounds, no upgrades"]
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
				button.text = "%s  locked: only one path past tier 2" % head if tower.tiers[path] >= 2 						else "%s  locked: only two paths per defender" % head
			"soon":
				button.text = "%s  %s - coming soon" % [head, next.display_name]
			"unaffordable":
				button.text = "%s  > %s  $%d (need $%d)" % [head, next.display_name, next.price, next.price - match_node.ledger.cash]
			_:
				button.text = "%s  > %s  $%d" % [head, next.display_name, next.price]
		button.tooltip_text = "" if next == null else "%s  $%d
%s" % [next.display_name, next.price, _effects_text(next, def)]
		button.disabled = state != "ok" or match_node.is_over()
	_info_text.text = "\n".join(lines)
	_sell.text = "Sell for $%d" % match_node.sell_value(tower)
	_sell.disabled = match_node.is_over()


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
