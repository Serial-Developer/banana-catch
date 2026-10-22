class_name Effets
extends Node2D
## Effets visuels réagissant aux signaux de la Partie : particules, anneaux, taches d'Échec, secousse de caméra,
## gel d'image et flèches vers les Bananes hors écran. Ne modifie aucune règle.

const ECRAN := Rect2(0.0, 0.0, 1280.0, 720.0)

var partie: Partie
var camera: Camera2D

var _secousse: float = 0.0
var _duree_secousse: float = 0.0
var _amplitude: float = 0.0
## Éléments dessinés : {type, position, temps, duree, couleur, rayon, texte}.
var _elements: Array[Dictionary] = []


func _ready() -> void:
	z_index = 50
	partie.attrape.connect(_sur_attrape)
	partie.coup.connect(_sur_coup)
	partie.echec.connect(_sur_echec)
	partie.stock_perdu.connect(_sur_stock_perdu)
	partie.reapparition.connect(_sur_reapparition)


func _sur_attrape(lieu: Vector2) -> void:
	_particules(lieu, 26, [Color(1.0, 0.95, 0.4), Color(1.0, 1.0, 1.0)], 260.0, 0.45, 0.0)
	_ajouter({"type": "anneau", "position": lieu, "duree": 0.3, "couleur": Color(0.7, 1.0, 0.6), "rayon": 46.0})
	_ajouter({"type": "texte", "position": lieu + Vector2(0.0, -30.0), "duree": 0.8, "couleur": Color(1.0, 0.9, 0.3), "texte": "+1"})
	partie.geler(0.04)


func _sur_coup(pourcentage: float) -> void:
	var lieu: Vector2 = partie.joueur_position() + Vector2(0.0, -32.0)
	_particules(lieu, 30, [Color(1.0, 0.6, 0.2), Color(1.0, 1.0, 0.8), Color(1.0, 0.25, 0.15)], 380.0 + pourcentage * 2.0, 0.35, 300.0)
	_ajouter({"type": "anneau", "position": lieu, "duree": 0.25, "couleur": Color(1.0, 0.45, 0.2), "rayon": 60.0 + pourcentage * 0.4})
	_secouer(6.0 + pourcentage * 0.08, 0.25 + pourcentage * 0.002)
	partie.geler(minf(0.05 + pourcentage * 0.0006, 0.18))


func _sur_echec(lieu: Vector2) -> void:
	_particules(lieu, 14, [Color(1.0, 0.85, 0.2), Color(0.6, 0.45, 0.1)], 200.0, 0.4, 700.0)
	if lieu.y < Partie.FOND_DU_VIDE - 10.0:
		_ajouter({"type": "tache", "position": lieu + Vector2(0.0, 12.0), "duree": 3.0, "couleur": Color(1.0, 0.85, 0.2)})
	_secouer(4.0, 0.15)


func _sur_stock_perdu(_restants: int) -> void:
	var position_joueur: Vector2 = partie.joueur_position()
	if ECRAN.grow(-4.0).has_point(position_joueur):
		return
	# Explosion de sortie sur le bord de l'écran, orientée vers l'intérieur.
	var bord := Vector2(clampf(position_joueur.x, 0.0, ECRAN.size.x), clampf(position_joueur.y, 0.0, ECRAN.size.y))
	_particules(bord, 60, [Color(1.0, 1.0, 1.0), Color(1.0, 0.85, 0.3), Color(1.0, 0.35, 0.2)], 700.0, 0.7, 0.0)
	_ajouter({"type": "anneau", "position": bord, "duree": 0.6, "couleur": Color(1.0, 0.9, 0.5), "rayon": 260.0})
	_ajouter({"type": "faisceau", "position": bord, "duree": 0.5, "couleur": Color(1.0, 0.95, 0.7)})
	_secouer(18.0, 0.45)


func _sur_reapparition() -> void:
	_ajouter({"type": "anneau", "position": partie.joueur_position() + Vector2(0.0, -32.0), "duree": 0.5, "couleur": Color(0.6, 0.9, 1.0), "rayon": 70.0})


func _ajouter(element: Dictionary) -> void:
	element["temps"] = 0.0
	_elements.append(element)


