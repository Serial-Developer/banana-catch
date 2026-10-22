class_name Singe
extends Node2D
## L'adversaire : se déplace dans l'Arène et enchaîne Élan puis Lancer. Il ne fait aucun dégât par contact.

signal lance(lancer: Lancer)

enum Etat { ATTENTE, DEPLACEMENT, ELAN }

const POINT_DEPART := Vector2(960.0, Arene.HAUT_PRINCIPALE)
## Hauteur de la main (lieu de départ des Bananes) au-dessus des pieds.
const HAUTEUR_MAIN: float = 56.0

var reglages: Reglages
var rng: RandomNumberGenerator
## Renvoie le point visé (buste du Joueur).
var cible: Callable
## Renvoie vrai si une nouvelle Banane peut être lancée.
var peut_lancer: Callable
## Renvoie le Score courant (règle la Cadence et le mélange des Lancers).
var score: Callable
var actif: bool = true

var _etat: Etat = Etat.ATTENTE
var _temps: float = 0.0
var _duree: float = 0.0
var _depart := Vector2.ZERO
var _arrivee := Vector2.ZERO
var _hauteur_saut: float = 0.0
var _type: Lancer.Type = Lancer.Type.ARC
var _orientation: float = -1.0
var _lancers_restants_ici: int = 0


func _ready() -> void:
	position = POINT_DEPART
	_attendre(reglages.intervalle_lancers(score.call()))


func etat() -> Etat:
	return _etat


func type_en_preparation() -> Lancer.Type:
	return _type


func _physics_process(delta: float) -> void:
	if not actif:
		return
	_temps += delta
	match _etat:
		Etat.ATTENTE:
			if _temps >= _duree and peut_lancer.call():
				if _lancers_restants_ici > 0:
					_preparer_lancer()
				else:
					_lancers_restants_ici = reglages.palier(score.call()).lancers_par_position
					_choisir_destination()
		Etat.DEPLACEMENT:
			var s: float = clampf(_temps / _duree, 0.0, 1.0)
			position = _depart.lerp(_arrivee, s) + Vector2(0.0, -_hauteur_saut * 4.0 * s * (1.0 - s))
			if s >= 1.0:
				_preparer_lancer()
		Etat.ELAN:
			_orientation = signf(cible.call().x - position.x)
			if _temps >= _duree:
				lance.emit(_calculer_lancer())
				_attendre(reglages.intervalle_lancers(score.call()))


func _attendre(duree: float) -> void:
	_etat = Etat.ATTENTE
	_temps = 0.0
	_duree = duree


func _choisir_destination() -> void:
	var plateformes: Array[Rect2] = Arene.plateformes()
	var rect: Rect2 = plateformes[rng.randi_range(0, plateformes.size() - 1)]
	_depart = position
	_arrivee = Vector2(rng.randf_range(rect.position.x + 30.0, rect.end.x - 30.0), rect.position.y)
	var meme_niveau: bool = is_equal_approx(_depart.y, _arrivee.y)
	_hauteur_saut = 0.0 if meme_niveau else 90.0 + maxf(_depart.y - _arrivee.y, 0.0)
	_etat = Etat.DEPLACEMENT
	_temps = 0.0
	_duree = maxf(_depart.distance_to(_arrivee) / reglages.singe_vitesse, 0.0 if meme_niveau else 0.5)
	if _duree <= 0.0:
		_preparer_lancer()


func _preparer_lancer() -> void:
	if _etat == Etat.DEPLACEMENT:
		position = _arrivee
	_lancers_restants_ici -= 1
	_type = _tirer_type()
	_etat = Etat.ELAN
	_temps = 0.0
	_duree = [reglages.duree_elan_arc, reglages.duree_elan_tir_tendu, reglages.duree_elan_lob][_type]


func _tirer_type() -> Lancer.Type:
	var palier: Palier = reglages.palier(score.call())
	var poids: Array[float] = [palier.poids_arc, palier.poids_tir_tendu, palier.poids_lob]
	var tirage: float = rng.randf() * (poids[0] + poids[1] + poids[2])
	for type: int in poids.size():
		if tirage < poids[type]:
			return type as Lancer.Type
		tirage -= poids[type]
	return Lancer.Type.ARC


## Vitesse initiale qui amène la Banane de la main au point visé (dispersé) en un temps de vol donné.
func _calculer_lancer() -> Lancer:
	var main: Vector2 = position + Vector2(_orientation * 20.0, -HAUTEUR_MAIN)
	var dispersion: float = [reglages.dispersion_arc, reglages.dispersion_tir_tendu, reglages.dispersion_lob][_type]
	var vise: Vector2 = cible.call() + Vector2(rng.randf_range(-dispersion, dispersion), 0.0)
	var ecart: Vector2 = vise - main
	var temps_vol: float
	match _type:
		Lancer.Type.TIR_TENDU:
			temps_vol = maxf(absf(ecart.x) / reglages.vitesse_tir_tendu, reglages.temps_vol_min_tir_tendu)
		Lancer.Type.LOB:
			temps_vol = rng.randf_range(reglages.temps_vol_lob.x, reglages.temps_vol_lob.y)
		_:
			temps_vol = rng.randf_range(reglages.temps_vol_arc.x, reglages.temps_vol_arc.y)
	var vitesse := Vector2(ecart.x / temps_vol, (ecart.y - 0.5 * reglages.gravite_banane * temps_vol * temps_vol) / temps_vol)
	return Lancer.new(_type, main, vitesse)


