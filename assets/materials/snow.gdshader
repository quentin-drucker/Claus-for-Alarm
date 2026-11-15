// Dev 13 snow (ground, backdrop, banks, rims): world-XZ mapped detail texture, so every snow surface agrees.
// Broad patches + fine grain + wind streaks; bright but never clipped (albedo stays below the tint).
shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform sampler2D detail : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(0.93, 0.955, 0.975);
uniform vec3 shade : source_color = vec3(0.82, 0.875, 0.93);
uniform float scale = 0.11;

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 fine = texture(detail, wpos.xz * scale);
	vec4 broad = texture(detail, wpos.zx * scale * 0.21 + vec2(0.37, 0.11));
	float drift = smoothstep(0.30, 0.72, broad.g);
	vec3 col = mix(shade, tint, drift);
	col *= mix(0.945, 1.025, fine.r);
	ALBEDO = col;
	ROUGHNESS = 0.82 - fine.b * 0.5;
	SPECULAR = 0.3 + fine.b * 0.6;
}
