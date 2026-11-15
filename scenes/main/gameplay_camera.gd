extends Camera3D
## Orbit the same ground focus without changing orthographic zoom or map geometry.
## 60 degrees reproduces the previous pitch; 50 is the owner's more side-on trial.

@export_range(35.0, 80.0, 1.0) var elevation_degrees: float = 50.0
@export var focus_point: Vector3 = Vector3(6.5, 0.0, -0.047005)
@export var orbit_distance_m: float = 23.094011


func _ready() -> void:
	apply_elevation()


func apply_elevation() -> void:
	var angle: float = deg_to_rad(elevation_degrees)
	position = focus_point + Vector3(0.0, sin(angle), cos(angle)) * orbit_distance_m
	rotation = Vector3(-angle, 0.0, 0.0)
