extends "res://tests/lib/suite_partie.gd"
## Ticket 03 : Coup, Pourcentage, Éjection, sortie d'Arène et Réapparition.

const HAUTEUR_JOUEUR: float = 64.0
const X_DEGAGE: float = 285.0

var attrapes: Array
var coups: Array
var echecs: Array
var stocks_perdus: Array
var reapparitions: Array


func _partie_prete(reglages: Reglages = null) -> void:
	nouvelle_partie(reglages)
	attrapes = espionner("attrape")
	coups = espionner("coup")
	echecs = espionner("echec")
	stocks_perdus = espionner("stock_perdu")
	reapparitions = espionner("reapparition")
	await secondes(1.0)
	await aller_vers(X_DEGAGE)


## Tir tendu horizontal, de la gauche vers le buste du Joueur.
func _tir_tendu_sur_le_joueur() -> void:
	var pieds: Vector2 = partie.joueur_position()
	partie.forcer_lancer(Lancer.new(Lancer.Type.TIR_TENDU, pieds + Vector2(-160.0, -40.0), Vector2(900.0, 0.0)))


func _lacher_au_dessus_de_la_tete(hauteur: float) -> void:
	var pieds: Vector2 = partie.joueur_position()
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, pieds + Vector2(0.0, -HAUTEUR_JOUEUR - hauteur), Vector2.ZERO))


func test_un_coup_augmente_le_pourcentage_et_fait_disparaitre_la_banane_sans_echec() -> String:
	await _partie_prete()
	_tir_tendu_sur_le_joueur()
	await secondes(1.5)
	if coups.size() != 1:
		return "attendu 1 Coup, obtenu %d" % coups.size()
	var attendu: float = Reglages.new().pourcentage_par_coup
	if not is_equal_approx(partie.pourcentage(), attendu) or not is_equal_approx(coups[0][0], attendu):
		return "le Pourcentage devrait valoir %s, obtenu %s" % [attendu, partie.pourcentage()]
	if not echecs.is_empty() or partie.nombre_bananes_en_vol() != 0:
		return "la Banane du Coup devrait disparaître sans Échec"
	return ""


func test_les_coups_s_accumulent_dans_le_pourcentage() -> String:
	await _partie_prete()
	_tir_tendu_sur_le_joueur()
	await secondes(1.5)
	await aller_vers(X_DEGAGE)
	_tir_tendu_sur_le_joueur()
	await secondes(1.0)
	if coups.size() != 2 or not is_equal_approx(partie.pourcentage(), 2.0 * Reglages.new().pourcentage_par_coup):
		return "deux Coups devraient doubler le Pourcentage, obtenu %s" % partie.pourcentage()
	return ""


func _distance_d_ejection(pourcentage_par_coup: float) -> float:
	var reglages := Reglages.new()
	reglages.pourcentage_par_coup = pourcentage_par_coup
	await _partie_prete(reglages)
	_tir_tendu_sur_le_joueur()
	await attendre_que(func() -> bool: return coups.size() == 1, 1.0)
	var depart: Vector2 = partie.joueur_position()
	await secondes(0.3)
	var distance: float = partie.joueur_position().distance_to(depart)
	partie.queue_free()
	await images(1)
	return distance


func test_a_pourcentage_eleve_la_meme_banane_ejecte_plus_loin() -> String:
	var faible: float = await _distance_d_ejection(1.0)
	var eleve: float = await _distance_d_ejection(120.0)
	if eleve < faible * 1.5:
		return "l'Éjection à haut Pourcentage devrait être bien plus forte (faible=%s, élevé=%s)" % [faible, eleve]
	return ""


func test_pendant_l_ejection_appuyer_sur_attraper_est_sans_effet() -> String:
	await _partie_prete()
	_tir_tendu_sur_le_joueur()
	await attendre_que(func() -> bool: return coups.size() == 1, 1.0)
	if not partie.joueur_en_ejection():
		return "le Joueur devrait être en Éjection juste après le Coup"
	await taper("catch")
	if partie.joueur_etat_attrape() != "normal":
		return "aucune Fenêtre d'attrape ne devrait s'ouvrir pendant l'Éjection, état=%s" % partie.joueur_etat_attrape()
	return ""


