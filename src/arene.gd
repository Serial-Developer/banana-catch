class_name Arene
extends Node2D
## L'Arène : une Plateforme principale flottante, des Plateformes hautes traversables, du vide autour.

const COUCHE_PRINCIPALE: int = 1
const COUCHE_HAUTES: int = 2

const HAUT_PRINCIPALE: float = 520.0
const PRINCIPALE := Rect2(240.0, HAUT_PRINCIPALE, 800.0, 48.0)
const HAUTES: Array[Rect2] = [
	Rect2(350.0, 385.0, 210.0, 14.0),
	Rect2(720.0, 385.0, 210.0, 14.0),
	Rect2(535.0, 255.0, 210.0, 14.0),
]
## Au-delà de ces limites, le Joueur est hors de l'Arène.
const LIMITES := Rect2(-260.0, -460.0, 1800.0, 1360.0)
const POINT_APPARITION := Vector2(640.0, 440.0)


func _ready() -> void:
	_ajouter_plateforme(PRINCIPALE, false)
	for rect: Rect2 in HAUTES:
		_ajouter_plateforme(rect, true)


## Toutes les Plateformes (principale d'abord).
static func plateformes() -> Array[Rect2]:
	var toutes: Array[Rect2] = [PRINCIPALE]
	toutes.append_array(HAUTES)
	return toutes


func _ajouter_plateforme(rect: Rect2, haute: bool) -> void:
	var corps := StaticBody2D.new()
	corps.position = rect.get_center()
	corps.collision_layer = 0
	corps.set_collision_layer_value(COUCHE_HAUTES if haute else COUCHE_PRINCIPALE, true)
	corps.collision_mask = 0
	var forme := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	forme.shape = rectangle
	forme.one_way_collision = haute
	corps.add_child(forme)
	add_child(corps)


func _draw() -> void:
	draw_rect(PRINCIPALE, Color(0.35, 0.3, 0.45))
	for rect: Rect2 in HAUTES:
		draw_rect(rect, Color(0.5, 0.45, 0.6))
