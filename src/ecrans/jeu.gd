class_name Jeu
extends Node
## Parcours complet : écran titre → Partie (HUD, pause) → écran de fin. Seule couche qui écrit le Meilleur score.

const DELAI_ECRAN_FIN: float = 1.2

var _meilleur_score: int = 0
var _partie: Partie
var _hud: Hud
var _calque: CanvasLayer


func _ready() -> void:
	_meilleur_score = MeilleurScore.lire()
	_calque = CanvasLayer.new()
	_calque.layer = 10
	add_child(_calque)
	_afficher_titre()


func _vider_calque() -> void:
	for enfant: Node in _calque.get_children():
		enfant.queue_free()


func _afficher_titre() -> void:
	_quitter_partie()
	_vider_calque()
	var colonne: VBoxContainer = Ui.panneau_centre(_calque)
	colonne.add_child(Ui.etiquette("BANANA CATCH", 96, Ui.COULEUR_ACCENT))
	colonne.add_child(Ui.etiquette("Attrape les Bananes du Singe !", 32))
	colonne.add_child(Ui.etiquette("Meilleur score : %d" % _meilleur_score, 36))
	colonne.add_child(Ui.etiquette(
		"Clavier : ←→ / QD bouger · ↑ / Z / Espace sauter · J / X attraper · K / C / Maj dash · Échap pause\n"
		+ "Manette : stick / croix bouger · A sauter · B attraper · RB dash · Start pause", 20, Color(0.85, 0.85, 0.95)))
	var jouer: Button = Ui.bouton("Jouer", _lancer_partie)
	colonne.add_child(jouer)
	jouer.grab_focus.call_deferred()


func _lancer_partie() -> void:
	_quitter_partie()
	_vider_calque()
	_partie = Partie.creer(null, randi(), _meilleur_score)
	_partie.fin_de_partie.connect(_sur_fin_de_partie)
	_partie.pause_changee.connect(_sur_pause)
	add_child(_partie)
	_hud = Hud.new()
	_hud.partie = _partie
	add_child(_hud)


func _quitter_partie() -> void:
	if _partie != null:
		_partie.queue_free()
		_partie = null
	if _hud != null:
		_hud.queue_free()
		_hud = null


func _sur_pause(en_pause: bool) -> void:
	_vider_calque()
	if not en_pause:
		return
	var colonne: VBoxContainer = Ui.panneau_centre(_calque)
	colonne.add_child(Ui.etiquette("PAUSE", 80, Ui.COULEUR_ACCENT))
	var reprendre: Button = Ui.bouton("Reprendre", func() -> void: _partie.mettre_en_pause(false))
	colonne.add_child(reprendre)
	colonne.add_child(Ui.bouton("Quitter", _afficher_titre))
	reprendre.grab_focus.call_deferred()


func _sur_fin_de_partie(score: int, record_battu: bool) -> void:
	if record_battu:
		_meilleur_score = score
		MeilleurScore.ecrire(score)
	var partie_finie: Partie = _partie
	await get_tree().create_timer(DELAI_ECRAN_FIN).timeout
	if _partie != partie_finie:
		return
	_vider_calque()
	var colonne: VBoxContainer = Ui.panneau_centre(_calque)
	colonne.add_child(Ui.etiquette("FIN DE PARTIE", 80, Ui.COULEUR_ACCENT))
	colonne.add_child(Ui.etiquette("Score : %d" % score, 48))
	colonne.add_child(Ui.etiquette("Meilleur score : %d" % _meilleur_score, 32))
	if record_battu:
		colonne.add_child(Ui.etiquette("Nouveau meilleur score !", 40, Color(1.0, 0.4, 0.3)))
	var rejouer: Button = Ui.bouton("Rejouer", _lancer_partie)
	colonne.add_child(rejouer)
	colonne.add_child(Ui.bouton("Titre", _afficher_titre))
	rejouer.grab_focus.call_deferred()
