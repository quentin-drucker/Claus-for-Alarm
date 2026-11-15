extends CanvasLayer
## Autoload "ScreenFinish": faint vignette + bottom-corner powder over the whole game (DEC-049).
## Layer 1100 sits above every game CanvasLayer (max 100) and the root viewport's embedded-popup canvas (1024).
## Never takes input. F8 toggles it OFF / ON for owner comparison. (Universal pixel pass removed by the owner.)

const SHADER: Shader = preload("res://assets/materials/screen_finish.gdshader")

@export var enabled: bool = true:
	set(value):
		enabled = value
		visible = value
@export_range(0.0, 1.0, 0.01) var vignette_strength: float = 0.08:
	set(value):
		vignette_strength = value
		_push()
@export_range(0.0, 1.0, 0.01) var snow_opacity: float = 0.6:
	set(value):
		snow_opacity = value
		_push()

var _material: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	layer = 1100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_material.shader = SHADER
	var rect: ColorRect = ColorRect.new()
	rect.name = "Finish"
	rect.material = _material
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.focus_mode = Control.FOCUS_NONE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	_push()
	visible = enabled


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and not key.echo and key.keycode == KEY_F8:
		enabled = not enabled
		print("SCREEN_FINISH ", "ON" if enabled else "OFF")
		get_viewport().set_input_as_handled()


func _push() -> void:
	_material.set_shader_parameter(&"vignette_strength", vignette_strength)
	_material.set_shader_parameter(&"snow_opacity", snow_opacity)
