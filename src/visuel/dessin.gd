class_name Dessin
extends RefCounted
## Primitives de dessin cartoon : formes pleines cernées d'un contour épais.

const CONTOUR := Color(0.08, 0.05, 0.12)
const EPAISSEUR: float = 4.0


static func cercle(ci: CanvasItem, centre: Vector2, rayon: float, couleur: Color, epaisseur: float = EPAISSEUR) -> void:
	ci.draw_circle(centre, rayon + epaisseur, Color(CONTOUR, couleur.a))
	ci.draw_circle(centre, rayon, couleur)


static func ellipse(ci: CanvasItem, centre: Vector2, rayons: Vector2, couleur: Color, epaisseur: float = EPAISSEUR) -> void:
	polygone(ci, points_ellipse(centre, rayons), couleur, epaisseur)


static func polygone(ci: CanvasItem, points: PackedVector2Array, couleur: Color, epaisseur: float = EPAISSEUR) -> void:
	ci.draw_colored_polygon(points, couleur)
	if epaisseur > 0.0:
		var ferme: PackedVector2Array = points.duplicate()
		ferme.append(points[0])
		ci.draw_polyline(ferme, Color(CONTOUR, couleur.a), epaisseur, true)


## Membre (bras, jambe) : trait épais à bout arrondi, cerné.
static func membre(ci: CanvasItem, de: Vector2, a: Vector2, largeur: float, couleur: Color) -> void:
	ci.draw_line(de, a, CONTOUR, largeur + EPAISSEUR * 2.0)
	ci.draw_circle(de, (largeur + EPAISSEUR * 2.0) / 2.0, CONTOUR)
	ci.draw_circle(a, (largeur + EPAISSEUR * 2.0) / 2.0, CONTOUR)
	ci.draw_line(de, a, couleur, largeur)
	ci.draw_circle(de, largeur / 2.0, couleur)
	ci.draw_circle(a, largeur / 2.0, couleur)


static func rectangle_arrondi(centre: Vector2, taille: Vector2, rayon: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var demi: Vector2 = taille / 2.0 - Vector2(rayon, rayon)
	var coins: Array[Vector2] = [Vector2(demi.x, demi.y), Vector2(-demi.x, demi.y), Vector2(-demi.x, -demi.y), Vector2(demi.x, -demi.y)]
	for i: int in 4:
		for k: int in 6:
			var angle: float = (i + k / 5.0) * PI / 2.0
			points.append(centre + coins[i] + Vector2(cos(angle), sin(angle)) * rayon)
	return points


static func points_ellipse(centre: Vector2, rayons: Vector2, segments: int = 28) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in segments:
		var angle: float = TAU * i / segments
		points.append(centre + Vector2(cos(angle) * rayons.x, sin(angle) * rayons.y))
	return points


## Forme de Banane (croissant incurvé vers le haut) centrée sur l'origine, de longueur `longueur`.
## Les 13 premiers points forment le bord inférieur, de la queue (indice 0) à la pointe (indice 12).
static func points_banane(longueur: float) -> PackedVector2Array:
	var bas := PackedVector2Array()
	var haut := PackedVector2Array()
	for i: int in 13:
		var t: float = lerpf(-1.0, 1.0, i / 12.0)
		var milieu := Vector2(t * longueur / 2.0, longueur * 0.22 * (t * t - 0.5))
		var epaisseur: float = longueur * 0.3 * pow(1.0 - t * t, 0.7)
		bas.append(milieu + Vector2(0.0, epaisseur * 0.6))
		haut.append(milieu - Vector2(0.0, epaisseur * 0.4))
	haut.reverse()
	bas.append_array(haut)
	return bas


static func banane(ci: CanvasItem, position: Vector2, longueur: float, angle: float, alpha: float = 1.0) -> void:
	ci.draw_set_transform(position, angle, Vector2.ONE)
	polygone(ci, points_banane(longueur), Color(1.0, 0.86, 0.2, alpha), 3.0)
	var bouts: PackedVector2Array = points_banane(longueur)
	ci.draw_circle(bouts[0], 3.5, Color(0.35, 0.22, 0.08, alpha))
	ci.draw_circle(bouts[12], 3.0, Color(0.45, 0.6, 0.15, alpha))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
