class_name Banane
extends Node2D
## Le projectile lancé par le Singe. Sa trajectoire est balistique ; c'est la Partie qui résout son issue.

## Distance maximale parcourue entre deux tests de contact (évite de traverser une Plateforme).
const PAS_MAX: float = 6.0

var type: Lancer.Type
var vitesse: Vector2
var gravite: float
var rayon: float


## Avance la Banane et renvoie la liste des positions intermédiaires à tester.
func avancer(delta: float) -> Array[Vector2]:
	vitesse.y += gravite * delta
	var deplacement: Vector2 = vitesse * delta
	var pas: int = maxi(1, ceili(deplacement.length() / PAS_MAX))
	var points: Array[Vector2] = []
	for i: int in pas:
		points.append(position + deplacement * float(i + 1) / float(pas))
	return points


## Vrai si le disque de la Banane centré en `centre` touche le rectangle.
func touche(centre: Vector2, rect: Rect2) -> bool:
	var proche := Vector2(clampf(centre.x, rect.position.x, rect.end.x), clampf(centre.y, rect.position.y, rect.end.y))
	return centre.distance_squared_to(proche) <= rayon * rayon


func _process(delta: float) -> void:
	_rotation_visuelle += delta * (6.0 + vitesse.length() / 120.0) * signf(vitesse.x if vitesse.x != 0.0 else 1.0)
	queue_redraw()


var _rotation_visuelle: float = 0.0


func _draw() -> void:
	Dessin.banane(self, Vector2.ZERO, rayon * 2.6, _rotation_visuelle)
