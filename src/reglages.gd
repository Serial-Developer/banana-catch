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

@export_group("Attrape")
@export var duree_fenetre_attrape: float = 0.2
@export var duree_recuperation: float = 0.4

@export_group("Bananes")
@export var gravite_banane: float = 900.0
@export var rayon_banane: float = 16.0

@export_group("Partie")
@export var stocks_depart: int = 3

@export_group("Coup et Éjection")
@export var pourcentage_par_coup: float = 12.0
## Force d'Éjection = base + Pourcentage × facteur (en px/s).
@export var ejection_base: float = 380.0
@export var ejection_facteur: float = 9.0
## Composante verticale (vers le haut) de la direction d'Éjection, avant normalisation.
@export var ejection_composante_haute: float = 0.7
## Durée sans contrôle par unité de force d'Éjection (s par px/s).
@export var ejection_duree_par_force: float = 0.00035
@export var ejection_duree_min: float = 0.15

@export_group("Stocks")
@export var duree_invulnerabilite: float = 2.0
