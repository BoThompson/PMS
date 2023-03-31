shader_type canvas_item;
uniform float cutoff;
uniform int direction;

void fragment() {
	COLOR = COLOR * texture(TEXTURE, UV);
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
