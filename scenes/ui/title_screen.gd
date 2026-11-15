extends Control
## Title screen (P13-T01): Play, a one-screen How to Play, Settings (Music / SFX / Tower SFX / Ambience volume on
## their audio buses, P13-T10, P18-T05). Animated Christmas-village backdrop (owner, P17 menu slice).
## Environment attribution: CREDITS.md; owner places public credits on the game website.

const MATCH: String = "res://scenes/main/match.tscn"
const LODGE := preload("res://scripts/ui/lodge_theme.gd")
const MAP_LOADING := preload("res://scripts/ui/map_loading.gd")
var _opening_match: bool = false
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
	%PlayButton.pressed.connect(_open_match)
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
	_finish_web_loading.call_deferred()


func _finish_web_loading() -> void:
	if not OS.has_feature("web"):
		return
	# Keep the HTML sweater loader over download, engine startup and first village draw.
	await RenderingServer.frame_post_draw
	JavaScriptBridge.eval("if (typeof window.clausMenuReady === 'function') window.clausMenuReady();")


func _fit_menu() -> void:
	# Side menu leaves the central tree visible; narrow windows keep the menu usable.
	$MenuSide.anchor_right = 0.44 if size.x >= 900.0 else 1.0
	$RookieShowcase.visible = size.x >= 900.0 and _menu.visible


func _open_match() -> void:
	if _opening_match:
		return
	_opening_match = true
	%PlayButton.disabled = true
	var loader: CanvasLayer = MAP_LOADING.new()
	loader.name = "MapLoading"
	loader.destination = MATCH
	get_tree().root.add_child(loader)


## Dev 13: the shared ski-lodge theme (timber-framed panels, red primary Play, cream text) over the 3D backdrop.
func _style_menu() -> void:
	theme = LODGE.get_theme()
	$MenuSide/Menu/Title.theme_type_variation = &"GameTitle"
	$MenuSide/Menu/Title.remove_theme_font_size_override("font_size")
	$MenuSide/Menu/Subtitle.theme_type_variation = &"Subtitle"
	_menu.add_theme_constant_override("separation", 10)
	%PlayButton.theme_type_variation = &"PrimaryButton"
	for title: Label in [$Center/HowPanel/Box/HowTitle, $Center/SettingsPanel/Box/SettingsTitle]:
		title.theme_type_variation = &"Heading"
	for button: Button in [%PlayButton, %HowButton, %SettingsButton, %HowBack, %SettingsBack]:
		button.custom_minimum_size.y = 44
		button.add_theme_font_size_override("font_size", 20)
		LODGE.juice(button, 1.03)


func _show(panel: Control) -> void:
	$Background.color.a = 0.12 if panel == _menu else 0.45
	for p: Control in [_menu, _how, _settings]:
		p.visible = p == panel
	_fit_menu()


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
