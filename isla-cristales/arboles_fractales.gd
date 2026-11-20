extends Node3D

@export var niveles := 3
@export var largo_inicial := 2.2
@export var radio_inicial := 0.22
@export var angulo_ramas := 30.0 # grados

@onready var terreno := $"../Terreno"

var mat_tronco: StandardMaterial3D
var mat_hojas: StandardMaterial3D
var malla_hojas: SphereMesh


func _ready() -> void:
	mat_tronco = StandardMaterial3D.new()
	mat_tronco.albedo_color = Color(0.42, 0.26, 0.15)
	mat_tronco.roughness = 0.9

	mat_hojas = StandardMaterial3D.new()
	mat_hojas.albedo_color = Color(0.16, 0.58, 0.22)
	mat_hojas.roughness = 0.75

	# Reutilizamos una sola malla low-poly para todas las hojas (mejor rendimiento)
	malla_hojas = SphereMesh.new()
	malla_hojas.radius = 0.75
	malla_hojas.height = 1.2
	malla_hojas.radial_segments = 6
	malla_hojas.rings = 4

	var posiciones := [
		Vector2(-8.0, -6.0),
		Vector2(9.0, -5.0),
		Vector2(-7.0, 8.0),
		Vector2(8.0, 7.0),
	]

	for pos in posiciones:
		var y: float = terreno.calcular_altura(pos.x, pos.y)
		var base := Node3D.new()
		base.position = Vector3(pos.x, y - 0.1, pos.y)
		add_child(base)
		construir_rama(base, largo_inicial, radio_inicial, niveles)


func construir_rama(padre: Node3D, largo: float, radio: float, nivel: int) -> void:
	# 1. Crear la rama (cilindro)
	var mesh_inst := MeshInstance3D.new()
	var cilindro := CylinderMesh.new()
	cilindro.top_radius = radio * 0.75
	cilindro.bottom_radius = radio
	cilindro.height = largo
	cilindro.radial_segments = 6

	mesh_inst.mesh = cilindro
	mesh_inst.material_override = mat_tronco
	mesh_inst.position = Vector3(0.0, largo * 0.5, 0.0)
	padre.add_child(mesh_inst)

	# Caso base: en la punta de las últimas ramas colocamos las hojas
	if nivel <= 0:
		var copa := MeshInstance3D.new()
		copa.mesh = malla_hojas
		copa.material_override = mat_hojas
		copa.position = Vector3(0.0, largo, 0.0)
		padre.add_child(copa)
		return

	# 2. Crear 2 ramas hijas
	var rad := deg_to_rad(angulo_ramas)
	for lado in [-1.0, 1.0]:
		var pivote := Node3D.new()
		pivote.position = Vector3(0.0, largo, 0.0)

		if nivel % 2 == 0:
			pivote.rotation.z = lado * rad
		else:
			pivote.rotation.x = lado * rad

		padre.add_child(pivote)
		construir_rama(pivote, largo * 0.72, radio * 0.72, nivel - 1)
