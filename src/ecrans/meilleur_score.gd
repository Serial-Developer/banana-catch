class_name MeilleurScore
extends RefCounted
## Lecture et sauvegarde du Meilleur score dans le dossier utilisateur Godot.

const CHEMIN: String = "user://meilleur_score.cfg"


static func lire(chemin: String = CHEMIN) -> int:
	var fichier := ConfigFile.new()
	if fichier.load(chemin) != OK:
		return 0
	return int(fichier.get_value("banana_catch", "meilleur_score", 0))


static func ecrire(score: int, chemin: String = CHEMIN) -> void:
	var fichier := ConfigFile.new()
	fichier.set_value("banana_catch", "meilleur_score", score)
	fichier.save(chemin)
