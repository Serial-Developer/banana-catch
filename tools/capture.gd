extends SceneTree
## Outil de vérification visuelle : lance le jeu, joue un scénario et enregistre des captures d'écran.
## Usage : ./tools/godot.sh capture <dossier>  (nécessite un affichage, pas de --headless)

var _dossier: String


func _initialize() -> void:
	_dossier = OS.get_environment("DOSSIER_CAPTURES")
	if _dossier == "":
		_dossier = OS.get_user_data_dir()
	var jeu: Node = load("res://scenes/jeu.tscn").instantiate()
	root.add_child(jeu)
	await _attendre(30)
	await _capturer("1_titre")
	(jeu as Jeu).call("_lancer_partie")
	await _attendre(90)
	var partie: Partie = jeu.get("_partie")
	var singe: Singe = partie.get("_singe")
	for type: int in 3:
		var limite: int = 4000
		while limite > 0 and is_instance_valid(singe) and not (singe.etat() == Singe.Etat.ELAN and singe.type_en_preparation() == type and singe.get("_temps") > 0.15):
			await process_frame
			limite -= 1
		if not is_instance_valid(singe):
			break
		await _capturer("1b_elan_%d" % type)
	if not is_instance_valid(singe):
		push_warning("capture : la Partie s'est arrêtée avant les captures de jeu")
		quit()
		return
	singe.actif = false
	partie.forcer_lancer(Lancer.new(Lancer.Type.LOB, Vector2(300.0, 200.0), Vector2(0.0, -900.0)))
	await _attendre(20)
	await _capturer("2_partie_lob_hors_ecran")
	var pieds: Vector2 = partie.joueur_position()
	partie.forcer_lancer(Lancer.new(Lancer.Type.TIR_TENDU, pieds + Vector2(-200.0, -40.0), Vector2(900.0, 0.0)))
	await _attendre(16)
	await _capturer("2b_coup")
	await _attendre(150)
	Input.action_press("catch")
	await _attendre(3)
	await _capturer("2c_fenetre_attrape")
	Input.action_release("catch")
	partie.mettre_en_pause(true)
	await _attendre(10)
	await _capturer("3_pause")
	partie.mettre_en_pause(false)
	for i: int in 3:
		partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(950.0 + i * 20.0, 450.0), Vector2.ZERO))
		await _attendre(40)
	await _attendre(200)
	await _capturer("4_fin")
	quit()


func _attendre(images: int) -> void:
	for i: int in images:
		await process_frame


func _capturer(nom: String) -> void:
	await RenderingServer.frame_post_draw
	var chemin: String = _dossier.path_join(nom + ".png")
	root.get_texture().get_image().save_png(chemin)
	print("capture : ", chemin)
