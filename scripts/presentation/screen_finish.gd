extends CanvasLayer
## Autoload "ScreenFinish": one final full-screen pass over the composed game (DEC-049).
## Layer 1100 sits above every game CanvasLayer (max 100) and the root viewport's embedded-popup canvas (1024),
## so tooltips and popups are treated too. Never takes input. F8 toggles OFF / SUBTLE for owner comparison.

const SHADER: Shader = preload("res://assets/materials/screen_finish.gdshader")

@export var enabled: bool = true:
	set(value):
		enabled = value
		visible = value
## Cell size in base-UI pixels (1152x648); scaled to the window like the UI and snapped to whole physical
## pixels, so the finish keeps the same weight relative to text at any window size, browser zoom or DPI.
@export_range(1.0, 8.0, 0.5) var pixel_cell_size: float = 3.0:
	set(value):
		pixel_cell_size = value
		_push()
@export_range(0.0, 1.0, 0.01) var pixel_blend: float = 0.3:
	set(value):
		pixel_blend = value
		_push()
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
	get_tree().root.size_changed.connect(_push)
	_push()
	visible = enabled


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key and key.pressed and not key.echo and key.keycode == KEY_F8:
		enabled = not enabled
		print("SCREEN_FINISH ", "SUBTLE" if enabled else "OFF")
		get_viewport().set_input_as_handled()


func _push() -> void:
	_material.set_shader_parameter(&"cell_size", physical_cell_size())
	_material.set_shader_parameter(&"pixel_blend", pixel_blend)
	_material.set_shader_parameter(&"vignette_strength", vignette_strength)
	_material.set_shader_parameter(&"snow_opacity", snow_opacity)


func physical_cell_size() -> float:
	if not is_inside_tree():
		return pixel_cell_size
	return cell_for(pixel_cell_size, Vector2(get_tree().root.size), Vector2(get_tree().root.content_scale_size))


static func cell_for(base_cell: float, window: Vector2, base: Vector2) -> float:
	var ui_scale: float = minf(window.x / base.x, window.y / base.y) if base.x > 0.0 and base.y > 0.0 else 1.0
	return maxf(1.0, roundf(base_cell * ui_scale))
