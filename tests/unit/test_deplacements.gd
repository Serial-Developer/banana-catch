extends "res://tests/lib/suite_partie.gd"
## Ticket 01 : déplacements du Joueur dans l'Arène.


func test_le_joueur_atterrit_sur_la_plateforme_principale_et_y_reste() -> String:
	nouvelle_partie()
	await secondes(1.5)
	if not partie.joueur_au_sol():
		return "le Joueur devrait être au sol"
	var y: float = partie.joueur_position().y
	await secondes(0.5)
	if absf(partie.joueur_position().y - y) > 0.5:
		return "le Joueur devrait rester immobile sur la Plateforme principale"
	if partie.joueur_position().y > Arene.HAUT_PRINCIPALE + 1.0:
		return "le Joueur devrait être posé sur la Plateforme principale, y=%s" % partie.joueur_position().y
	return ""


## Hauteur maximale atteinte (y minimal) pendant la durée donnée.
func _sommet_pendant(s: float) -> float:
	var sommet: float = partie.joueur_position().y
	for i: int in int(s * 60):
		await images(1)
		sommet = minf(sommet, partie.joueur_position().y)
	return sommet


func _sauter_puis_resauter(nombre_sauts_air: int) -> float:
	nouvelle_partie()
	await secondes(1.0)
	await taper("jump")
	var sommet: float = partie.joueur_position().y
	for i: int in nombre_sauts_air:
		sommet = minf(sommet, await _sommet_pendant(0.25))
		await taper("jump")
	return minf(sommet, await _sommet_pendant(1.0))


func test_le_double_saut_fait_monter_plus_haut_qu_un_saut_simple() -> String:
	var simple: float = await _sauter_puis_resauter(0)
	var double: float = await _sauter_puis_resauter(1)
	if double > simple - 50.0:
		return "le double saut devrait monter nettement plus haut (simple=%s, double=%s)" % [simple, double]
	return ""


func test_le_double_saut_ne_fonctionne_qu_une_fois_par_saut() -> String:
	var double: float = await _sauter_puis_resauter(1)
	var triple: float = await _sauter_puis_resauter(2)
	if absf(triple - double) > 1.0:
		return "un troisième saut ne devrait rien changer (double=%s, triple=%s)" % [double, triple]
	return ""


func test_le_joueur_traverse_une_plateforme_haute_en_montant_puis_en_redescend() -> String:
	nouvelle_partie()
	await secondes(1.0)
	# Sous la Plateforme haute du sommet : saut + double saut pour passer au travers.
	await taper("jump")
	await secondes(0.3)
	await taper("jump")
	await secondes(1.5)
	var haute: Rect2 = Arene.HAUTES[2]
	if not partie.joueur_au_sol() or absf(partie.joueur_position().y - haute.position.y) > 1.0:
		return "le Joueur devrait être posé sur la Plateforme haute, y=%s" % partie.joueur_position().y
	presser("down")
	await taper("jump")
	relacher("down")
	await secondes(1.5)
	if absf(partie.joueur_position().y - Arene.HAUT_PRINCIPALE) > 1.0:
		return "le Joueur devrait être redescendu sur la Plateforme principale, y=%s" % partie.joueur_position().y
	return ""


func test_le_joueur_qui_sort_de_la_plateforme_principale_tombe_dans_le_vide() -> String:
	nouvelle_partie()
	await secondes(1.0)
	presser("move_right")
	await secondes(2.5)
	relacher("move_right")
	if partie.joueur_position().y < 800.0:
		return "le Joueur devrait tomber dans le vide, y=%s" % partie.joueur_position().y
	return ""


func test_le_dash_deplace_plus_vite_que_la_course() -> String:
	nouvelle_partie()
	await secondes(1.0)
	var depart: float = partie.joueur_position().x
	await taper("dash")
	await secondes(0.15)
	var distance_dash: float = partie.joueur_position().x - depart
	var course: float = Reglages.new().vitesse_course * 0.18
	if distance_dash < course * 1.5:
		return "le dash devrait parcourir bien plus que la course (dash=%s)" % distance_dash
	return ""
