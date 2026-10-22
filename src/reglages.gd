class_name Reglages
extends Resource
## Toutes les valeurs ajustables du jeu, regroupées en un seul endroit.

@export_group("Joueur")
@export var vitesse_course: float = 420.0
@export var acceleration_sol: float = 4000.0
@export var acceleration_air: float = 2200.0
@export var gravite: float = 2300.0
@export var vitesse_chute_max: float = 1300.0
@export var vitesse_saut: float = 880.0
@export var vitesse_double_saut: float = 800.0
@export var vitesse_dash: float = 950.0
@export var duree_dash: float = 0.15
@export var recharge_dash: float = 0.45
@export var duree_traversee: float = 0.25
