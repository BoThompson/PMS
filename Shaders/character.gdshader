shader_type canvas_item;

uniform vec4  tint_color : source_color;
uniform float tint_strength : hint_range(0, 1);
void fragment(){
	vec4 tcol = texture(TEXTURE, UV);
  COLOR.rgb = mix(tcol.rgb,tint_color.rgb, tint_strength); //read from texture
  COLOR.a = tcol.a;
}