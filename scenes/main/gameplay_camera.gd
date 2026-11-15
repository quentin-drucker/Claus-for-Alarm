extends Camera3D
## Orbit the same ground focus without changing map geometry. 60 degrees reproduces the previous pitch; 50 is the
## owner's more side-on trial. Dev 13: fit() sizes the orthographic view so the whole route (entry to exit) sits in
## the playfield left of the HUD sidebar; h_offset shifts the view, and project_ray_*/unproject_position include it,
## so picking, placement ghosts, range rings, ticket hover and floaters keep matching the cursor.

@export_range(35.0, 80.0, 1.0) var elevation_degrees: float = 50.0
@export var focus_point: Vector3 = Vector3(0.0, 0.0, -0.047005)
@export var orbit_distance_m: float = 23.094011
## World width (m) that must fit across the playfield: the 34 m route plus ~1 m margins. Chosen so the owner's
## orthographic size 46 holds at the base 1152-wide UI with the 248-unit sidebar (test_playfeel).
@export var fit_width_m: float = 46.0 * 904.0 / 1152.0
## Minimum world height (m, orthographic) visible on screen (wide windows).
@export var fit_height_m: float = 24.0
## UI units on the right covered by the HUD sidebar (set by the HUD).
var reserved_right: float = 0.0


func _ready() -> void:
	apply_elevation()
	get_viewport().size_changed.connect(fit)
	fit()


func apply_elevation() -> void:
	var angle: float = deg_to_rad(elevation_degrees)
	position = focus_point + Vector3(0.0, sin(angle), cos(angle)) * orbit_distance_m
	rotation = Vector3(-angle, 0.0, 0.0)


func fit() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	if vp.x <= reserved_right or vp.y <= 0.0:
		return
	size = maxf(fit_width_m * vp.x / (vp.x - reserved_right), fit_height_m * vp.x / vp.y)  # keep_aspect = width
	h_offset = size * reserved_right / vp.x / 2.0
