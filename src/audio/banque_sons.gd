extends Node
## Autoload : effets sonores synthétisés par code (aucun fichier audio), générés une seule fois au démarrage.
## En autoload plutôt qu'en variable statique pour être libérés proprement à la fermeture.

const FREQUENCE: int = 22050

var _sons: Dictionary = {}


func _ready() -> void:
	_generer()


func son(nom: String) -> AudioStreamWAV:
	return _sons[nom]


func _generer() -> void:
	var bruit := RandomNumberGenerator.new()
	bruit.seed = 1234
	_sons["lancer"] = _synthetiser(0.28, func(t: float, d: float) -> float:
		# Souffle : bruit filtré dont l'enveloppe monte puis retombe.
		return bruit.randf_range(-1.0, 1.0) * sin(PI * t / d) * 0.5, 0.15)
	_sons["attrape"] = _synthetiser(0.4, func(t: float, _d: float) -> float:
		var f: float = 1320.0 + 200.0 * minf(t * 20.0, 1.0)
		return (sin(TAU * f * t) * 0.6 + sin(TAU * f * 1.5 * t) * 0.3) * exp(-t * 9.0))
	_sons["coup"] = _synthetiser(0.3, func(t: float, _d: float) -> float:
		var f: float = lerpf(170.0, 55.0, minf(t / 0.2, 1.0))
		return (sin(TAU * f * t) * 0.6 + bruit.randf_range(-1.0, 1.0) * 0.3 * exp(-t * 40.0)) * exp(-t * 10.0))
	_sons["echec"] = _synthetiser(0.32, func(t: float, _d: float) -> float:
		return bruit.randf_range(-1.0, 1.0) * exp(-t * 12.0) * 0.8, 0.35)
	_sons["stock_perdu"] = _synthetiser(0.9, func(t: float, _d: float) -> float:
		return (bruit.randf_range(-1.0, 1.0) * 0.6 + sin(TAU * 48.0 * t) * 0.35) * exp(-t * 4.0), 0.5)
	_sons["reapparition"] = _synthetiser(0.45, func(t: float, _d: float) -> float:
		var notes: Array[float] = [523.25, 659.25, 783.99]
		var i: int = mini(int(t / 0.15), 2)
		var local: float = t - i * 0.15
		return signf(sin(TAU * notes[i] * t)) * 0.25 * exp(-local * 10.0))


## Génère un son 16 bits mono. `lissage` (0..1) applique un filtre passe-bas simple (0 = aucun).
func _synthetiser(duree: float, onde: Callable, lissage: float = 0.0) -> AudioStreamWAV:
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
