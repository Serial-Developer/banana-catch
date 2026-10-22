class_name Palier
extends Resource
## Un palier de progression : à partir d'un Score, la Cadence, le nombre de Bananes en vol et le mélange des Lancers.

@export var score_min: int = 0
## Pause du Singe entre la fin d'un Lancer et la décision suivante.
@export var intervalle: float = 1.4
@export var bananes_max: int = 1
## Nombre de Lancers enchaînés depuis une même position avant que le Singe ne se déplace.
@export var lancers_par_position: int = 1
@export var poids_arc: float = 0.6
@export var poids_tir_tendu: float = 0.2
@export var poids_lob: float = 0.2


static func creer(p_score_min: int, p_intervalle: float, p_bananes_max: int, p_lancers_par_position: int, p_arc: float, p_tir: float, p_lob: float) -> Palier:
	var palier := Palier.new()
	palier.score_min = p_score_min
	palier.intervalle = p_intervalle
	palier.bananes_max = p_bananes_max
	palier.lancers_par_position = p_lancers_par_position
	palier.poids_arc = p_arc
	palier.poids_tir_tendu = p_tir
	palier.poids_lob = p_lob
	return palier