func _secouer(amplitude: float, duree: float) -> void:
	if amplitude >= _amplitude * (_secousse / maxf(_duree_secousse, 0.01)):
		_amplitude = amplitude
		_secousse = duree
		_duree_secousse = duree


func _particules(lieu: Vector2, nombre: int, couleurs: Array, vitesse: float, duree: float, gravite: float) -> void:
	var emetteur := CPUParticles2D.new()
	emetteur.position = lieu
	emetteur.one_shot = true
	emetteur.explosiveness = 1.0
	emetteur.amount = nombre
	emetteur.lifetime = duree
	emetteur.spread = 180.0
	emetteur.direction = Vector2.UP
	emetteur.initial_velocity_min = vitesse * 0.4
	emetteur.initial_velocity_max = vitesse
	emetteur.gravity = Vector2(0.0, gravite)
	emetteur.damping_min = vitesse * 0.5
	emetteur.damping_max = vitesse * 0.8
	emetteur.scale_amount_min = 4.0
	emetteur.scale_amount_max = 9.0
	var degrade := Gradient.new()
	degrade.set_color(0, couleurs[0])
	degrade.set_color(1, Color(couleurs[-1], 0.0))
	if couleurs.size() > 2:
		degrade.add_point(0.5, couleurs[1])
	emetteur.color_ramp = degrade
	emetteur.finished.connect(emetteur.queue_free)
	add_child(emetteur)
	emetteur.emitting = true


func _process(delta: float) -> void:
	if _secousse > 0.0:
		_secousse = maxf(_secousse - delta, 0.0)
		var force: float = _amplitude * _secousse / maxf(_duree_secousse, 0.01)
		camera.offset = Vector2(randf_range(-force, force), randf_range(-force, force))
	else:
		camera.offset = Vector2.ZERO
	for element: Dictionary in _elements.duplicate():
		element.temps += delta
		if element.temps >= element.duree:
			_elements.erase(element)
	queue_redraw()


func _draw() -> void:
	for element: Dictionary in _elements:
		var t: float = element.temps / element.duree
		var couleur: Color = element.couleur
		match element.type:
			"anneau":
				draw_arc(element.position, element.rayon * (0.3 + 0.7 * t), 0.0, TAU, 40, Color(couleur, 1.0 - t), 8.0 * (1.0 - t) + 2.0)
			"texte":
				var police: Font = ThemeDB.fallback_font
				var lieu: Vector2 = element.position + Vector2(-14.0, -40.0 * t)
				draw_string_outline(police, lieu, element.texte, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, 8, Color(Dessin.CONTOUR, 1.0 - t))
				draw_string(police, lieu, element.texte, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(couleur, 1.0 - t))
			"tache":
				var alpha: float = 1.0 - maxf(t - 0.6, 0.0) / 0.4
				Dessin.ellipse(self, element.position, Vector2(26.0, 6.0), Color(1.0, 0.85, 0.25, alpha), 3.0)
				for k: int in 5:
					var angle: float = PI + k * PI / 4.0
					draw_circle(element.position + Vector2(cos(angle) * 30.0, sin(angle) * 10.0), 4.0, Color(0.95, 0.8, 0.3, alpha))
			"faisceau":
				var vers_centre: Vector2 = (ECRAN.get_center() - element.position).normalized()
				draw_line(element.position, element.position + vers_centre * 900.0, Color(couleur, 0.8 * (1.0 - t)), 90.0 * (1.0 - t) + 6.0)
	# Flèches vers les Bananes sorties du cadre.
	for lieu: Vector2 in partie.positions_bananes():
		if lieu.y < -8.0:
			var x: float = clampf(lieu.x, 30.0, ECRAN.size.x - 30.0)
			var pointe := Vector2(x, 10.0)
			var fleche := PackedVector2Array([pointe, pointe + Vector2(-16.0, 24.0), pointe + Vector2(16.0, 24.0)])
			Dessin.polygone(self, fleche, Color(1.0, 0.9, 0.25), 3.0)
			draw_string(ThemeDB.fallback_font, pointe + Vector2(-14.0, 50.0), "%dm" % int(-lieu.y / 10.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
