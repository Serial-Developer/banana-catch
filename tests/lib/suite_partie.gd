extends Node
## Base des suites de tests : crée une Partie sans affichage et la pilote par actions d'entrée simulées.

const ACTIONS: Array[String] = ["move_left", "move_right", "down", "jump", "catch", "dash", "pause"]

var partie: Partie


func nouvelle_partie(reglages: Reglages = null, graine: int = 1, meilleur_score: int = 0) -> Partie:
	partie = Partie.creer(reglages, graine, meilleur_score)
	add_child(partie)
	return partie


func _exit_tree() -> void:
	for action: String in ACTIONS:
		Input.action_release(action)


func images(n: int) -> void:
	for i: int in n:
		await get_tree().physics_frame


func secondes(s: float) -> void:
	await images(int(round(s * Engine.physics_ticks_per_second)))


func presser(action: String) -> void:
	Input.action_press(action)


func relacher(action: String) -> void:
	Input.action_release(action)


## Appui bref : pressé pendant n images puis relâché.
func taper(action: String, n: int = 2) -> void:
	presser(action)
	await images(n)
	relacher(action)


## Attend jusqu'à ce que la condition soit vraie (max en secondes). Renvoie false si délai dépassé.
func attendre_que(condition: Callable, max_s: float = 3.0) -> bool:
	var restant: int = int(max_s * Engine.physics_ticks_per_second)
	while restant > 0:
		if condition.call():
			return true
		await get_tree().physics_frame
		restant -= 1
	return condition.call()


## Enregistre les émissions d'un signal de la Partie.
func espionner(nom_signal: String) -> Array:
	var recus: Array = []
	partie.connect(nom_signal, func(a: Variant = null, b: Variant = null) -> void: recus.append([a, b]))
	return recus
