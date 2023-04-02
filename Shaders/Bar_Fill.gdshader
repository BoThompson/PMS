shader_type canvas_item;
uniform float cutoff;
uniform int direction;
uniform vec3 tint;

void fragment() {
	COLOR = COLOR * texture(TEXTURE, UV);
	COLOR.rgb += tint;
	switch(direction){
		case 0: if(UV.x > cutoff)
				{
					COLOR.a = 0.0;
				}
				break;
		case 1: if(UV.x < cutoff)
				{
					COLOR.a = 0.0;
				}
				break;
		case 2: if(UV.y > cutoff)
				{
					COLOR.a = 0.0;
				}
				break;
		case 3: if(UV.y < cutoff)
				{
					COLOR.a = 0.0;
				}
				break;
	}
}