func test_une_forte_ejection_hors_de_l_arene_coute_un_stock_et_fait_reapparaitre() -> String:
	var reglages := Reglages.new()
	reglages.pourcentage_par_coup = 400.0
	await _partie_prete(reglages)
	_tir_tendu_sur_le_joueur()
	if not await attendre_que(func() -> bool: return reapparitions.size() == 1, 4.0):
		return "le Joueur éjecté hors de l'Arène devrait réapparaître"
	if stocks_perdus.size() != 1 or partie.stocks() != 2:
		return "la sortie d'Arène devrait coûter un Stock, Stocks=%d" % partie.stocks()
	if partie.pourcentage() != 0.0:
		return "le Pourcentage devrait repartir à 0, obtenu %s" % partie.pourcentage()
	if not partie.joueur_invulnerable():
		return "le Joueur devrait être invulnérable après la Réapparition"
	if not Arene.LIMITES.has_point(partie.joueur_position()):
		return "le Joueur devrait réapparaître dans l'Arène"
	return ""


func test_un_echec_remet_le_pourcentage_a_zero_et_donne_l_invulnerabilite() -> String:
	await _partie_prete()
	_tir_tendu_sur_le_joueur()
	await secondes(1.5)
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(900.0, 300.0), Vector2.ZERO))
	await attendre_que(func() -> bool: return echecs.size() == 1, 2.0)
	if partie.pourcentage() != 0.0 or not partie.joueur_invulnerable():
		return "après un Échec : Pourcentage à 0 et Invulnérabilité attendus"
	if reapparitions.size() != 0:
		return "un Échec ne fait pas réapparaître un Joueur resté dans l'Arène"
	return ""


func _sortir_et_reapparaitre() -> void:
	var reglages := Reglages.new()
	reglages.pourcentage_par_coup = 400.0
	await _partie_prete(reglages)
	_tir_tendu_sur_le_joueur()
	await attendre_que(func() -> bool: return reapparitions.size() == 1, 4.0)
	await secondes(0.6)


func test_pendant_l_invulnerabilite_une_banane_traverse_le_joueur_puis_finit_en_echec() -> String:
	await _sortir_et_reapparaitre()
	_lacher_au_dessus_de_la_tete(80.0)
	await secondes(1.0)
	if not coups.size() == 1:
		return "aucun nouveau Coup attendu pendant l'Invulnérabilité (Coups=%d)" % coups.size()
	if echecs.size() != 1:
		return "la Banane devrait traverser le Joueur et finir en Échec"
	return ""


func test_pendant_l_invulnerabilite_l_attrape_reste_possible() -> String:
	await _sortir_et_reapparaitre()
	_lacher_au_dessus_de_la_tete(80.0)
	var tete: float = partie.joueur_position().y - HAUTEUR_JOUEUR
	await attendre_que(func() -> bool: return partie.positions_bananes().is_empty() or partie.positions_bananes()[0].y > tete - 40.0, 1.0)
	await taper("catch")
	await secondes(1.0)
	if attrapes.size() != 1:
		return "l'Attrape devrait rester possible pendant l'Invulnérabilité"
	return ""


func test_l_invulnerabilite_se_termine() -> String:
	await _sortir_et_reapparaitre()
	await secondes(Reglages.new().duree_invulnerabilite)
	if partie.joueur_invulnerable():
		return "l'Invulnérabilité devrait durer %s s" % Reglages.new().duree_invulnerabilite
	return ""


func test_une_banane_qui_touche_le_joueur_et_une_plateforme_dans_la_meme_image_est_un_coup() -> String:
	await _partie_prete()
	var pieds: Vector2 = partie.joueur_position()
	# Au ras du sol, collée au Joueur : contact avec le Joueur et la Plateforme dès la première image.
	partie.forcer_lancer(Lancer.new(Lancer.Type.TIR_TENDU, pieds + Vector2(-32.0, -8.0), Vector2(200.0, 0.0)))
	await secondes(0.5)
	if coups.size() != 1 or not echecs.is_empty():
		return "attendu un Coup et aucun Échec, obtenu %d Coup(s), %d Échec(s)" % [coups.size(), echecs.size()]
	return ""
