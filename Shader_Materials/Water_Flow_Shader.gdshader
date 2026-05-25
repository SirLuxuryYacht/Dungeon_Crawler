shader_type spatial;

uniform float map_brightness;

uniform sampler2D Albedo;

uniform sampler2D Roughness;

uniform sampler2D Normal;

uniform float flow_speed;

uniform float flow_angle;

void vertex() {
	vec2 flow_direction = vec2(cos(PI/180.0 * flow_angle),sin(PI/180.0 * flow_angle));
	// Called for every vertex the material is visible on.
	UV.x += flow_direction.x * 0.1 * flow_speed * TIME;
	UV.y += flow_direction.y * 0.1 * flow_speed * TIME;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(Albedo,UV.xy).xyz;
	EMISSION = ALBEDO * map_brightness;
	ROUGHNESS = texture(Roughness,UV.xy).x;
	NORMAL_MAP = texture(Normal,UV.xy).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
