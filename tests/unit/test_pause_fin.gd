extends "res://tests/lib/suite_partie.gd"
## Ticket 06 : pause et Fin de Partie (record battu ou non).


func _finir_avec(score: int, meilleur_score: int) -> Array:
	nouvelle_partie(null, 1, meilleur_score)
	var fins: Array = espionner("fin_de_partie")
	await secondes(1.0)
	await marquer(score)
	for x: float in [700.0, 900.0, 1000.0]:
		partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(x, 450.0), Vector2.ZERO))
		await secondes(0.6)
	return fins


func test_la_fin_de_partie_annonce_un_record_battu() -> String:
	var fins: Array = await _finir_avec(3, 2)
	if fins.size() != 1 or fins[0] != [3, true]:
		return "attendu fin_de_partie(3, true), obtenu %s" % [fins]
	return ""


func test_la_fin_de_partie_annonce_un_record_non_battu() -> String:
	var fins: Array = await _finir_avec(3, 5)
	if fins.size() != 1 or fins[0] != [3, false]:
		return "attendu fin_de_partie(3, false), obtenu %s" % [fins]
	return ""


func test_egaler_le_meilleur_score_ne_le_bat_pas() -> String:
	var fins: Array = await _finir_avec(2, 2)
	if fins.size() != 1 or fins[0] != [2, false]:
		return "attendu fin_de_partie(2, false), obtenu %s" % [fins]
	return ""


func test_la_pause_fige_les_bananes_en_vol() -> String:
	nouvelle_partie()
	var changements: Array = espionner("pause_changee")
	await secondes(1.0)
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(900.0, 100.0), Vector2(0.0, 0.0)))
	await images(5)
	await taper("pause")
	if not partie.en_pause() or changements.size() != 1:
		return "la Partie devrait être en pause"
	var avant: Array[Vector2] = partie.positions_bananes()
	await secondes(1.0)
	if partie.positions_bananes() != avant:
		return "les Bananes devraient être figées pendant la pause"
	await taper("pause")
	if partie.en_pause():
		return "un second appui sur pause devrait reprendre la Partie"
	await images(3)
	if partie.positions_bananes() == avant:
		return "les Bananes devraient repartir après la pause"
	return ""


func test_la_pause_fige_la_fenetre_d_attrape() -> String:
	nouvelle_partie()
	await secondes(1.0)
	await taper("catch")
	await taper("pause")
	await secondes(1.0)
	if partie.joueur_etat_attrape() != "fenetre":
		return "la Fenêtre d'attrape ne devrait pas s'écouler pendant la pause, état=%s" % partie.joueur_etat_attrape()
	partie.mettre_en_pause(false)
	await secondes(0.3)
	if partie.joueur_etat_attrape() != "recuperation":
		return "la Fenêtre d'attrape devrait reprendre son cours après la pause"
	return ""


func test_le_singe_ne_lance_pas_pendant_la_pause() -> String:
	nouvelle_partie(null, 1, 0, true)
	var lancers: Array = espionner("lancer")
	await images(2)
	partie.mettre_en_pause(true)
	await secondes(10.0)
	if not lancers.is_empty():
		return "le Singe ne devrait pas lancer pendant la pause"
	return ""
