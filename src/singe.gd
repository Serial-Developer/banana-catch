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
var actif: bool = true

var _etat: Etat = Etat.ATTENTE
var _temps: float = 0.0
var _duree: float = 0.0
var _depart := Vector2.ZERO
var _arrivee := Vector2.ZERO
var _hauteur_saut: float = 0.0
var _type: Lancer.Type = Lancer.Type.ARC
var _orientation: float = -1.0


func _ready() -> void:
	position = POINT_DEPART
	_attendre(reglages.intervalle_lancers)


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
				_attendre(reglages.intervalle_lancers)


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
	position = _arrivee
	_type = _tirer_type()
	_etat = Etat.ELAN
	_temps = 0.0
	_duree = [reglages.duree_elan_arc, reglages.duree_elan_tir_tendu, reglages.duree_elan_lob][_type]


func _tirer_type() -> Lancer.Type:
	var poids: Array[float] = [reglages.poids_arc, reglages.poids_tir_tendu, reglages.poids_lob]
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


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var couleur := Color(0.55, 0.33, 0.18)
	if _etat == Etat.ELAN:
		couleur = [Color(0.9, 0.6, 0.2), Color(1.0, 0.3, 0.2), Color(0.6, 0.4, 1.0)][_type]
	draw_rect(Rect2(-22.0, -60.0, 44.0, 60.0), couleur)
	draw_rect(Rect2(-24.0, -70.0, 48.0, 12.0), Color(0.85, 0.1, 0.1))
