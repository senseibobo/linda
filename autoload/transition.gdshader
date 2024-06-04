shader_type canvas_item;
uniform sampler2D albedo_texture: source_color,filter_nearest;
uniform float t: hint_range(0.0,1.0) = 0.0;
uniform vec2 node_size = vec2(400.0, 400.0);
uniform vec4 color : source_color = vec4(1.0);

varying vec2 vert;


void vertex() {
    vert = VERTEX;
}

void fragment() {
    float v = t;// mod(TIME,1);
    vec2 full_uv = vert/node_size;
    vec2 tile_uv = vec2(mod(full_uv.x,1),mod(full_uv.y,1));
    COLOR.rgb = color.rgb;
    COLOR.a = 1.0-step(max((texture(albedo_texture, tile_uv).r-1.0) + (1.0-UV.x*5.0)-1.0+v*7.0,0.0),0.5) ;
}