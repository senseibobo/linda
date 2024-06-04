shader_type canvas_item;
uniform sampler2D albedo_texture: source_color,filter_nearest;
uniform sampler2D mask_texture: source_color,filter_nearest;

uniform vec2 node_size = vec2(400.0, 400.0);
uniform vec4 color : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(0.0);

varying vec2 vert;


void vertex() {
	vert = VERTEX;
}

void fragment() {
	float t = TIME;// mod(TIME,1);
	vec2 full_uv = vert/node_size;
	vec2 tile_uv = vec2(mod(full_uv.x-t,1),mod(full_uv.y-t,1));
	float mask = texture(mask_texture,UV).r*1.60;
	COLOR.rgb =mix(color.rgb,color2.rgb,1.0-step(mask+(-texture(albedo_texture, tile_uv).r),0.5));
	//COLOR.a = max((texture(albedo_texture, tile_uv+t).r-1.0) + (1.0-UV.x*5.0)-1.0*7.0,0.0) ;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
