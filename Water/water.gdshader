shader_type spatial;

const int wave_count = 4;

struct Wave {
	float amplitude;
	float phase;
	float frequency;
	vec2 direction;
};

uniform vec3 water_colour: source_color = vec3(0.1, 0.5, 0.8);
uniform vec3 fresnel_colour: source_color = vec3(0.1, 0.5, 0.8);

uniform sampler2D normal_map_cuz_ugly;

group_uniforms wave1;
uniform float amplitude1: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float phase1: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float frequency1: hint_range(0.001, 0.3, 0.01) = 0.1;
uniform vec2 direction1 = vec2(0.0, 0.0);

group_uniforms wave2;
uniform float amplitude2: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float phase2: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float frequency2: hint_range(0.001, 0.3, 0.01) = 0.1;
uniform vec2 direction2 = vec2(0.0, 0.1);

group_uniforms wave3;
uniform float amplitude3: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float phase3: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float frequency3: hint_range(0.001, 0.3, 0.01) = 0.1;
uniform vec2 direction3 = vec2(1.0,1.0);

group_uniforms wave4;
uniform float amplitude4: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float phase4: hint_range(0.001, 10.0, 0.01) = 0.1;
uniform float frequency4: hint_range(0.001, 0.3, 0.01) = 0.1;
uniform vec2 direction4 = vec2(1.0, 0.0);

varying vec3 world_pos;

vec2 get_direction(vec3 vertex, Wave w) {
	return w.direction;
}

float get_wave_coord(vec3 v, vec2 d) {
	return v.x * d.x + v.z * d.y;
}

float get_time(Wave w) {
	return TIME * w.phase;
}

float sine(vec3 v, Wave w) {
	vec2 d = get_direction(v, w);
	float xz = get_wave_coord(v, d);
	float t = get_time(w);

	return w.amplitude * sin(xz * w.frequency + t);
}

vec3 sine_normal(vec3 v, Wave w) {
	vec2 d = get_direction(v, w);
	float xz = get_wave_coord(v, d);
	float t = get_time(w);

	vec2 n = w.frequency * w.amplitude * d * cos(xz * w.frequency + t);
	return vec3(n.x, n.y, 0.0);
}

vec3 calc_offset(vec3 v, Wave w) {
	return vec3(0.0, sine(v, w), 0.0);
}

vec3 calc_normal(vec3 v, Wave w) {
	return sine_normal(v, w);
}

void vertex() {
	Wave wave1 = Wave(amplitude1, phase1, frequency1, direction1);
	Wave wave2 = Wave(amplitude2, phase2, frequency2, direction2);
	Wave wave3 = Wave(amplitude3, phase3, frequency3, direction3);
	Wave wave4 = Wave(amplitude4, phase4, frequency4, direction4);
	Wave[wave_count] waves;
	waves[0] = wave1;
	waves[1] = wave2;
	waves[2] = wave3;
	waves[3] = wave4;

	//for (int i = 0; i < waves.length(); i++) {
		//VERTEX.y += waves[i].amplitude * sin(VERTEX.x * waves[i].frequency + TIME * waves[i].phase);
		//VERTEX.y += waves[i].amplitude * sin(VERTEX.z * waves[i].frequency + TIME * waves[i].phase);
	//}

	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec3 h = vec3(0.0);
	vec3 n = vec3(0.0, 0.0, 0.0);

	for (int wi = 0; wi < wave_count; wi ++) {
		h += calc_offset(world_pos, waves[wi]);
		n += calc_normal(world_pos, waves[wi]);
	}
	VERTEX.y = h.y;
	NORMAL = normalize(vec3(-n.x, 1.0,-n.y));
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

}

void fragment() {
	vec3 view_dir = normalize(-VERTEX);
    float fresnel = dot(normalize(NORMAL), view_dir);
    fresnel = pow(1.0 - fresnel, 4.0);

    ALBEDO = mix(water_colour, fresnel_colour, fresnel * 0.5);
    SPECULAR = 0.2;
    ROUGHNESS = 0.1;
    METALLIC = 0.0;
	NORMAL_MAP = texture(normal_map_cuz_ugly, UV).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
