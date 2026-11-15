shader_type canvas_item;
// Enlarged character portraits (shop, upgrade card, hero strip): stronger pixel finish than the world (DEC-049).
// Blocks are in texture space, so they scale with the UI like the portrait itself.

uniform float blocks = 32.0; // pixel blocks across the portrait

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec2 uv = (floor(UV * blocks) + 0.5) / blocks;
	// Mip level that averages one block: steady colours, no sparkle from point-sampling 256 px art.
	float lod = log2(max(1.0, 1.0 / (TEXTURE_PIXEL_SIZE.x * blocks)));
	COLOR = textureLod(TEXTURE, uv, lod) * tint;
}
