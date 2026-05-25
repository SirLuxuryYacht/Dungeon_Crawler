shader_type spatial;

const float frequency = 2.0;

const float time_factor = 1.0;

uniform float wind_strength;

uniform float flag_width;

uniform float map_brightness;

uniform int orientation;

uniform sampler2D Albedo;

uniform sampler2D Roughness;

uniform sampler2D Normal;

void vertex() {
	//VERTEX.y = VERTEX.y * VERTEX.y;
	VERTEX.z = float(orientation) * wind_strength * (0.4*sin(TIME)*sin(2.0*TIME)*sin(3.0*TIME)*sin(0.25*TIME)*cos(0.3*TIME) + 1.2)*(float(orientation) * 0.03 * VERTEX.y * VERTEX.y + 0.3) * (VERTEX.x + flag_width / 2.0) * 0.1 * sin(VERTEX.x/(0.1*flag_width) * (1.0 + 0.1 * sin(1000.0 * VERTEX.x/(0.1*flag_width))) - VERTEX.y/(0.1*flag_width) * (0.2 + 0.05 * sin(1000.0 * VERTEX.y/(0.1*flag_width))) - wind_strength * 2.0 * TIME * frequency * (1.0 + 0.1 * sin(1000.0 * frequency)));
	//VERTEX.z = VERTEX.z * VERTEX.z;
}

void fragment() {
	ALBEDO = texture(Albedo,UV.xy).xyz;
	EMISSION = ALBEDO * map_brightness;
	ROUGHNESS = texture(Roughness,UV.xy).x;
	NORMAL_MAP = texture(Normal,UV.xy).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
