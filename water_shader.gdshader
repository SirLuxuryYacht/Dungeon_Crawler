shader_type spatial;

uniform vec4 ColorParameter : source_color;

uniform sampler2D Albedo;

uniform float map_brightness;

uniform sampler2D Roughness;

uniform sampler2D Normal;

uniform float wavenumber;

uniform float amplitude;

uniform float flow_speed;

uniform float flow_angle;

uniform float harmonic_angle_offset;

uniform float harmonic_ratio;

void vertex() {
	
	float s = sin(PI/180.0 * harmonic_angle_offset);
	float c = cos(PI/180.0 * harmonic_angle_offset);
	
	vec2 flow_direction = vec2(cos(PI/180.0 * flow_angle),sin(PI/180.0 * flow_angle));
	vec2 location = vec2(UV.x,UV.y);
	vec2 wave_vector = flow_direction * wavenumber;
	
	float first_harmonic = amplitude * (1.0 - abs(sin(wave_vector.x * location.x + wave_vector.y * location.y - wavenumber * flow_speed * TIME)));
	wave_vector = vec2(c * wave_vector.x + s * wave_vector.y,-s * wave_vector.x + c * wave_vector.y);
	float second_harmonic = amplitude / harmonic_ratio * (1.0 - abs(sin(wave_vector.x * location.x + wave_vector.y * location.y - wavenumber * flow_speed * harmonic_ratio * TIME)));
	wave_vector = vec2(c * wave_vector.x + s * wave_vector.y,-s * wave_vector.x + c * wave_vector.y);
	float third_harmonic = amplitude / (2.0 * harmonic_ratio) * (1.0 - abs(sin(wave_vector.x * location.x + wave_vector.y * location.y - wavenumber * flow_speed * (2.0 * harmonic_ratio) * TIME)));
	
	VERTEX.y += first_harmonic + second_harmonic + third_harmonic;
}

void fragment() {
	// Called for every pixel the material is visible on.#
	// Fresnel:3
	float n_in3p3 = 1.00000;
	float n_out3p0 = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_in3p3);
	
	vec3 change_x = normalize(dFdx(VERTEX));
	vec3 change_y = normalize(dFdy(VERTEX));
	vec3 normal = normalize(vec3((PI + atan(cross(change_y,change_x).x)) * 255.0 / PI,(PI + atan(cross(change_y,change_x).y)) * 255.0 / PI,(PI + atan(cross(change_y,change_x).z)) * 255.0 / PI));

// MultiplyAdd:7
	float n_in7p1 = 0.90000;
	float n_in7p2 = 0.10000;
	float n_out7p0 = fma(n_out3p0, n_in7p1, n_in7p2);
	ALBEDO = ColorParameter.xyz;
	EMISSION = ALBEDO * map_brightness;
	ROUGHNESS = texture(Roughness,UV.xy).x;
	NORMAL_MAP = normal;
	ALPHA = n_out7p0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
