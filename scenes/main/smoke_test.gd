extends Node3D
## P01 infrastructure smoke test: proves editor + Web boot, input, resize/fullscreen and the
## browser audio gesture unlock. Disposable; replaced by the real match scene from P03/P04.

@onready var _status: Label = $UI/Status
@onready var _blip: AudioStreamPlayer = $Blip

var _last_input: String = "none"
var _blips: int = 0


func _ready() -> void:
	print("SMOKE_READY renderer=%s web=%s" % [
		RenderingServer.get_current_rendering_method(), OS.has_feature("web")])


func _process(_delta: float) -> void:
	_status.text = "PLAY TEST\nFPS %d | window %s | %s\nlast input: %s | blips: %d\nclick / any key = blip    F = fullscreen" % [
		Engine.get_frames_per_second(), get_viewport().get_visible_rect().size,
		DisplayServer.window_get_mode(), _last_input, _blips]


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if not (key or event is InputEventMouseButton) or not event.is_pressed() or event.is_echo():
		return
	_last_input = event.as_text()
	# The first click/key is the user gesture browsers require before audio may play.
	_blip.play()
	_blips += 1
	print("SMOKE_INPUT %s" % _last_input)
	if key and key.keycode == KEY_F:
		var full: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
