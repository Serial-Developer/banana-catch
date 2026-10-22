extends "res://tests/lib/suite_partie.gd"
## Ticket 04 : le Singe et ses Lancers.


## Lance une Partie avec le Singe actif et un Joueur immobile ; renvoie les Lancers [type, instant].
func _observer_lancers(graine: int, duree_s: float) -> Array:
	var reglages := Reglages.new()
	reglages.stocks_depart = 999
	nouvelle_partie(reglages, graine, 0, true)
	var lancers: Array = []
	var p: Partie = partie
	partie.lancer.connect(func(type: Lancer.Type) -> void: lancers.append([type, snappedf(p.temps_ecoule(), 0.001)]))
	await secondes(duree_s)
	partie.queue_free()
	await images(1)
	return lancers


func test_avec_la_meme_graine_le_singe_fait_les_memes_lancers() -> String:
	var premiers: Array = await _observer_lancers(42, 20.0)
	var seconds: Array = await _observer_lancers(42, 20.0)
	if premiers.size() < 5:
		return "le Singe devrait lancer régulièrement (%d Lancers en 20 s)" % premiers.size()
	if premiers != seconds:
		return "même graine, mêmes entrées : la suite de Lancers devrait être identique"
	var autre: Array = await _observer_lancers(7, 20.0)
	if autre == premiers:
		return "une autre graine devrait donner une autre suite de Lancers"
	return ""


func test_sur_un_grand_nombre_de_lancers_les_trois_types_apparaissent() -> String:
	var lancers: Array = await _observer_lancers(3, 90.0)
	var types: Dictionary = {}
	for l: Array in lancers:
		types[l[0]] = true
	if types.size() != 3:
		return "les trois types de Lancer devraient apparaître (%d Lancers, types=%s)" % [lancers.size(), types.keys()]
	return ""


## Durée moyenne entre un Lancer du type donné et la résolution de sa Banane (Joueur immobile).
func _duree_de_vol_moyenne(type_vise: Lancer.Type) -> float:
	var reglages := Reglages.new()
	reglages.stocks_depart = 999
	nouvelle_partie(reglages, 11, 0, true)
	await aller_vers(285.0)
	# Les lambdas capturent les variables locales par valeur : on accumule dans un dictionnaire.
	var cumul: Dictionary = {"total": 0.0, "nombre": 0}
	var en_cours: Array = []  # [type, instant] de la Banane en vol
	var p: Partie = partie
	partie.lancer.connect(func(type: Lancer.Type) -> void: en_cours.append([type, p.temps_ecoule()]))
	var resoudre: Callable = func() -> void:
		if en_cours.is_empty():
			return
		var l: Array = en_cours.pop_front()
		if l[0] == type_vise:
			cumul.total += p.temps_ecoule() - l[1]
			cumul.nombre += 1
	partie.attrape.connect(resoudre)
	partie.coup.connect(func(_pourcentage: float) -> void: resoudre.call())
	partie.echec.connect(resoudre)
	await secondes(120.0)
	partie.queue_free()
	await images(1)
	return cumul.total / cumul.nombre if cumul.nombre > 0 else INF


func test_un_tir_tendu_atteint_le_joueur_plus_vite_qu_un_lob() -> String:
	var tir_tendu: float = await _duree_de_vol_moyenne(Lancer.Type.TIR_TENDU)
	var lob: float = await _duree_de_vol_moyenne(Lancer.Type.LOB)
	if tir_tendu == INF or lob == INF:
		return "pas assez de Lancers observés"
	if tir_tendu >= lob * 0.6:
		return "un Tir tendu devrait arriver bien plus vite qu'un Lob (tir=%s s, lob=%s s)" % [tir_tendu, lob]
	return ""


func test_les_lancers_du_singe_visent_le_joueur() -> String:
	var reglages := Reglages.new()
	reglages.stocks_depart = 999
	nouvelle_partie(reglages, 5, 0, true)
	# Hors de l'abri des Plateformes hautes.
	await aller_vers(285.0)
	var coups: Array = espionner("coup")
	var echecs: Array = espionner("echec")
	await secondes(60.0)
	# Joueur immobile : la plupart des Bananes doivent le toucher.
	if coups.size() < echecs.size() * 2:
		return "la plupart des Lancers devraient atteindre le Joueur (Coups=%d, Échecs=%d)" % [coups.size(), echecs.size()]
	return ""


func test_le_joueur_traverse_le_singe_sans_coup() -> String:
	nouvelle_partie()
	var coups: Array = espionner("coup")
	await secondes(1.0)
	var singe: Vector2 = partie.singe_position()
	await aller_vers(singe.x + 60.0)
	if partie.joueur_position().x < singe.x + 40.0:
		return "le Joueur devrait avoir traversé le Singe"
	if not coups.is_empty() or partie.pourcentage() != 0.0:
		return "traverser le Singe ne devrait causer aucun Coup"
	return ""
