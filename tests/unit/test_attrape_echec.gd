extends "res://tests/lib/suite_partie.gd"
## Ticket 02 : Bananes, Attrape, Échec et boucle de Partie minimale.

const HAUTEUR_JOUEUR: float = 64.0
const X_DEGAGE: float = 285.0

var attrapes: Array
var echecs: Array
var stocks_perdus: Array
var fins: Array
var coups: Array


func _partie_prete() -> void:
	nouvelle_partie()
	attrapes = espionner("attrape")
	echecs = espionner("echec")
	stocks_perdus = espionner("stock_perdu")
	fins = espionner("fin_de_partie")
	coups = espionner("coup")
	await secondes(1.0)
	# À gauche de l'Arène, aucune Plateforme haute au-dessus du Joueur.
	await aller_vers(X_DEGAGE)


## Lâche une Banane à la verticale, au-dessus de la tête du Joueur.
func _lacher_sur_le_joueur(hauteur: float = 300.0) -> void:
	var pieds: Vector2 = partie.joueur_position()
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, pieds + Vector2(0.0, -HAUTEUR_JOUEUR - hauteur), Vector2.ZERO))


## Attend que la première Banane en vol soit à moins de `marge` pixels au-dessus de la tête du Joueur.
func _attendre_banane_proche(marge: float) -> bool:
	var tete: float = partie.joueur_position().y - HAUTEUR_JOUEUR
	return await attendre_que(func() -> bool:
		var positions: Array[Vector2] = partie.positions_bananes()
		return positions.is_empty() or positions[0].y > tete - marge)


func test_un_appui_juste_avant_le_contact_au_sol_donne_une_attrape() -> String:
	await _partie_prete()
	_lacher_sur_le_joueur()
	await _attendre_banane_proche(60.0)
	await taper("catch")
	await secondes(1.5)
	if attrapes.size() != 1 or partie.score() != 1:
		return "attendu 1 Attrape et Score 1, obtenu %d Attrape(s), Score %d" % [attrapes.size(), partie.score()]
	if not echecs.is_empty() or partie.nombre_bananes_en_vol() != 0:
		return "la Banane attrapée ne devrait ni causer d'Échec ni rester en vol"
	return ""


func test_une_attrape_en_l_air_au_dessus_du_vide_fonctionne() -> String:
	await _partie_prete()
	presser("move_left")
	if not await attendre_que(func() -> bool: return partie.joueur_position().x < Arene.PRINCIPALE.position.x + 30.0):
		return "le Joueur n'atteint pas le bord"
	await taper("jump")
	if not await attendre_que(func() -> bool: return partie.joueur_position().x < Arene.PRINCIPALE.position.x - 30.0):
		return "le Joueur ne passe pas au-dessus du vide"
	relacher("move_left")
	if partie.joueur_au_sol():
		return "le Joueur devrait être en l'air"
	presser("catch")
	await images(1)
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, partie.joueur_position() + Vector2(0.0, -HAUTEUR_JOUEUR / 2.0), Vector2.ZERO))
	await images(2)
	relacher("catch")
	if attrapes.size() != 1:
		return "attendu une Attrape en l'air au-dessus du vide, obtenu %d" % attrapes.size()
	return ""


func test_un_appui_trop_tot_mene_a_la_recuperation_puis_pas_d_attrape() -> String:
	await _partie_prete()
	_lacher_sur_le_joueur(400.0)
	await taper("catch")
	await secondes(0.3)
	if partie.joueur_etat_attrape() != "recuperation":
		return "le Joueur devrait être en Récupération, état=%s" % partie.joueur_etat_attrape()
	await secondes(2.0)
	if not attrapes.is_empty():
		return "aucune Attrape attendue après un appui trop tôt"
	if coups.size() != 1 or not echecs.is_empty():
		return "la Banane non attrapée devrait être un Coup (Coups=%d, Échecs=%d)" % [coups.size(), echecs.size()]
	return ""


func test_appuyer_pendant_la_recuperation_n_ouvre_pas_de_fenetre_d_attrape() -> String:
	await _partie_prete()
	await taper("catch")
	await secondes(0.25)
	if partie.joueur_etat_attrape() != "recuperation":
		return "le Joueur devrait être en Récupération"
	await taper("catch")
	if partie.joueur_etat_attrape() != "recuperation":
		return "un appui pendant la Récupération ne devrait rien ouvrir, état=%s" % partie.joueur_etat_attrape()
	await secondes(0.5)
	if partie.joueur_etat_attrape() != "normal":
		return "la Récupération devrait se terminer"
	return ""


