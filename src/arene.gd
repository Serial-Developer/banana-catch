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
	# Plateforme principale : île flottante, herbe sur roche, dessous effilé.
	var p: Rect2 = PRINCIPALE
	var ile := PackedVector2Array([
		p.position, Vector2(p.end.x, p.position.y), Vector2(p.end.x - 30.0, p.position.y + 60.0),
		Vector2(p.end.x - 140.0, p.position.y + 120.0), Vector2(p.get_center().x + 60.0, p.position.y + 175.0),
		Vector2(p.get_center().x - 80.0, p.position.y + 165.0), Vector2(p.position.x + 120.0, p.position.y + 110.0),
		Vector2(p.position.x + 25.0, p.position.y + 55.0),
	])
	Dessin.polygone(self, ile, Color(0.42, 0.36, 0.5), 5.0)
	for k: int in 7:
		var x: float = p.position.x + 90.0 + k * 100.0
		draw_line(Vector2(x, p.position.y + 40.0), Vector2(x + 30.0, p.position.y + 80.0 + (k % 3) * 15.0), Color(0.3, 0.25, 0.38), 4.0)
	Dessin.polygone(self, Dessin.rectangle_arrondi(Vector2(p.get_center().x, p.position.y + 9.0), Vector2(p.size.x + 12.0, 22.0), 9.0), Color(0.35, 0.8, 0.4), 5.0)
	draw_line(Vector2(p.position.x + 10.0, p.position.y + 3.0), Vector2(p.end.x - 10.0, p.position.y + 3.0), Color(0.6, 0.95, 0.6), 3.0)
	# Plateformes hautes : dalles lumineuses traversables.
	for rect: Rect2 in HAUTES:
		Dessin.polygone(self, Dessin.rectangle_arrondi(rect.get_center() + Vector2(0.0, 2.0), rect.size + Vector2(8.0, 8.0), 7.0), Color(0.55, 0.75, 1.0, 0.95), 4.0)
		draw_line(rect.position + Vector2(10.0, 2.0), Vector2(rect.end.x - 10.0, rect.position.y + 2.0), Color(0.9, 0.97, 1.0), 3.0)
