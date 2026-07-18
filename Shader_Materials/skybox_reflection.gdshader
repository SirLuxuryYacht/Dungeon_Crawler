shader_type spatial;

uniform sampler2D hdri_texture : filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
	//NORMAL = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 1.0)).xyz);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	vec3 view_direction = vec3(NODE_POSITION_WORLD - CAMERA_POSITION_WORLD);
    
    vec3 reflect_direction = normalize(reflect(view_direction, normalize(WORLD_NORMAL)));
    
    float u = atan(reflect_direction.z,reflect_direction.y)/ (2.0 * PI) + 0.5;
	float v = asin(reflect_direction.x) / PI + 0.5;
    
    ALBEDO = texture(hdri_texture, vec2(u,v)).rgb;
	EMISSION = ALBEDO;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
