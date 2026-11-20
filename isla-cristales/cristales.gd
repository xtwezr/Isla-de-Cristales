extends Node3D

signal cristal_recogido

@onready var terreno := $"../Terreno"
var lista_cristales: Array[Area3D] = []
var tiempo := 0.0


func _ready() -> void:
	generar_cristales()


func generar_cristales() -> void:
	for c in lista_cristales:
		if is_instance_valid(c):
			c.queue_free()
	lista_cristales.clear()

	# Material dorado brillante
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.85, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.65, 0.05)
	mat.emission_energy_multiplier = 1.4
	mat.roughness = 0.2

	var posiciones := [
		Vector2(-12, -10), Vector2(0, -13), Vector2(12, -10),
		Vector2(-13, 0),   Vector2(-4, -4), Vector2(5, -3),
		Vector2(13, 1),    Vector2(-11, 10), Vector2(0, 12),
		Vector2(11, 10)
	]

	for i in range(posiciones.size()):
		var pos: Vector2 = posiciones[i]
		var area := Area3D.new()
		var y_base: float = terreno.calcular_altura(pos.x, pos.y) + 1.1
		area.position = Vector3(pos.x, y_base, pos.y)
		# Guardamos su altura base y un desfase para la flotación
		area.set_meta("y_base", y_base)
		area.set_meta("fase", i * 0.7)

		var mesh_inst := MeshInstance3D.new()
		var caja := BoxMesh.new()
		caja.size = Vector3(0.7, 0.7, 0.7)
		mesh_inst.mesh = caja
		mesh_inst.material_override = mat
		mesh_inst.rotation_degrees = Vector3(45, 0, 45)
		area.add_child(mesh_inst)

		var col := CollisionShape3D.new()
		var forma := SphereShape3D.new()
		forma.radius = 0.8
		col.shape = forma
		area.add_child(col)

		area.body_entered.connect(_al_tocar_cristal.bind(area))
		add_child(area)
		lista_cristales.append(area)


func _process(delta: float) -> void:
	tiempo += delta
	for c in lista_cristales:
		if is_instance_valid(c):
			c.rotation.y += 2.2 * delta
			var y_base: float = c.get_meta("y_base")
			var fase: float = c.get_meta("fase")
			c.position.y = y_base + sin(tiempo * 3.0 + fase) * 0.22


func _al_tocar_cristal(body: Node3D, cristal: Area3D) -> void:
	if body.name == "Personaje":
		cristal.queue_free()
		cristal_recogido.emit()
