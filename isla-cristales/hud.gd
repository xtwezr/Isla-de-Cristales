extends Node2D

enum Estado { JUGANDO, GANASTE, PERDISTE }

@export var tiempo_limite := 60.0
@export var meta_cristales := 10
# Posición del HUD con matriz de transformación (listo para el Hechizo Mutador)
@export var posicion_hud := Vector2(20.0, 20.0)

var estado := Estado.JUGANDO
var puntaje := 0
var tiempo_restante := 60.0
var motivo_derrota := ""

@onready var cristales := $"../../Cristales"
@onready var drones := $"../../Drones"
@onready var personaje: CharacterBody3D = $"../../Personaje"


func _ready() -> void:
	tiempo_restante = tiempo_limite
	cristales.cristal_recogido.connect(_on_cristal_recogido)
	drones.dron_tocado.connect(_on_dron_tocado)


func _process(delta: float) -> void:
	if estado == Estado.JUGANDO:
		tiempo_restante -= delta
		if tiempo_restante <= 0.0:
			tiempo_restante = 0.0
			terminar_partida(Estado.PERDISTE, "¡Se acabó el tiempo!")
		elif personaje.global_position.y < -5.0:
			terminar_partida(Estado.PERDISTE, "¡Te caíste al agua!")
	else:
		# Presionar R para reiniciar
		if Input.is_key_pressed(KEY_R):
			reiniciar_partida()

	# Redibuja el HUD en cada frame
	queue_redraw()


func _on_cristal_recogido() -> void:
	if estado != Estado.JUGANDO:
		return
	puntaje += 1
	if puntaje >= meta_cristales:
		terminar_partida(Estado.GANASTE, "¡Recolectaste todos los cristales!")


func _on_dron_tocado() -> void:
	if estado != Estado.JUGANDO:
		return
	terminar_partida(Estado.PERDISTE, "¡Te atrapó un dron!")


func terminar_partida(nuevo_estado: Estado, motivo: String) -> void:
	estado = nuevo_estado
	motivo_derrota = motivo
	personaje.set_physics_process(false)


func reiniciar_partida() -> void:
	estado = Estado.JUGANDO
	puntaje = 0
	tiempo_restante = tiempo_limite
	motivo_derrota = ""

	# Regresa al personaje al centro de la isla y reactiva su movimiento
	personaje.global_position = Vector3(0.0, 5.0, 0.0)
	personaje.velocity = Vector3.ZERO
	personaje.set_physics_process(true)

	# Regenera los 10 cristales
	cristales.generar_cristales()


func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	var tamano_ventana := get_viewport_rect().size

	# --- 1. PANEL DEL HUD (usando matriz de transformación y modelo HSV) ---
	var matriz_hud := Transform2D(0.0, posicion_hud)
	draw_set_transform_matrix(matriz_hud)

	# Fondo semitransparente (HSV: tono azul oscuro)
	var color_fondo := Color.from_hsv(0.60, 0.40, 0.12, 0.80)
	draw_rect(Rect2(0, 0, 250, 95), color_fondo, true)
	# Borde con primitiva de línea (rectángulo sin relleno)
	draw_rect(Rect2(0, 0, 250, 95), Color.from_hsv(0.55, 0.50, 0.90), false, 2.0)

	# Texto de puntaje (HSV: dorado)
	var color_puntaje := Color.from_hsv(0.13, 0.85, 1.0)
	draw_string(fuente, Vector2(15, 32), "Cristales: %d / %d" % [puntaje, meta_cristales], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, color_puntaje)

	# Color del tiempo en HSV: pasa de verde (0.33) a rojo (0.0) según el tiempo restante
	var fraccion := clampf(tiempo_restante / tiempo_limite, 0.0, 1.0)
	var color_tiempo := Color.from_hsv(0.33 * fraccion, 0.90, 0.95)
	draw_string(fuente, Vector2(15, 62), "Tiempo: %.1f s" % tiempo_restante, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, color_tiempo)

	# Barra de tiempo dibujada con primitiva de línea
	draw_line(Vector2(15, 78), Vector2(235, 78), Color.from_hsv(0.0, 0.0, 0.3), 6.0)
	draw_line(Vector2(15, 78), Vector2(15 + 220.0 * fraccion, 78), color_tiempo, 6.0)

	# Restauramos la matriz identidad para las pantallas finales
	draw_set_transform_matrix(Transform2D.IDENTITY)

	# --- 2. PANTALLAS DE GANASTE / PERDISTE ---
	if estado != Estado.JUGANDO:
		draw_rect(Rect2(Vector2.ZERO, tamano_ventana), Color(0, 0, 0, 0.65), true)

		var centro := tamano_ventana * 0.5
		var titulo := "¡GANASTE!" if estado == Estado.GANASTE else "PERDISTE"
		var color_titulo := Color.from_hsv(0.33, 0.85, 1.0) if estado == Estado.GANASTE else Color.from_hsv(0.0, 0.85, 1.0)

		draw_string(fuente, centro + Vector2(-120, -30), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, color_titulo)
		draw_string(fuente, centro + Vector2(-150, 20), motivo_derrota, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
		draw_string(fuente, centro + Vector2(-140, 65), "Presiona [R] para jugar de nuevo", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.from_hsv(0.15, 0.6, 1.0))
