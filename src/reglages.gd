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

@export_group("Effets")
## Gel d'image sur les impacts (toujours ignoré sans affichage).
@export var gel_image: bool = true
## Volume global des effets sonores (0 à 1).
@export_range(0.0, 1.0) var volume: float = 0.8

@export_group("Singe")
@export var singe_vitesse: float = 320.0


@export_group("Progression")
## Paliers triés par Score croissant ; le dernier atteint s'applique.
@export var paliers: Array[Palier] = [
	Palier.creer(0, 1.4, 1, 1, 0.7, 0.15, 0.15),
	Palier.creer(10, 1.0, 2, 2, 0.5, 0.25, 0.25),
	Palier.creer(25, 0.45, 3, 3, 0.34, 0.33, 0.33),
]
## Au-delà du dernier palier, l'intervalle diminue de cette valeur par Attrape, jusqu'au plancher.
@export var reduction_intervalle_par_attrape: float = 0.02
@export var intervalle_plancher: float = 0.2


func palier(score: int) -> Palier:
	var courant: Palier = paliers[0]
	for p: Palier in paliers:
		if score >= p.score_min:
			courant = p
	return courant


## Cadence : pause du Singe entre deux Lancers pour ce Score.
func intervalle_lancers(score: int) -> float:
	var p: Palier = palier(score)
	if p != paliers[-1]:
		return p.intervalle
	var reduction: float = (score - p.score_min) * reduction_intervalle_par_attrape
	return maxf(p.intervalle - reduction, intervalle_plancher)

@export_group("Lancers")
@export var duree_elan_arc: float = 0.4
@export var duree_elan_tir_tendu: float = 0.3
@export var duree_elan_lob: float = 0.55
## Temps de vol jusqu'à la cible : [min, max] en secondes.
@export var temps_vol_arc: Vector2 = Vector2(0.9, 1.25)
@export var temps_vol_lob: Vector2 = Vector2(1.8, 2.2)
## Vitesse horizontale d'un Tir tendu (px/s) et temps de vol minimal.
@export var vitesse_tir_tendu: float = 1000.0
@export var temps_vol_min_tir_tendu: float = 0.25
## Écart aléatoire maximal entre le point visé et le Joueur (px).
@export var dispersion_arc: float = 24.0
@export var dispersion_tir_tendu: float = 12.0
@export var dispersion_lob: float = 32.0
