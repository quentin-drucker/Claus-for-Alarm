// Dev 13 rink ice: deep clear blue towards the middle, frosted near the shore, faint skate scratches and one painted
// ring. UV = local XZ metres from the rink centre.
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform sampler2D detail : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 deep : source_color = vec3(0.38, 0.62, 0.76);
uniform vec3 frost : source_color = vec3(0.78, 0.89, 0.94);
uniform float shore_radius = 2.4;

void fragment() {
	vec2 p = UV;
	float r = length(p) / shore_radius;
	vec4 d = texture(detail, p * 0.35);
	vec4 s = texture(detail, vec2(p.x * 0.08 + p.y * 0.05, p.y * 0.9 - p.x * 0.4));
	vec3 col = mix(deep, frost, smoothstep(0.55, 1.0, r) + d.g * 0.15);
	col = mix(col, vec3(0.92, 0.96, 0.98), smoothstep(0.62, 0.7, s.r) * 0.35);  // scratches
	float ring = 1.0 - smoothstep(0.015, 0.035, abs(length(p) - 0.75));
	col = mix(col, vec3(0.80, 0.28, 0.30), ring * 0.55);
	ALBEDO = col;
	ROUGHNESS = 0.18 + d.r * 0.15;
	SPECULAR = 0.6;
}
