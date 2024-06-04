shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float t: hint_range(0.0,1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	float s = COLOR.r + COLOR.g + COLOR.b;
	s /= 3.0;
	COLOR.rgb = mix(COLOR.rgb, vec3(s,s,s), t);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
