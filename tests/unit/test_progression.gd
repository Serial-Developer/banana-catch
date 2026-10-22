extends "res://tests/lib/suite_partie.gd"
## Ticket 05 : progression de la Cadence, des Bananes simultanées et du mélange des Lancers.

const SCORE_ELEVE: int = 30


## Partie avec le Singe actif ; le Joueur marque `score` Attrapes puis reste immobile pendant `duree_s`.
## Renvoie {lancers: [type...], max_en_vol: int}.
func _observer(score: int, duree_s: float, graine: int = 9) -> Dictionary:
	var reglages := Reglages.new()
	reglages.stocks_depart = 9999
	nouvelle_partie(reglages, graine, 0, true)
	await secondes(1.0)
	await marquer(score)
	if partie.score() != score:
		push_error("le Score devrait valoir %d, obtenu %d" % [score, partie.score()])
	var observe: Dictionary = {"lancers": [], "max_en_vol": 0}
	partie.lancer.connect(func(type: Lancer.Type) -> void: observe.lancers.append(type))
	for i: int in int(duree_s * 60.0):
		await images(1)
		observe.max_en_vol = maxi(observe.max_en_vol, partie.nombre_bananes_en_vol())
	partie.queue_free()
	await images(1)
	return observe


func test_la_cadence_est_plus_rapide_a_score_eleve() -> String:
	var debut: Dictionary = await _observer(0, 40.0)
	var eleve: Dictionary = await _observer(SCORE_ELEVE, 40.0)
	if eleve.lancers.size() < debut.lancers.size() * 1.5:
		return "il devrait y avoir bien plus de Lancers à Score élevé (Score 0 : %d, Score %d : %d)" % [debut.lancers.size(), SCORE_ELEVE, eleve.lancers.size()]
	return ""


func test_a_score_zero_il_n_y_a_jamais_plus_d_une_banane_en_vol() -> String:
	var debut: Dictionary = await _observer(0, 40.0)
	if debut.max_en_vol != 1:
		return "au premier palier, une seule Banane en vol au maximum (observé : %d)" % debut.max_en_vol
	return ""


func test_au_dernier_palier_jusqu_a_trois_bananes_sont_en_vol_et_jamais_plus() -> String:
	var eleve: Dictionary = await _observer(SCORE_ELEVE, 60.0)
	if eleve.max_en_vol != 3:
		return "au dernier palier, attendu 3 Bananes en vol au maximum (observé : %d)" % eleve.max_en_vol
	return ""


func _part_tirs_tendus_et_lobs(lancers: Array) -> float:
	var nombre: int = 0
	for type: Lancer.Type in lancers:
		if type != Lancer.Type.ARC:
			nombre += 1
	return float(nombre) / maxf(lancers.size(), 1.0)


func test_les_tirs_tendus_et_les_lobs_sont_plus_frequents_au_dernier_palier() -> String:
	var debut: Dictionary = await _observer(0, 90.0, 21)
	var eleve: Dictionary = await _observer(SCORE_ELEVE, 60.0, 21)
	var part_debut: float = _part_tirs_tendus_et_lobs(debut.lancers)
	var part_eleve: float = _part_tirs_tendus_et_lobs(eleve.lancers)
	if part_eleve < part_debut + 0.15:
		return "la part de Tirs tendus et de Lobs devrait augmenter (début %.2f, fin %.2f)" % [part_debut, part_eleve]
	return ""
