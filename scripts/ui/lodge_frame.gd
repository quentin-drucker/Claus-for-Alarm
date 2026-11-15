class_name LodgeFrame
extends PanelContainer
## Major-frame decoration on top of the theme's timber panel (Dev 13): bevel lines on the timber, brass nails at the
## corners, and optionally a snow cap along the top edge and a garland under it. Drawn in code: no textures,
## nothing behind text (it stays inside the timber border).

const T := preload("res://scripts/ui/lodge_theme.gd")

@export var snow_cap: bool = false
@export var garland: bool = false
@export var nails: bool = true


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var r: Rect2 = Rect2(Vector2.ZERO, size)
	var w: float = 6.0  # timber border width (LodgeTheme frame)
	# Bevel: light inner top/left, dark inner bottom/right lines on the timber.
	draw_line(Vector2(2, 2), Vector2(r.size.x - 2, 2), T.TIMBER_LIGHT, 1.5)
	draw_line(Vector2(2, 2), Vector2(2, r.size.y - 2), T.TIMBER_LIGHT, 1.5)
	draw_line(Vector2(w, r.size.y - w), Vector2(r.size.x - w, r.size.y - w), T.TIMBER_DARK, 1.5)
	draw_line(Vector2(r.size.x - w, w), Vector2(r.size.x - w, r.size.y - w), T.TIMBER_DARK, 1.5)
	if nails:
		for p: Vector2 in [Vector2(w / 2, w / 2), Vector2(r.size.x - w / 2, w / 2), Vector2(w / 2, r.size.y - w / 2),
				Vector2(r.size.x - w / 2, r.size.y - w / 2)]:
			draw_circle(p, 2.4, T.TIMBER_DARK)
			draw_circle(p - Vector2(0.4, 0.4), 1.7, T.BRASS)
	if garland:
		var y: float = w + 3.0
		var x: float = 14.0
		var k: int = 0
		while x < r.size.x - 14.0:
			draw_arc(Vector2(x + 9.0, y - 3.0), 9.0, 0.35, PI - 0.35, 8, Color("2f6b45"), 3.0)
			draw_circle(Vector2(x + 9.0, y + 6.0), 2.2, T.RED if k % 2 == 0 else T.GOLD)
			x += 18.0
			k += 1
	if snow_cap:
		# Irregular drift along the top timber: overlapping lumps, a soft blue underside line.
		var x2: float = -2.0
		var i: int = 0
		while x2 < r.size.x + 2.0:
			var rad: float = 4.0 + float((i * 7) % 5)
			draw_circle(Vector2(x2, 0.5), rad + 0.8, Color("a9c3d6"))
			draw_circle(Vector2(x2, -0.5), rad, T.SNOW)
			x2 += rad * 1.3
			i += 1
		draw_rect(Rect2(0, -4, r.size.x, 4), T.SNOW)
