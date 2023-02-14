shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void light() {
	// Place fragment code here.
	COLOR = texture(TEXTURE, UV)
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
}
