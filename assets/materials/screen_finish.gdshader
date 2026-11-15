shader_type canvas_item;
render_mode unshaded;
// Final full-screen finish (DEC-049): faint vignette and powder snow in the bottom corners, drawn as a plain
// alpha overlay above every game layer and popup. The universal pixel pass was removed at the owner's request.

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
	vec2 p = UV * res;
	float h = powder_height(p.x / res.y, res.x / res.y);
	float snow = (1.0 - smoothstep(h * 0.45, h, (res.y - p.y) / res.y)) * snow_opacity;
	float shade = vignette_strength * smoothstep(0.55, 1.05, length(UV - 0.5) * 1.41421);
	// Darken first, then powder on top, as one blended layer.
	float alpha = 1.0 - (1.0 - shade) * (1.0 - snow);
	COLOR = vec4(snow_color.rgb * snow / max(alpha, 0.0001), alpha);
}