func test_apres_une_attrape_une_deuxieme_banane_peut_etre_attrapee_immediatement() -> String:
	await _partie_prete()
	_lacher_sur_le_joueur(300.0)
	_lacher_sur_le_joueur(380.0)
	await _attendre_banane_proche(60.0)
	await taper("catch")
	if not await attendre_que(func() -> bool: return attrapes.size() == 1, 1.0):
		return "la première Banane devrait être attrapée"
	if partie.joueur_etat_attrape() != "normal":
		return "une Attrape ne devrait pas déclencher de Récupération, état=%s" % partie.joueur_etat_attrape()
	await _attendre_banane_proche(60.0)
	await taper("catch")
	await secondes(1.5)
	if attrapes.size() != 2 or partie.score() != 2:
		return "attendu 2 Attrapes, obtenu %d" % attrapes.size()
	return ""


func _lacher_loin_du_joueur(x: float) -> void:
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(x, 0.0), Vector2.ZERO))


func test_une_banane_sur_la_plateforme_principale_est_un_echec_qui_coute_un_stock() -> String:
	await _partie_prete()
	_lacher_loin_du_joueur(900.0)
	await secondes(2.0)
	if echecs.size() != 1 or partie.stocks() != 2:
		return "attendu 1 Échec et 2 Stocks, obtenu %d Échec(s), %d Stocks" % [echecs.size(), partie.stocks()]
	if stocks_perdus.size() != 1 or stocks_perdus[0][0] != 2:
		return "le signal Stock perdu devrait annoncer 2 Stocks restants"
	if partie.nombre_bananes_en_vol() != 0:
		return "la Banane devrait avoir disparu"
	return ""


func test_une_banane_traverse_une_plateforme_haute_puis_finit_en_echec_sur_la_principale() -> String:
	await _partie_prete()
	var x: float = Arene.HAUTES[0].get_center().x
	_lacher_loin_du_joueur(x)
	await attendre_que(func() -> bool: return partie.positions_bananes().is_empty() or partie.positions_bananes()[0].y > Arene.HAUTES[0].end.y + 20.0, 2.0)
	if not echecs.is_empty():
		return "la Banane devrait traverser la Plateforme haute"
	await secondes(1.0)
	if echecs.size() != 1:
		return "attendu 1 Échec sur la Plateforme principale"
	return ""


func test_une_banane_dans_le_vide_est_un_echec() -> String:
	await _partie_prete()
	_lacher_loin_du_joueur(100.0)
	await secondes(3.0)
	if echecs.size() != 1:
		return "attendu 1 Échec pour une Banane tombée dans le vide, obtenu %d" % echecs.size()
	return ""


func test_trois_echecs_terminent_la_partie() -> String:
	await _partie_prete()
	for x: float in [700.0, 900.0, 1000.0]:
		_lacher_loin_du_joueur(x)
		await secondes(1.5)
	if fins.size() != 1:
		return "attendu un signal Fin de Partie, obtenu %d" % fins.size()
	if partie.stocks() != 0 or not partie.terminee():
		return "la Partie devrait être terminée avec 0 Stock"
	return ""


func test_chaque_banane_n_a_qu_une_seule_issue() -> String:
	await _partie_prete()
	_lacher_sur_le_joueur()
	await _attendre_banane_proche(60.0)
	await taper("catch")
	_lacher_loin_du_joueur(900.0)
	await secondes(3.0)
	if attrapes.size() != 1 or echecs.size() != 1:
		return "attendu exactement 1 Attrape et 1 Échec, obtenu %d et %d" % [attrapes.size(), echecs.size()]
	return ""


func test_l_echec_et_l_attrape_indiquent_ou_ils_ont_lieu() -> String:
	await _partie_prete()
	_lacher_loin_du_joueur(900.0)
	await secondes(2.0)
	var lieu_echec: Vector2 = echecs[0][0]
	if absf(lieu_echec.x - 900.0) > 1.0 or absf(lieu_echec.y - Arene.HAUT_PRINCIPALE) > 20.0:
		return "l'Échec devrait être situé sur la Plateforme principale en x=900, obtenu %s" % lieu_echec
	_lacher_sur_le_joueur()
	await _attendre_banane_proche(60.0)
	await taper("catch")
	await secondes(1.0)
	var lieu_attrape: Vector2 = attrapes[0][0]
	if lieu_attrape.distance_to(partie.joueur_position()) > 100.0:
		return "l'Attrape devrait être située près du Joueur, obtenu %s" % lieu_attrape
	return ""
