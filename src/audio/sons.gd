class_name Sons
extends Node
## Effets sonores joués en réaction aux signaux de la Partie (sons fournis par l'autoload BanqueSons).
## Aucune logique de jeu ici.

const VOIX: int = 10

var partie: Partie
var reglages: Reglages

var _voix: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i: int in VOIX:
		var lecteur := AudioStreamPlayer.new()
		add_child(lecteur)
		_voix.append(lecteur)
	partie.lancer.connect(func(_type: Lancer.Type) -> void: jouer("lancer"))
	partie.attrape.connect(func(_lieu: Vector2) -> void: jouer("attrape", 0.0, 1.0 + minf(partie.score() * 0.01, 0.3)))
	partie.coup.connect(func(pourcentage: float) -> void: jouer("coup", minf(pourcentage * 0.04, 6.0), 1.0 - minf(pourcentage * 0.002, 0.3)))
	partie.echec.connect(func(_lieu: Vector2) -> void: jouer("echec"))
	partie.stock_perdu.connect(func(_restants: int) -> void: jouer("stock_perdu"))
	partie.reapparition.connect(func() -> void: jouer("reapparition"))


func _exit_tree() -> void:
	# Arrêt explicite : sinon le serveur audio garde les lectures en cours (fuites à la fermeture).
	for lecteur: AudioStreamPlayer in _voix:
		lecteur.stop()


## Joue un son de la banque sur une voix libre (sinon la plus ancienne est réutilisée).
## Sans affichage (tests), aucun son n'est joué : le pilote audio factice ne libère jamais les lectures.
func jouer(nom: String, gain_db: float = 0.0, hauteur: float = 1.0) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var lecteur: AudioStreamPlayer = _voix[0]
	for v: AudioStreamPlayer in _voix:
		if not v.playing:
			lecteur = v
			break
	_voix.erase(lecteur)
	_voix.append(lecteur)
	# Recherche à l'exécution : ce script peut être compilé avant l'enregistrement des autoloads (outils -s).
	lecteur.stream = get_node("/root/BanqueSons").son(nom)
	# Marge de -6 dB pour que plusieurs sons simultanés ne saturent pas.
	lecteur.volume_db = linear_to_db(maxf(reglages.volume, 0.0001)) - 6.0 + gain_db
	lecteur.pitch_scale = hauteur
	lecteur.play()
