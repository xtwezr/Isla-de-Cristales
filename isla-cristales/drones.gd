extends Node3D

signal dron_tocado

@export var velocidad := 0.25
# Interruptor listo para el Hechizo Mutador: cambia entre Bézier y B-spline
@export var usar_bspline := false

@onready var terreno := $"../Terreno"

var drones: Array[Area3D] = []
var anillos: Array[MeshInstance3D] = []
var rutas: Array = []
var tiempos: Array[float] = [0.0, 0.5]
var direcciones: Array[float] = [1.0, -1.0]


func _ready() -> void:
	rutas.append([
		Vector2(-14, -8),
		Vector2(-4, -14),
		Vector2(6, 2),
		Vector2(14, -6)
	])
	rutas.append([
		Vector2(-14, 8),
		Vector2(-5, -2),
		Vector2(5, 14),
		Vector2(14, 6)
	])

	var mat_nucleo := StandardMaterial3D.new()
	mat_nucleo.albedo_color = Color(0.95, 0.15, 0.15)
	mat_nucleo.emission_enabled = true
	mat_nucleo.emission = Color(0.9, 0.1, 0.1)
	mat_nucleo.emission_energy_multiplier = 1.5

	var mat_anillo := StandardMaterial3D.new()
	mat_anillo.albedo_color = Color(0.15, 0.17, 0.22)
	mat_anillo.metallic = 0.8
	mat_anillo.roughness = 0.25

	for i in range(2):
		var area := Area3D.new()

		# Núcleo rojo
		var mesh_inst := MeshInstance3D.new()
		var esfera := SphereMesh.new()
		esfera.radius = 0.65
		esfera.height = 1.3
		mesh_inst.mesh = esfera
		mesh_inst.material_override = mat_nucleo
		area.add_child(mesh_inst)

		# Anillo metálico giratorio
		var anillo_inst := MeshInstance3D.new()
		var toro := TorusMesh.new()
		toro.inner_radius = 0.8
		toro.outer_radius = 1.0
		anillo_inst.mesh = toro
		anillo_inst.material_override = mat_anillo
		anillo_inst.rotation_degrees = Vector3(25, 0, 0)
		area.add_child(anillo_inst)
		anillos.append(anillo_inst)

		var col := CollisionShape3D.new()
		var forma := SphereShape3D.new()
		forma.radius = 0.85
		col.shape = forma
		area.add_child(col)

		area.body_entered.connect(_al_tocar_dron)
		add_child(area)
		drones.append(area)


func _process(delta: float) -> void:
	for i in range(drones.size()):
		tiempos[i] += velocidad * direcciones[i] * delta
		if tiempos[i] >= 1.0:
			tiempos[i] = 1.0
			direcciones[i] = -1.0
		elif tiempos[i] <= 0.0:
			tiempos[i] = 0.0
			direcciones[i] = 1.0

		var P: Array = rutas[i]
		var pos_2d := evaluar_bspline(P, tiempos[i]) if usar_bspline else evaluar_bezier(P, tiempos[i])
		var y: float = terreno.calcular_altura(pos_2d.x, pos_2d.y)
		drones[i].position = Vector3(pos_2d.x, y + 1.1, pos_2d.y)

		# Giro tipo giroscopio en el anillo
		anillos[i].rotation.y += 4.5 * delta
		anillos[i].rotation.z += 2.0 * delta


func evaluar_bezier(P: Array, t: float) -> Vector2:
	var u := 1.0 - t
	return (
		u * u * u * P[0]
		+ 3.0 * u * u * t * P[1]
		+ 3.0 * u * t * t * P[2]
		+ t * t * t * P[3]
	)


func evaluar_bspline(P: Array, t: float) -> Vector2:
	var u := 1.0 - t
	var b0 := (u * u * u) / 6.0
	var b1 := (3.0 * t * t * t - 6.0 * t * t + 4.0) / 6.0
	var b2 := (-3.0 * t * t * t + 3.0 * t * t + 3.0 * t + 1.0) / 6.0
	var b3 := (t * t * t) / 6.0
	return P[0] * b0 + P[1] * b1 + P[2] * b2 + P[3] * b3


func _al_tocar_dron(body: Node3D) -> void:
	if body.name == "Personaje":
		dron_tocado.emit()
