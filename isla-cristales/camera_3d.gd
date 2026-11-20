extends Camera3D

@export var desplazamiento := Vector3(0.0, 6.0, 10.0)
@export var velocidad_seguimiento := 5.0

@onready var personaje: Node3D = $"../Personaje"


func _physics_process(delta: float) -> void:
	if personaje == null:
		return

	# Seguimiento suavizado con delta (dt)
	var destino := personaje.global_position + desplazamiento
	global_position = global_position.lerp(destino, clampf(velocidad_seguimiento * delta, 0.0, 1.0))

	# Siempre mira hacia el personaje
	look_at(personaje.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
