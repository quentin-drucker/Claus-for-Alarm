class_name LodgeTheme
extends RefCounted
## Dev 13 "Christmas ski lodge" UI theme, shared by the match HUD and the title screen so every screen agrees:
## dark timber frames, navy/spruce interiors, cream text, festive-red primary actions, gold highlights.
## Type variations: LodgeInset (inner section), CardButton (shop card), PrimaryButton (red main action),
## TopBar (compact stat strip), Heading / Small / Price / Muted labels.

const TIMBER: Color = Color("4a2e1d")
const TIMBER_LIGHT: Color = Color("8a5a37")
const TIMBER_DARK: Color = Color("2a1a10")
const NAVY: Color = Color("132b3a")
const SPRUCE: Color = Color("1d4048")
const INSET: Color = Color("0e2130")
const CREAM: Color = Color("f6ead2")
const MUTED: Color = Color("b9c4c9")
const RED: Color = Color("c4363f")
const RED_HI: Color = Color("dc4c50")
const RED_LO: Color = Color("932630")
const GOLD: Color = Color("f2c14e")
const BRASS: Color = Color("c99a4a")
const SNOW: Color = Color("f4f8fb")
const BAD: Color = Color("ff8a7a")

static var _theme: Theme
static var _reduced: int = -1


## The one shared Theme (built once).
static func get_theme() -> Theme:
	if _theme == null:
		_theme = _build()
	return _theme


## prefers-reduced-motion in the browser; false elsewhere (Godot has no desktop query).
static func reduced_motion() -> bool:
	if _reduced < 0:
		_reduced = 0
		if OS.has_feature("web"):
			_reduced = 1 if JavaScriptBridge.eval("window.matchMedia('(prefers-reduced-motion: reduce)').matches", true) else 0
	return _reduced == 1


static func box(bg: Color, border: Color = Color(0, 0, 0, 0), width: int = 0, radius: int = 6) -> StyleBoxFlat:
	var b: StyleBoxFlat = StyleBoxFlat.new()
	b.bg_color = bg
	b.set_corner_radius_all(radius)
	b.set_content_margin_all(6)
	b.content_margin_left = 10
	b.content_margin_right = 10
	if width > 0:
		b.set_border_width_all(width)
		b.border_color = border
	return b


