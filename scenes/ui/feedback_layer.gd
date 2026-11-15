extends Control
## Placeholder feedback (P13-T06): plain floating text and a banner for gameplay events. Presentation only: it
## listens to Events and never touches the simulation. ponytail: text stand-ins until the owner's VFX/SFX pass
## (P17/P18) replaces them here; a hard cap keeps 4x late rounds cheap (caps visuals, never combat events).

const MAX_FLOATERS: int = 60
## Hit markers are the most frequent; they stop first when the screen is busy.
const MAX_HIT_FLOATERS: int = 30
const HIT: Color = Color("ffffff")
const IMMUNE: Color = Color("c8c8c8")
const LEAK: Color = Color("ff5a5a")
const INCOME: Color = Color("f9c96d")

var camera: Camera3D
## Flashes red when a snowball leaks (the HUD's lives/cash line).
var flash_target: Control
var _banner: Label = Label.new()
var _floaters: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.offset_top = 56.0
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override(&"font_size", 28)
	_banner.add_theme_constant_override(&"outline_size", 8)
	_banner.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_banner.modulate.a = 0.0
	add_child(_banner)
	Events.emitted.connect(_on_event)


func _on_event(e: GameEvent) -> void:
	match e.type:
		&"enemy_hit":
			_float("*", e.position, HIT, 0.25, MAX_HIT_FLOATERS)
		&"enemy_immune":
			_float("IMMUNE", e.position, IMMUNE, 0.7)
		&"enemy_leaked":
			_float("-%d lives" % e.magnitude, e.position, LEAK, 1.2)
			if flash_target:
				flash_target.modulate = LEAK
				create_tween().tween_property(flash_target, ^"modulate", Color.WHITE, 0.6)
		&"income_collected", &"income_banked":
			_float("+$%d" % e.magnitude, e.position, INCOME, 1.0)
		&"ability_used":
			if "snowball_frenzy" in e.tags:
				banner("SNOWBALL FRENZY!")
			elif "focused_shot" in e.tags:
				banner("Focused Shot %s" % ("ON" if e.magnitude > 0.0 else "off"))
		&"tower_placed", &"tower_upgraded":
			_float("-$%d" % e.magnitude, e.position, INCOME, 0.9)
		&"purchase_failed":
			_float(e.tags[0] if e.tags.size() > 0 else "Can't buy", e.position, LEAK, 1.0)
		&"hero_level_up":
			_float("Level %d!" % e.magnitude, e.position, INCOME, 1.5)
		&"round_started":
			banner("Round %d" % e.magnitude)
		&"round_complete":
			banner("Round %s complete   +$%d bonus" % [e.tags[0], e.magnitude])


## Centre-top message that fades out.
func banner(text: String) -> void:
	_banner.text = text
	_banner.modulate.a = 1.0
	var tween: Tween = _banner.create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(_banner, ^"modulate:a", 0.0, 0.5)


## Text at a world position that rises and fades. Skipped when `cap` floaters are already showing.
func _float(text: String, world: Vector3, color: Color, seconds: float, cap: int = MAX_FLOATERS) -> void:
	if camera == null or _floaters >= cap or camera.is_position_behind(world):
		return
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_constant_override(&"outline_size", 6)
	label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = camera.unproject_position(world + Vector3.UP * 0.8) - Vector2(8.0, 12.0)
	add_child(label)
	_floaters += 1
	var tween: Tween = label.create_tween().set_parallel()
	tween.tween_property(label, ^"position:y", label.position.y - 30.0, seconds)
	tween.tween_property(label, ^"modulate:a", 0.0, seconds)
	tween.chain().tween_callback(func() -> void:
		_floaters -= 1
		label.queue_free())