func _process(delta: float) -> void:
	_temps_anim += delta
	queue_redraw()


# --- Rendu : un singe original (casquette, salopette, queue). Aucune règle ici. --

const FOURRURE := Color(0.5, 0.3, 0.15)
const VISAGE := Color(0.95, 0.78, 0.58)
const CASQUETTE := Color(0.9, 0.15, 0.15)
const SALOPETTE := Color(0.2, 0.4, 0.85)
## Couleur d'aura de l'Élan, par type de Lancer.
const AURA: Array[Color] = [Color(1.0, 0.75, 0.2), Color(1.0, 0.25, 0.2), Color(0.65, 0.4, 1.0)]

var _temps_anim: float = 0.0


func _draw() -> void:
	var en_elan: bool = _etat == Etat.ELAN
	var progression: float = clampf(_temps / maxf(_duree, 0.01), 0.0, 1.0) if en_elan else 0.0
	var accroupi: float = 0.0
	if en_elan and _type == Lancer.Type.TIR_TENDU:
		accroupi = 6.0 * progression
	draw_set_transform(Vector2(0.0, -30.0 + accroupi), 0.0, Vector2(_orientation, 1.0))

	if en_elan:
		var aura: Color = AURA[_type]
		draw_circle(Vector2(0.0, -6.0), 38.0 + 6.0 * sin(_temps_anim * 30.0), Color(aura, 0.25 + 0.3 * progression))

	# Queue en spirale.
	var queue := PackedVector2Array()
	for k: int in 14:
		var t: float = k / 13.0
		queue.append(Vector2(-14.0 - 22.0 * t, 14.0 - 30.0 * t) + Vector2(cos(t * 7.0), sin(t * 7.0)) * 6.0 * t)
	draw_polyline(queue, Dessin.CONTOUR, 9.0, true)
	draw_polyline(queue, FOURRURE, 5.0, true)
	# Jambes.
	var pas: float = sin(_temps_anim * 14.0) * 6.0 if _etat == Etat.DEPLACEMENT else 0.0
	Dessin.membre(self, Vector2(-7.0, 16.0), Vector2(-9.0 + pas, 30.0 - accroupi), 8.0, FOURRURE)
	Dessin.membre(self, Vector2(7.0, 16.0), Vector2(9.0 - pas, 30.0 - accroupi), 8.0, FOURRURE)
	# Salopette.
	Dessin.polygone(self, Dessin.rectangle_arrondi(Vector2(0.0, 6.0), Vector2(30.0, 26.0), 9.0), SALOPETTE)
	draw_circle(Vector2(-7.0, -2.0), 2.5, Color(1.0, 0.85, 0.3))
	draw_circle(Vector2(7.0, -2.0), 2.5, Color(1.0, 0.85, 0.3))
	# Bras selon l'Élan : derrière l'épaule (Arc), tiré en arrière à l'horizontale (Tir tendu), au-dessus de la tête (Lob).
	var main_lancer := Vector2(16.0, 8.0)
	var main_autre := Vector2(-15.0, 10.0)
	if en_elan:
		match _type:
			Lancer.Type.ARC:
				main_lancer = Vector2(-10.0, -30.0).lerp(Vector2(-18.0, -26.0), progression)
			Lancer.Type.TIR_TENDU:
				main_lancer = Vector2(-26.0 - 6.0 * progression, -4.0)
				main_autre = Vector2(22.0, -6.0)
			Lancer.Type.LOB:
				main_lancer = Vector2(4.0, -46.0)
				main_autre = Vector2(-6.0, -46.0)
	Dessin.membre(self, Vector2(-9.0, -4.0), main_autre, 7.0, FOURRURE)
	Dessin.membre(self, Vector2(9.0, -4.0), main_lancer, 7.0, FOURRURE)
	if en_elan:
		Dessin.banane(self, main_lancer + Vector2(0.0, -8.0), 26.0, -0.6)
		draw_set_transform(Vector2(0.0, -30.0 + accroupi), 0.0, Vector2(_orientation, 1.0))
	# Tête : oreilles, visage, yeux, casquette à visière vers l'avant avec un emblème banane.
	Dessin.cercle(self, Vector2(-15.0, -20.0), 7.0, FOURRURE, 3.0)
	Dessin.cercle(self, Vector2(15.0, -20.0), 7.0, FOURRURE, 3.0)
	draw_circle(Vector2(-15.0, -20.0), 3.5, VISAGE)
	draw_circle(Vector2(15.0, -20.0), 3.5, VISAGE)
	Dessin.cercle(self, Vector2(0.0, -20.0), 14.0, FOURRURE)
	Dessin.ellipse(self, Vector2(4.0, -16.0), Vector2(10.0, 8.0), VISAGE, 0.0)
	draw_circle(Vector2(1.0, -21.0), 2.6, Dessin.CONTOUR)
	draw_circle(Vector2(9.0, -21.0), 2.6, Dessin.CONTOUR)
	draw_arc(Vector2(5.0, -13.0), 4.0, 0.2, PI - 0.2, 8, Dessin.CONTOUR, 2.0)
	Dessin.polygone(self, PackedVector2Array([Vector2(-14.0, -28.0), Vector2(-10.0, -38.0), Vector2(8.0, -39.0), Vector2(14.0, -29.0), Vector2(24.0, -27.0), Vector2(23.0, -24.0), Vector2(-14.0, -25.0)]), CASQUETTE, 3.0)
	Dessin.banane(self, Vector2(0.0, -32.0), 10.0, 0.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
