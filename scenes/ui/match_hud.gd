extends CanvasLayer
## Placeholder match HUD (P04). Reads match state and calls match controls; it never changes rules itself.
## Refreshes on `match.changed` (event-driven), except the dev-only debug overlay which updates per frame.

const PATH_NAMES: PackedStringArray = ["Top", "Middle", "Bottom"]
const PRIORITY_NAMES: PackedStringArray = ["First", "Last", "Close", "Strong"]  # Targeting.Priority order

var match_node: Node3D
var _shop_buttons: Array[Button] = []

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
		_shop.add_child(button)
		_shop_buttons.append(button)
	_start.pressed.connect(match_node.start_round)
	_pause.pressed.connect(func() -> void: match_node.set_paused(not match_node.clock.paused))
	_speed.pressed.connect(match_node.toggle_speed)
	_sell.pressed.connect(func() -> void: match_node.sell(match_node.selected))
	_target.pressed.connect(func() -> void: match_node.cycle_priority(match_node.selected))
	_resume.pressed.connect(match_node.set_paused.bind(false))
	_restart.pressed.connect(match_node.restart)
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


func _refresh() -> void:
	var m: Node3D = match_node
	var over: bool = m.is_over()
	var state_name: String = m.State.keys()[m.state]
	_stats.text = "Lives %d    Cash $%d    Round %d / %d    %s" % [m.lives, m.ledger.cash,
			m.round_index + 1, Content.rounds.size(), state_name.capitalize()]
	for i: int in _shop_buttons.size():
		_shop_buttons[i].disabled = over or m.ledger.cash < m.shop[i].price
	_start.disabled = not m.can_start_round()
	_pause.disabled = over
	_pause.text = "Resume (P)" if m.clock.paused else "Pause (P)"
	_speed.text = "Speed %sx (F)" % m.clock.speed
	_refresh_info()
	_overlay.visible = over or m.clock.paused
	_resume.visible = not over
	if m.state == m.State.WON:
		_overlay_title.text = "Victory! The finish line held for all %d rounds." % Content.rounds.size()
	elif m.state == m.State.LOST:
		_overlay_title.text = "Defeat — the snowballs broke through in round %d." % (m.round_index + 1)
	else:
		_overlay_title.text = "Paused"


## Selected tower card (P04-T04). Upgrade purchase arrives in P09; slots show the next tier from data.
func _refresh_info() -> void:
	var tower: Node3D = match_node.selected
	_info_panel.visible = is_instance_valid(tower)
	if not _info_panel.visible:
		return
	var def: TowerDefinition = tower.def
	var lines: PackedStringArray = [def.display_name]
	if def.global_range:
		lines.append("Range: whole map (line of sight)")
	elif def.range_units > 0.0:
		lines.append("Range: %s (%.1f m)" % [def.range_units, def.range_units * GameDefinition.UNIT_M])
	_target.visible = not def.attacks.is_empty()
	_target.text = "Target: %s (T)" % PRIORITY_NAMES[tower.priority]
	if def.attacks.is_empty():
		lines.append("Income building")
	lines.append("Invested $%d" % tower.spent)
	lines.append("Upgrades %d-%d-%d (coming soon):" % [tower.tiers.x, tower.tiers.y, tower.tiers.z])
	for path: int in 3:
		var next: UpgradeDefinition = def.get_upgrade(path, tower.tiers[path] + 1)
		var locked: String = "" if def.can_upgrade(tower.tiers, path) else " — locked"
		lines.append("  %s: %s $%d%s" % [PATH_NAMES[path], next.display_name, next.price, locked] if next
				else "  %s: final tier" % PATH_NAMES[path])
	_info_text.text = "\n".join(lines)
	_sell.text = "Sell for $%d" % match_node.sell_value(tower)
	_sell.disabled = match_node.is_over()


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
