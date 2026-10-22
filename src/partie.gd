class_name Partie
extends Node2D
## Une Partie : l'Arène, le Joueur, le Singe et les Bananes, avec toutes les règles du jeu.

const SCENE: PackedScene = preload("res://scenes/partie.tscn")

var reglages: Reglages
var graine: int = 1
var meilleur_score: int = 0

var _rng := RandomNumberGenerator.new()
var _joueur: Joueur


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
	_rng.seed = graine
	add_child(Arene.new())
	_joueur = Joueur.new()
	_joueur.reglages = reglages
	_joueur.position = Arene.POINT_APPARITION
	add_child(_joueur)


func joueur_position() -> Vector2:
	return _joueur.position


func joueur_au_sol() -> bool:
	return _joueur.is_on_floor()
