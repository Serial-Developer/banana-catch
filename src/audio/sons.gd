class_name Sons
extends Node
## Effets sonores synthétisés par code (aucun fichier audio), joués en réaction aux signaux de la Partie.
## Aucune logique de jeu ici.

const FREQUENCE: int = 22050
const VOIX: int = 10

## Sons générés une seule fois, partagés entre les Parties.
static var _banque: Dictionary = {}

var partie: Partie
var reglages: Reglages

var _voix: Array[AudioStreamPlayer] = []


func _ready() -> void:
	if _banque.is_empty():
		_generer_banque()
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


## Joue un son de la banque sur une voix libre (sinon la plus ancienne est réutilisée).
func jouer(nom: String, gain_db: float = 0.0, hauteur: float = 1.0) -> void:
	var lecteur: AudioStreamPlayer = _voix[0]
	for v: AudioStreamPlayer in _voix:
		if not v.playing:
			lecteur = v
			break
	_voix.erase(lecteur)
	_voix.append(lecteur)
	lecteur.stream = _banque[nom]
	# Marge de -6 dB pour que plusieurs sons simultanés ne saturent pas.
	lecteur.volume_db = linear_to_db(maxf(reglages.volume, 0.0001)) - 6.0 + gain_db
	lecteur.pitch_scale = hauteur
	lecteur.play()


static func _generer_banque() -> void:
	var bruit := RandomNumberGenerator.new()
	bruit.seed = 1234
	_banque["lancer"] = _synthetiser(0.28, func(t: float, d: float) -> float:
		# Souffle : bruit filtré dont l'enveloppe monte puis retombe.
		return bruit.randf_range(-1.0, 1.0) * sin(PI * t / d) * 0.5, 0.15)
	_banque["attrape"] = _synthetiser(0.4, func(t: float, _d: float) -> float:
		var f: float = 1320.0 + 200.0 * minf(t * 20.0, 1.0)
		return (sin(TAU * f * t) * 0.6 + sin(TAU * f * 1.5 * t) * 0.3) * exp(-t * 9.0))
	_banque["coup"] = _synthetiser(0.3, func(t: float, _d: float) -> float:
		var f: float = lerpf(170.0, 55.0, minf(t / 0.2, 1.0))
		return (sin(TAU * f * t) * 0.6 + bruit.randf_range(-1.0, 1.0) * 0.3 * exp(-t * 40.0)) * exp(-t * 10.0))
	_banque["echec"] = _synthetiser(0.32, func(t: float, _d: float) -> float:
		return bruit.randf_range(-1.0, 1.0) * exp(-t * 12.0) * 0.8, 0.35)
	_banque["stock_perdu"] = _synthetiser(0.9, func(t: float, _d: float) -> float:
		return (bruit.randf_range(-1.0, 1.0) * 0.6 + sin(TAU * 48.0 * t) * 0.35) * exp(-t * 4.0), 0.5)
	_banque["reapparition"] = _synthetiser(0.45, func(t: float, _d: float) -> float:
		var notes: Array[float] = [523.25, 659.25, 783.99]
		var i: int = mini(int(t / 0.15), 2)
		var local: float = t - i * 0.15
		return signf(sin(TAU * notes[i] * t)) * 0.25 * exp(-local * 10.0))


## Génère un son 16 bits mono. `lissage` (0..1) applique un filtre passe-bas simple (0 = aucun).
static func _synthetiser(duree: float, onde: Callable, lissage: float = 0.0) -> AudioStreamWAV:
	var nombre: int = int(duree * FREQUENCE)
	var donnees := PackedByteArray()
	donnees.resize(nombre * 2)
	var precedent: float = 0.0
	for i: int in nombre:
		var t: float = float(i) / FREQUENCE
		var valeur: float = onde.call(t, duree)
		if lissage > 0.0:
			valeur = lerpf(valeur, precedent, lissage)
			precedent = valeur
		# Fondu de 5 ms en fin de son pour éviter un clic.
		valeur *= clampf((duree - t) / 0.005, 0.0, 1.0)
		donnees.encode_s16(i * 2, int(clampf(valeur, -1.0, 1.0) * 32000.0))
	var son := AudioStreamWAV.new()
	son.format = AudioStreamWAV.FORMAT_16_BITS
	son.mix_rate = FREQUENCE
	son.stereo = false
	son.data = donnees
	return son
