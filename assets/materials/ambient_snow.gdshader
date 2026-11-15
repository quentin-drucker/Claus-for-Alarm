shader_type spatial;
// Ambient snow (P17-T07): every flake is animated here from TIME, so the CPU never touches a flake after _ready.
// INSTANCE_CUSTOM = (base x, base y, base z, seed 0..1); instance transforms stay identity (custom_aabb culls).
// gust = false: drifting snowfall wrapped inside box_min..box_max.
// gust = true: a corkscrew ribbon rolling along gust_dir from gust_start; xyz = (ribbon u, ring angle, radius).
render_mode unshaded, skip_vertex_transform, cull_disabled, shadows_disabled, depth_draw_never;

uniform bool gust = false;
uniform vec3 box_min = vec3(-27.0, 0.0, -22.0);
uniform vec3 box_max = vec3(27.0, 13.0, 18.0);
uniform vec2 wind = vec2(0.35, 0.12);
uniform float fall_speed = 0.9;
uniform float flake_size = 0.17;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 0.9);
// Cool rim so white flakes still read over the white snowfield.
uniform vec3 rim : source_color = vec3(0.62, 0.72, 0.88);
// Gust: start point, travel direction (XZ, unit), age 0..1 over its life, travel distance and ribbon shape.
uniform vec3 gust_start = vec3(0.0);
uniform vec2 gust_dir = vec2(1.0, 0.0);
uniform float gust_age = 0.0;
uniform float gust_travel = 38.0;
uniform float gust_length = 7.0;
uniform float gust_turns = 2.0;
uniform float gust_spin = 8.0;
// Meander: sideways sway (m), number of S-bends over the crossing, and a per-gust phase set by the script.
uniform float gust_sway = 2.5;
uniform float gust_waves = 1.2;
uniform float gust_phase = 0.0;

varying float v_alpha;

void vertex() {
	vec4 c = INSTANCE_CUSTOM;
	float seed = c.w;
	vec3 p;
	float size = flake_size * (0.6 + 0.8 * fract(seed * 7.13));
	v_alpha = 1.0;
	if (gust) {
		vec3 dir = vec3(gust_dir.x, 0.0, gust_dir.y);
		vec3 side = vec3(-gust_dir.y, 0.0, gust_dir.x);
		float u = c.x;
		// Wafting: the gust meanders sideways and bobs up/down; each flake sits where the head was `lag` ago, so the
		// ribbon follows the curve and its tail curls behind the head instead of moving as a rigid tube.
		float a = gust_age - u * gust_length / gust_travel;
		vec3 centre = gust_start + dir * gust_travel * a
				+ side * sin(a * 6.2832 * gust_waves + gust_phase) * gust_sway
				+ vec3(0.0, 1.4 + sin(a * 6.2832 * gust_waves * 1.7 + gust_phase) * 0.9 + u * 0.6, 0.0);
		float angle = c.y + u * gust_turns * 6.2832 - TIME * gust_spin;
		float breathe = 0.75 + 0.25 * sin(TIME * 2.3 + c.y * 3.0);
		float radius = c.z * (0.3 + 1.1 * u) * breathe * (0.6 + 0.4 * sin(gust_age * 3.1416));
		p = centre + side * cos(angle) * radius + vec3(0.0, sin(angle) * radius, 0.0);
		v_alpha = sin(gust_age * 3.1416) * (1.0 - u * 0.7);
		size *= 1.35;
	} else {
		vec3 span = box_max - box_min;
		float t = TIME * (0.7 + 0.6 * fract(seed * 3.7));
		p = c.xyz;
		p.y -= fall_speed * t;
		p.xz += wind * t;
		// Flutter: a small loop per flake so the fall reads as snow, not rain.
		float ph = seed * 6.2832;
		p.x += sin(TIME * (0.9 + seed) + ph) * 0.35;
		p.z += cos(TIME * (0.7 + seed) + ph) * 0.25;
		p = box_min + mod(p - box_min, span);
		v_alpha = smoothstep(0.0, 1.0, p.y - box_min.y);  // melt into the ground instead of popping
	}
	// Billboard: place the quad in view space around the flake's world position.
	VERTEX = (VIEW_MATRIX * vec4(p, 1.0)).xyz + vec3(VERTEX.xy * size, 0.0);
}

void fragment() {
	float d = length(UV - vec2(0.5)) * 2.0;
	ALBEDO = mix(tint.rgb, rim, smoothstep(0.25, 0.85, d));
	ALPHA = tint.a * v_alpha * (1.0 - smoothstep(0.55, 1.0, d));
}
