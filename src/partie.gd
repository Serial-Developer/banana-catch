class_name Partie
extends Node2D
## Une Partie : l'Arène, le Joueur, le Singe et les Bananes, avec toutes les règles du jeu.

signal lancer(type: Lancer.Type)
signal attrape
signal coup(pourcentage: float)
signal echec
signal reapparition
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
var _pourcentage: float = 0.0
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


func pourcentage() -> float:
	return _pourcentage


func joueur_en_ejection() -> bool:
	return _joueur.en_ejection()


func joueur_invulnerable() -> bool:
	return _joueur.invulnerable()


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
		if _terminee:
			return
		_avancer_banane(banane, delta)
	if not _terminee and not Arene.LIMITES.has_point(_joueur.position):
		_perdre_stock()
		if not _terminee:
			_joueur.reapparaitre(Arene.POINT_APPARITION)
			reapparition.emit()


## Résout la Banane sur toute l'image physique : Attrape > Coup > Échec.
func _avancer_banane(banane: Banane, delta: float) -> void:
	var touche_joueur: bool = false
	var hors_jeu: bool = false
	for point: Vector2 in banane.avancer(delta):
		banane.position = point
		if banane.touche(point, _joueur.boite()) and (_joueur.peut_attraper() or not _joueur.invulnerable()):
			touche_joueur = true
			break
		if not hors_jeu and (_touche_une_plateforme(banane, point) or point.y > FOND_DU_VIDE or not Arene.LIMITES.has_point(point)):
			hors_jeu = true
	if touche_joueur and _joueur.peut_attraper():
		_retirer(banane)
		_joueur.confirmer_attrape()
		_score += 1
		attrape.emit()
	elif touche_joueur:
		_retirer(banane)
		_subir_coup(banane)
	elif hors_jeu:
		_retirer(banane)
		echec.emit()
		_perdre_stock()


func _subir_coup(banane: Banane) -> void:
	_pourcentage += reglages.pourcentage_par_coup
	var horizontal: float = banane.vitesse.x / maxf(banane.vitesse.length(), 1.0)
	if absf(horizontal) < 0.3:
		# Banane presque verticale : le Joueur est repoussé du côté opposé à la Banane.
		var cote: float = signf(_joueur.position.x - banane.position.x)
		horizontal = 0.3 * (cote if cote != 0.0 else 1.0)
	var direction := Vector2(horizontal, -reglages.ejection_composante_haute).normalized()
	var force: float = reglages.ejection_base + _pourcentage * reglages.ejection_facteur
	var duree: float = maxf(reglages.ejection_duree_min, force * reglages.ejection_duree_par_force)
	_joueur.ejecter(direction * force, duree)
	coup.emit(_pourcentage)


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
	_pourcentage = 0.0
	stock_perdu.emit(_stocks)
	if _stocks <= 0:
		_terminer()
	else:
		_joueur.devenir_invulnerable(reglages.duree_invulnerabilite)


func _terminer() -> void:
	_terminee = true
	for banane: Banane in _bananes.duplicate():
		_retirer(banane)
	_joueur.set_physics_process(false)
	var record_battu: bool = _score > meilleur_score
	fin_de_partie.emit(_score, record_battu)
