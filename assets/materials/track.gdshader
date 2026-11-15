// Dev 13 groomed ski trail: packed blue-grey snow with corduroy lines along the direction of travel (UV.y = metres
// along the route, UV.x = across) and darker packed edges against the banks. Darker than snow and stone (ART_STYLE).
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform sampler2D detail : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 packed_snow : source_color = vec3(0.63, 0.70, 0.78);
uniform float ribs = 11.0;

void fragment() {
	float across = UV.x;
	vec4 d = texture(detail, vec2(UV.y * 0.05, across * 0.6));
	vec4 b = texture(detail, vec2(UV.y * 0.013 + 0.5, across * 0.15));
	float rib = 0.5 + 0.5 * sin(across * 6.2831 * ribs);
	float edge = smoothstep(0.0, 0.12, across) * smoothstep(1.0, 0.88, across);
	vec3 col = packed_snow * mix(0.95, 1.03, rib) * mix(0.94, 1.04, d.r) * mix(0.96, 1.03, b.g);
	ALBEDO = col * mix(0.86, 1.0, edge);
	ROUGHNESS = 0.7;
	SPECULAR = 0.35;
}
