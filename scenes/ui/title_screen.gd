extends Control
## Title screen (P13-T01): Play, a one-screen How to Play, Settings (Music/SFX volume on their audio buses,
## P13-T10). Plain default-theme placeholder: the visual skin is the owner's call (P17).

const MATCH: String = "res://scenes/main/match.tscn"
const SETTINGS_PATH: String = "user://settings.cfg"
const BUSES: PackedStringArray = ["Music", "SFX"]

@onready var _menu: Control = %Menu
@onready var _how: Control = %HowPanel
@onready var _settings: Control = %SettingsPanel
@onready var _sliders: Array[HSlider] = [%MusicSlider, %SfxSlider]


func _ready() -> void:
	%PlayButton.pressed.connect(get_tree().change_scene_to_file.bind(MATCH))
	%HowButton.pressed.connect(_show.bind(_how))
	%SettingsButton.pressed.connect(_show.bind(_settings))
	%HowBack.pressed.connect(_show.bind(_menu))
	%SettingsBack.pressed.connect(_show.bind(_menu))
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)  # missing file (first run, private window) = defaults
	for i: int in BUSES.size():
		_sliders[i].value = config.get_value("audio", BUSES[i], 1.0)
		_set_volume(BUSES[i], _sliders[i].value)
		_sliders[i].value_changed.connect(_on_volume_changed.bind(BUSES[i]))
	_show(_menu)


func _show(panel: Control) -> void:
	for p: Control in [_menu, _how, _settings]:
		p.visible = p == panel


func _on_volume_changed(value: float, bus: String) -> void:
	_set_volume(bus, value)
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", bus, value)
	config.save(SETTINGS_PATH)


## Linear 0..1 slider -> bus volume in dB; 0 mutes.
static func _set_volume(bus: String, linear: float) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index < 0:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.0)
