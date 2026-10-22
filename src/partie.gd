class_name Partie
extends Node2D
## Une Partie : l'Arène, le Joueur, le Singe et les Bananes, avec toutes les règles du jeu.

signal lancer(type: Lancer.Type)
signal attrape
signal echec
signal stock_perdu(stocks_restants: int)
signal fin_de_partie(score: int, record_battu: bool)

const SCENE: PackedScene = preload("res://scenes/partie.tscn")
## Sous cette hauteur, une Banane est tombée dans le vide.
const FOND_DU_VIDE: float = 780.0

var reglages: Reglages
var graine: int = 1
var meilleur_score: int = 0

var _rng := RandomNumberGenerator.new()
var _joueur: Joueur
var _bananes: Array[Banane] = []
var _score: int = 0
var _stocks: int = 0
var _terminee: bool = false


## Crée une Partie prête à être ajoutée à l'arbre.
static func creer(p_reglages: Reglages = null, p_graine: int = 1, p_meilleur_score: int = 0) -> Partie:
	var partie: Partie = SCENE.instantiate()
	partie.reglages = p_reglages
	partie.graine = p_graine
	partie.meilleur_score = p_meilleur_score
	return partie


func _ready() -> void:
	if reglages == null:
		reglages = Reglages.new()
	# Les règles sont évaluées après le déplacement du Joueur dans la même image physique.
	process_physics_priority = 10
	_rng.seed = graine
	_stocks = reglages.stocks_depart
	add_child(Arene.new())
	_joueur = Joueur.new()
	_joueur.reglages = reglages
	_joueur.position = Arene.POINT_APPARITION
	add_child(_joueur)


# --- État observable -------------------------------------------------------

func score() -> int:
	return _score


func stocks() -> int:
	return _stocks


func terminee() -> bool:
	return _terminee


func nombre_bananes_en_vol() -> int:
	return _bananes.size()


func positions_bananes() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for banane: Banane in _bananes:
		positions.append(banane.position)
	return positions


func joueur_position() -> Vector2:
	return _joueur.position


func joueur_au_sol() -> bool:
	return _joueur.is_on_floor()


## "normal", "fenetre" ou "recuperation".
func joueur_etat_attrape() -> String:
	return Joueur.EtatAttrape.keys()[_joueur.etat_attrape()].to_lower()


# --- Lancers ---------------------------------------------------------------

## Lance une Banane immédiatement (utilisé par le Singe, et par les tests pour imposer un Lancer).
func forcer_lancer(p_lancer: Lancer) -> void:
	var banane := Banane.new()
	banane.type = p_lancer.type
	banane.position = p_lancer.depart
	banane.vitesse = p_lancer.vitesse
	banane.gravite = reglages.gravite_banane
	banane.rayon = reglages.rayon_banane
	_bananes.append(banane)
	add_child(banane)
	lancer.emit(p_lancer.type)


func _unhandled_input(event: InputEvent) -> void:
	# Touche de debug : F1 force un Lancer aléatoire vers le Joueur.
	if OS.is_debug_build() and event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_F1:
		var depart := Vector2(_rng.randf_range(260.0, 1020.0), -40.0)
		forcer_lancer(Lancer.new(Lancer.Type.ARC, depart, Vector2((_joueur.position.x - depart.x) * 0.8, 0.0)))


# --- Règles ----------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _terminee:
		return
	for banane: Banane in _bananes.duplicate():
		_avancer_banane(banane, delta)


func _avancer_banane(banane: Banane, delta: float) -> void:
	for point: Vector2 in banane.avancer(delta):
		banane.position = point
		if banane.touche(point, _joueur.boite()) and _joueur.peut_attraper():
			_retirer(banane)
			_joueur.confirmer_attrape()
			_score += 1
			attrape.emit()
			return
		if _touche_une_plateforme(banane, point) or point.y > FOND_DU_VIDE or not Arene.LIMITES.has_point(point):
			_retirer(banane)
			echec.emit()
			_perdre_stock()
			return


func _touche_une_plateforme(banane: Banane, point: Vector2) -> bool:
	for rect: Rect2 in Arene.plateformes():
		if banane.touche(point, rect):
			return true
	return false


func _retirer(banane: Banane) -> void:
	_bananes.erase(banane)
	banane.queue_free()


func _perdre_stock() -> void:
	_stocks -= 1
	stock_perdu.emit(_stocks)
	if _stocks <= 0:
		_terminer()


func _terminer() -> void:
	_terminee = true
	for banane: Banane in _bananes.duplicate():
		_retirer(banane)
	_joueur.set_physics_process(false)
	var record_battu: bool = _score > meilleur_score
	fin_de_partie.emit(_score, record_battu)
