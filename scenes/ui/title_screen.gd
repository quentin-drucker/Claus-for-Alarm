extends Control
## Title screen (P13-T01): Play, a one-screen How to Play, Settings (Music / SFX / Tower SFX / Ambience volume on
## their audio buses, P13-T10, P18-T05). Animated Christmas-village backdrop (owner, P17 menu slice).
## Environment attribution: CREDITS.md; owner places public credits on the game website.

const MATCH: String = "res://scenes/main/match.tscn"
const SETTINGS_PATH: String = "user://settings.cfg"
const BUSES: PackedStringArray = ["Music", "SFX", "Towers", "Ambience"]
## Slider value on first run (no saved settings).
const DEFAULTS: Dictionary[String, float] = {"Music": 1.0, "SFX": 1.0, "Towers": 0.5, "Ambience": 1.0}
## Slider -> bus gain multiplier: Towers sits at 50% by default with headroom, so 0.5 = 0 dB and 1.0 = +6 dB.
const GAIN: Dictionary[String, float] = {"Towers": 2.0}

@onready var _menu: Control = %Menu
@onready var _how: Control = %HowPanel
@onready var _settings: Control = %SettingsPanel
@onready var _sliders: Array[HSlider] = [%MusicSlider, %SfxSlider, %TowerSlider, %AmbienceSlider]


func _ready() -> void:
	_style_menu()
	%PlayButton.pressed.connect(get_tree().change_scene_to_file.bind(MATCH))
	%HowButton.pressed.connect(_show.bind(_how))
	%SettingsButton.pressed.connect(_show.bind(_settings))
	%HowBack.pressed.connect(_show.bind(_menu))
	%SettingsBack.pressed.connect(_show.bind(_menu))
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)  # missing file (first run, private window) = defaults
	for i: int in BUSES.size():
		_sliders[i].value = config.get_value("audio", BUSES[i], DEFAULTS[BUSES[i]])
		_set_volume(BUSES[i], _sliders[i].value)
		_sliders[i].value_changed.connect(_on_volume_changed.bind(BUSES[i]))
	_show(_menu)
	resized.connect(_fit_menu)
	_fit_menu()


func _fit_menu() -> void:
	# Side menu leaves the central tree visible; narrow windows keep the menu usable.
	$MenuSide.anchor_right = 0.44 if size.x >= 900.0 else 1.0


func _style_menu() -> void:
	_menu.add_theme_constant_override("separation", 10)
	for overlay: PanelContainer in [_how, _settings]:
		var panel: StyleBoxFlat = StyleBoxFlat.new()
		panel.bg_color = Color(0.025, 0.065, 0.09, 0.97)
		panel.set_corner_radius_all(6)
		overlay.add_theme_stylebox_override("panel", panel)
	for button: Button in [%PlayButton, %HowButton, %SettingsButton]:
		button.custom_minimum_size.y = 44
		button.add_theme_font_size_override("font_size", 20)
		for state: String in ["normal", "hover", "pressed", "focus"]:
			var panel: StyleBoxFlat = StyleBoxFlat.new()
			panel.bg_color = Color(0.035, 0.09, 0.13, 0.86) if state == "normal" else Color(0.09, 0.23, 0.29, 0.94)
			panel.border_color = Color("e8c586")
			panel.set_border_width_all(1 if state == "normal" else 2)
			panel.set_corner_radius_all(7)
			panel.content_margin_left = 18
			panel.content_margin_right = 18
			button.add_theme_stylebox_override(state, panel)


func _show(panel: Control) -> void:
	$Background.color.a = 0.12 if panel == _menu else 0.45
	for p: Control in [_menu, _how, _settings]:
		p.visible = p == panel


func _on_volume_changed(value: float, bus: String) -> void:
	_set_volume(bus, value)
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", bus, value)
	config.save(SETTINGS_PATH)


## Linear 0..1 slider (times the bus's GAIN) -> bus volume in dB; 0 mutes.
static func _set_volume(bus: String, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear * GAIN.get(bus, 1.0), 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.0)
