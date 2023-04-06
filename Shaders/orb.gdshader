shader_type canvas_item;

void fragment() {
	vec3 white = vec3(1, 1, 1);
	COLOR.rgb = white - (white - COLOR.rgb) * (white - texture(TEXTURE, UV).rgb);
	COLOR.a = COLOR.a * texture(TEXTURE, UV).a;
	// Place fragment code here.
}
