shader_type canvas_item;

uniform float enabled : hint_range(0.0,1.0) = 0.0; //Disabled
uniform vec4 shine_color : source_color = vec4(1.0); //Shine color
uniform float cycle_speed : hint_range(0.0, 10.0, 0.1) = 1.0; //Pulse cycle speed

void vertex() {
}

void fragment() {
	if (enabled > 0.0) {
		float cycle = sin(TIME * cycle_speed);
		COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, (cycle >= 0.0 ? abs(cycle) : 0.0) * shine_color.a);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
