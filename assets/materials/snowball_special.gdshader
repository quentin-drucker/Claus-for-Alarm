// Dev 13 special snowball shells (replace the B/W/A/C letters): mode 0 = Aurora (slow ribbons of green/teal light
// over violet, gently emissive), mode 1 = Camo (the layer colour broken by dark blotches). Object-space pattern, so it
// rolls with the shell; baked vertex-colour AO kept.
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform int mode = 0;
uniform vec3 base_color : source_color = vec3(0.48, 0.25, 0.84);
uniform sampler2D detail : hint_default_white, filter_linear_mipmap, repeat_enable;

varying vec3 opos;

void vertex() {
	opos = VERTEX;
}

void fragment() {
	vec3 ao = COLOR.rgb;
	if (mode == 0) {
		float w = sin(opos.y * 9.0 + opos.x * 4.0 + TIME * 1.6) * 0.5 + 0.5;
		float w2 = sin(opos.y * 6.0 - opos.z * 5.0 - TIME * 1.1) * 0.5 + 0.5;
		vec3 band = mix(vec3(0.25, 0.95, 0.65), vec3(0.35, 0.8, 1.0), w2);
		float k = smoothstep(0.55, 0.95, w) * 0.85;
		vec3 col = mix(base_color, band, k);
		ALBEDO = col * ao;
		EMISSION = band * k * 0.55;
		ROUGHNESS = 0.35;
	} else {
		float n = texture(detail, opos.xz * 0.9 + opos.y * 0.4).g;
		float n2 = texture(detail, opos.zy * 1.3 + vec2(0.3, 0.7)).g;
		float blot = smoothstep(0.5, 0.56, n) + smoothstep(0.52, 0.58, n2) * 0.7;
		vec3 dark = base_color * vec3(0.38, 0.5, 0.4) + vec3(0.06, 0.1, 0.05);
		ALBEDO = mix(base_color, dark, clamp(blot, 0.0, 1.0)) * ao;
		ROUGHNESS = 0.8;
	}
}
