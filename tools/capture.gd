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
	partie.forcer_lancer(Lancer.new(Lancer.Type.ARC, Vector2(600.0, 300.0), Vector2(60.0, -100.0)))
	await _attendre(150)
	await _capturer("2_partie")
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