## Chunky bevelled button face: lighter top edge, heavy dark bottom edge (pressed: the bevel flips = compression).
static func _face(bg: Color, edge: Color, pressed: bool = false, outline: Color = Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var b: StyleBoxFlat = box(bg, edge, 0, 5)
	b.border_color = edge
	b.border_width_bottom = 1 if pressed else 4
	b.border_width_top = 3 if pressed else 1
	if outline.a > 0.0:
		b.border_width_left = 2
		b.border_width_right = 2
		b.border_width_top = maxi(b.border_width_top, 2)
		b.border_color = outline
	b.content_margin_top = 5 + (2 if pressed else 0)
	b.content_margin_bottom = 5
	return b


static func _build() -> Theme:
	var t: Theme = Theme.new()
	t.default_font_size = 15
	var frame: StyleBoxFlat = box(NAVY, TIMBER, 6, 7)
	frame.set_content_margin_all(12)
	frame.shadow_color = Color(0, 0, 0, 0.35)
	frame.shadow_size = 6
	t.set_stylebox(&"panel", &"PanelContainer", frame)
	t.set_stylebox(&"panel", &"Panel", frame)
	t.set_type_variation(&"LodgeInset", &"PanelContainer")
	var inset: StyleBoxFlat = box(INSET, Color("2c4f60"), 1, 5)
	inset.set_content_margin_all(8)
	t.set_stylebox(&"panel", &"LodgeInset", inset)
	t.set_type_variation(&"TopBar", &"PanelContainer")
	var bar: StyleBoxFlat = box(Color(NAVY, 0.92), TIMBER, 3, 6)
	bar.content_margin_top = 4
	bar.content_margin_bottom = 4
	bar.content_margin_left = 14
	bar.content_margin_right = 14
	t.set_stylebox(&"panel", &"TopBar", bar)

	# Buttons: spruce face, gold outline on hover, compressed when pressed.
	t.set_stylebox(&"normal", &"Button", _face(SPRUCE, Color("0b1d24")))
	t.set_stylebox(&"hover", &"Button", _face(Color("265560"), Color("0b1d24"), false, GOLD))
	t.set_stylebox(&"pressed", &"Button", _face(Color("17343b"), Color("0b1d24"), true, GOLD))
	t.set_stylebox(&"disabled", &"Button", _face(Color(SPRUCE.darkened(0.35), 0.85), Color("0b1d24")))
	var focus: StyleBoxFlat = box(Color(0, 0, 0, 0), GOLD, 2, 5)
	focus.draw_center = false
	t.set_stylebox(&"focus", &"Button", focus)
	t.set_color(&"font_color", &"Button", CREAM)
	t.set_color(&"font_hover_color", &"Button", Color.WHITE)
	t.set_color(&"font_pressed_color", &"Button", GOLD)
	t.set_color(&"font_focus_color", &"Button", CREAM)
	t.set_color(&"font_disabled_color", &"Button", Color(MUTED, 0.6))

	# Festive-red primary action.
	t.set_type_variation(&"PrimaryButton", &"Button")
	t.set_stylebox(&"normal", &"PrimaryButton", _face(RED, RED_LO.darkened(0.3)))
	t.set_stylebox(&"hover", &"PrimaryButton", _face(RED_HI, RED_LO.darkened(0.3), false, GOLD))
	t.set_stylebox(&"pressed", &"PrimaryButton", _face(RED_LO, RED_LO.darkened(0.4), true, GOLD))
	t.set_stylebox(&"disabled", &"PrimaryButton", _face(Color("5a3036"), Color("2a1418")))
	t.set_font_size(&"font_size", &"PrimaryButton", 17)

	# Shop card: inset face, gold outline on hover / selected.
	t.set_type_variation(&"CardButton", &"Button")
	var card: StyleBoxFlat = _face(Color("183746"), Color("091820"))
	card.set_content_margin_all(4)
	t.set_stylebox(&"normal", &"CardButton", card)
	var card_hover: StyleBoxFlat = _face(Color("214a5a"), Color("091820"), false, GOLD)
	card_hover.set_content_margin_all(4)
	t.set_stylebox(&"hover", &"CardButton", card_hover)
	var card_down: StyleBoxFlat = _face(Color("12303c"), Color("091820"), true, GOLD)
	card_down.set_content_margin_all(4)
	t.set_stylebox(&"pressed", &"CardButton", card_down)
	var card_off: StyleBoxFlat = _face(Color("10232d"), Color("08141a"))
	card_off.set_content_margin_all(4)
	t.set_stylebox(&"disabled", &"CardButton", card_off)

	# Labels.
	t.set_color(&"font_color", &"Label", CREAM)
	t.set_color(&"font_shadow_color", &"Label", Color(0, 0, 0, 0.45))
	t.set_constant(&"shadow_offset_y", &"Label", 1)
	t.set_type_variation(&"Heading", &"Label")
	t.set_color(&"font_color", &"Heading", GOLD)
	t.set_font_size(&"font_size", &"Heading", 18)
	t.set_type_variation(&"Small", &"Label")
	t.set_font_size(&"font_size", &"Small", 13)
	t.set_type_variation(&"Muted", &"Label")
	t.set_color(&"font_color", &"Muted", MUTED)
	t.set_font_size(&"font_size", &"Muted", 13)
	t.set_type_variation(&"Price", &"Label")
	t.set_color(&"font_color", &"Price", GOLD)
	t.set_font_size(&"font_size", &"Price", 15)

	# Tooltips, bars, sliders, scroll.
	var tip: StyleBoxFlat = box(Color(INSET, 0.97), BRASS, 1, 5)
	tip.set_content_margin_all(8)
	t.set_stylebox(&"panel", &"TooltipPanel", tip)
	t.set_color(&"font_color", &"TooltipLabel", CREAM)
	t.set_font_size(&"font_size", &"TooltipLabel", 14)
	t.set_stylebox(&"background", &"ProgressBar", box(INSET, TIMBER_DARK, 1, 3))
	t.set_stylebox(&"fill", &"ProgressBar", box(GOLD, Color(0, 0, 0, 0), 0, 3))
	var rail: StyleBoxFlat = box(INSET, TIMBER_DARK, 1, 4)
	rail.content_margin_top = 4
	rail.content_margin_bottom = 4
	t.set_stylebox(&"slider", &"HSlider", rail)
	var fill: StyleBoxFlat = box(RED, Color(0, 0, 0, 0), 0, 4)
	fill.content_margin_top = 4
	fill.content_margin_bottom = 4
	t.set_stylebox(&"grabber_area", &"HSlider", fill)
	t.set_stylebox(&"grabber_area_highlight", &"HSlider", fill)
	t.set_stylebox(&"panel", &"ScrollContainer", StyleBoxEmpty.new())
	return t


## Brief hover lift, pressed compression (input stays immediate: purely visual scale on the pivot).
static func juice(c: Control, lift: float = 1.04) -> void:
	if reduced_motion():
		return
	var to: Callable = func(s: float) -> void:
		var tw: Tween = c.create_tween()
		tw.tween_property(c, ^"scale", Vector2.ONE * s, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	c.resized.connect(func() -> void: c.pivot_offset = c.size / 2.0)
	c.mouse_entered.connect(func() -> void: to.call(lift))
	c.mouse_exited.connect(func() -> void: to.call(1.0))
	if c is BaseButton:
		(c as BaseButton).button_down.connect(func() -> void: to.call(0.96))
		(c as BaseButton).button_up.connect(func() -> void: to.call(lift if c.get_global_rect().has_point(c.get_global_mouse_position()) else 1.0))
