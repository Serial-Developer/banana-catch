class_name Fond
extends Node2D
## Décor animé derrière l'Arène : ciel en dégradé, soleil, montagnes lointaines, nuages en parallaxe.

const TAILLE := Vector2(1280.0, 720.0)
## Marge autour de l'écran couverte par le décor (secousses de caméra).
const MARGE: float = 80.0

var _temps: float = 0.0


func _ready() -> void:
	z_index = -100


func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()


func _draw() -> void:
	var haut := Color(0.22, 0.35, 0.85)
	var bas := Color(1.0, 0.7, 0.45)
	var a := Vector2(-MARGE, -MARGE)
	var b := TAILLE + Vector2(MARGE, MARGE)
	draw_polygon(PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)]), PackedColorArray([haut, haut, bas, bas]))
	# Soleil.
	draw_circle(Vector2(1040.0, 170.0), 120.0, Color(1.0, 0.9, 0.6, 0.18))
	draw_circle(Vector2(1040.0, 170.0), 70.0, Color(1.0, 0.92, 0.65, 0.6))
	# Montagnes (deux plans).
	_montagnes(560.0, 140.0, 0.08, Color(0.45, 0.4, 0.7, 0.8))
	_montagnes(640.0, 100.0, 0.18, Color(0.32, 0.28, 0.55, 0.9))
	# Nuages en parallaxe.
	for k: int in 6:
		var vitesse: float = 12.0 + k * 6.0
		var x: float = fposmod(k * 260.0 + _temps * vitesse, TAILLE.x + 2.0 * MARGE + 300.0) - MARGE - 150.0
		var y: float = 70.0 + (k * 97) % 260
		var c := Color(1.0, 1.0, 1.0, 0.55 + 0.05 * k)
		for bulle: Vector3 in [Vector3(0.0, 0.0, 34.0), Vector3(36.0, 8.0, 26.0), Vector3(-34.0, 10.0, 24.0), Vector3(10.0, 16.0, 26.0)]:
			draw_circle(Vector2(x + bulle.x, y + bulle.y), bulle.z, c)


func _montagnes(base: float, hauteur: float, decalage: float, couleur: Color) -> void:
	var points := PackedVector2Array([Vector2(-MARGE, TAILLE.y + MARGE)])
	var x: float = -MARGE
	var k: int = 0
	while x <= TAILLE.x + MARGE:
		var y: float = base - hauteur * (0.5 + 0.5 * sin(x * 0.007 + decalage * 10.0 + k * 1.3))
		points.append(Vector2(x, y))
		x += 120.0
		k += 1
	points.append(Vector2(TAILLE.x + MARGE, TAILLE.y + MARGE))
	draw_colored_polygon(points, couleur)
