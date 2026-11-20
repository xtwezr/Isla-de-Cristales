shader_type spatial;

uniform vec3 color_profundo : source_color = vec3(0.05, 0.25, 0.55);
uniform vec3 color_ola : source_color = vec3(0.15, 0.55, 0.85);
uniform float velocidad = 2.0;
uniform float altura_ola = 0.15;

void vertex() {
	// Mueve los vértices arriba y abajo formando olas con el tiempo
	VERTEX.y += sin(VERTEX.x * 0.4 + TIME * velocidad) * altura_ola;
	VERTEX.y += cos(VERTEX.z * 0.4 + TIME * velocidad) * altura_ola;
}

void fragment() {
	// Mezcla dos tonos de azul para dar sensación de movimiento
	float mezcla = sin(UV.x * 20.0 + TIME * velocidad) * 0.5 + 0.5;
	ALBEDO = mix(color_profundo, color_ola, mezcla);
	ROUGHNESS = 0.2;
}