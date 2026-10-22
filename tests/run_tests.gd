extends SceneTree
## Lanceur de tests sans affichage. Usage : ./tools/godot.sh tests
## Exécute chaque méthode « test_* » des fichiers res://tests/unit/test_*.gd.
## Un test renvoie "" en cas de succès, un message sinon ; il peut être asynchrone (await).
## Code de sortie 0 = tout passe, 1 = au moins un échec.

const DOSSIER_TESTS: String = "res://tests/unit"
const CompteurErreurs = preload("res://tests/lib/compteur_erreurs.gd")


func _initialize() -> void:
	# Une image pour laisser les autoloads finir leur _ready().
	await process_frame
	var erreurs := CompteurErreurs.new()
	OS.add_logger(erreurs)
	var reussis: int = 0
	var echoues: int = 0
	var filtre: String = OS.get_environment("FILTRE_TESTS")
	var fichiers: PackedStringArray = DirAccess.get_files_at(DOSSIER_TESTS)
	fichiers.sort()
	for nom_fichier: String in fichiers:
		if not (nom_fichier.begins_with("test_") and nom_fichier.ends_with(".gd")):
			continue
		if filtre != "" and not nom_fichier.contains(filtre):
			continue
		var script: GDScript = load(DOSSIER_TESTS.path_join(nom_fichier))
		if script == null or not script.can_instantiate():
			echoues += 1
			print("  FAIL %s | le script ne se charge pas" % nom_fichier)
			continue
		for m: Dictionary in script.get_script_method_list():
			var nom: String = m["name"]
			if not nom.begins_with("test_"):
				continue
			# Une instance neuve par test : aucun état partagé entre tests.
			erreurs.vider()
			var suite: Node = script.new()
			root.add_child(suite)
			var resultat: Variant = await suite.call(nom)
			var survenues: PackedStringArray = erreurs.vider()
			if not survenues.is_empty():
				resultat = "erreur pendant le test : %s" % survenues[0]
			if resultat is String and resultat == "":
				reussis += 1
				print("  PASS %s::%s" % [nom_fichier, nom])
			else:
				echoues += 1
				print("  FAIL %s::%s | %s" % [nom_fichier, nom, str(resultat)])
			suite.queue_free()
			await process_frame
	print("RESULT: %d passed, %d failed" % [reussis, echoues])
	quit(1 if echoues > 0 or reussis == 0 else 0)
