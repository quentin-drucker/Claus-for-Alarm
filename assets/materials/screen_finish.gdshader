shader_type canvas_item;
render_mode unshaded, blend_disabled;
// Final full-screen finish (DEC-049): faint pixel cells, soft vignette, powder snow in the bottom corners.
// Reads the composed frame (3D, every CanvasLayer, embedded popups/tooltips) via the screen texture.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform float cell_size = 3.0;          // physical output pixels per sampling cell
uniform float pixel_blend = 0.3;        // 0 = untouched frame, 1 = full cell colour
uniform float vignette_strength = 0.08; // corner darkening (0..1)
uniform float snow_opacity = 0.6;
uniform vec4 snow_color : source_color = vec4(0.965, 0.98, 1.0, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(float x, float seed) {
	float i = floor(x);
	float f = smoothstep(0.0, 1.0, fract(x));
	return mix(hash(vec2(i, seed)), hash(vec2(i + 1.0, seed)), f);
}

// Height (in screen heights) of the powder at horizontal position x (screen heights from the left edge).
float powder_height(float x, float width) {
	float xr = width - x;
	float left = 0.03 * exp(-pow(x / 0.2, 2.0));
	float right = 0.036 * exp(-pow(xr / 0.12, 2.0));
	// Light dusting along parts of the bottom edge only.
	float dust = 0.008 * smoothstep(0.45, 0.75, noise(x * 6.0, 3.0));
	float h = max(max(left, right), dust);
	return h * (0.78 + 0.44 * noise(x * 28.0, 7.0));
}

void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 cell = vec2(max(cell_size, 1.0));
	// Grid anchored to the screen corner in physical pixels: the camera never moves it.
	vec2 centre = (floor(SCREEN_UV * res / cell) + 0.5) * cell;
	vec2 q = 0.25 * cell * SCREEN_PIXEL_SIZE;
	vec2 c_uv = centre * SCREEN_PIXEL_SIZE;
	vec3 cell_col = 0.25 * (texture(screen_tex, c_uv + vec2(-q.x, -q.y)).rgb
			+ texture(screen_tex, c_uv + vec2(q.x, -q.y)).rgb
			+ texture(screen_tex, c_uv + vec2(-q.x, q.y)).rgb
			+ texture(screen_tex, c_uv + vec2(q.x, q.y)).rgb);
	vec3 col = mix(texture(screen_tex, SCREEN_UV).rgb, cell_col, pixel_blend);

	// Powder, evaluated on the same cell grid so its outline shares the pixel finish.
	vec2 p = (floor(UV * res / cell) + 0.5) * cell;
	float x = p.x / res.y;
	float y = (res.y - p.y) / res.y;
	float h = powder_height(x, res.x / res.y);
	float mask = 1.0 - smoothstep(h * 0.45, h, y);
	mask *= 0.85 + 0.15 * hash(floor(p / cell));
	col = mix(col, snow_color.rgb, mask * snow_opacity);

	float d = length(UV - 0.5) * 1.41421;
	col *= 1.0 - vignette_strength * smoothstep(0.55, 1.05, d);
	COLOR = vec4(col, 1.0);
}
