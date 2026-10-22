class_name Joueur
extends CharacterBody2D
## Le personnage contrôlé par la personne qui joue.

const TAILLE := Vector2(40.0, 64.0)

enum EtatAttrape { NORMAL, FENETRE, RECUPERATION }

var reglages: Reglages

var _sauts_air_restants: int = 1
var _dash_air_disponible: bool = true
var _temps_dash: float = 0.0
var _recharge_dash: float = 0.0
var _direction_dash: float = 1.0
var _temps_traversee: float = 0.0
var _orientation: float = 1.0
var _actions_precedentes: Dictionary = {}
var _etat_attrape: EtatAttrape = EtatAttrape.NORMAL
var _temps_ejection: float = 0.0
var _temps_invulnerabilite: float = 0.0
var _temps_etat_attrape: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(Arene.COUCHE_PRINCIPALE, true)
	set_collision_mask_value(Arene.COUCHE_HAUTES, true)
	floor_snap_length = 4.0
	var forme := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = TAILLE
	forme.shape = rectangle
	forme.position = Vector2(0.0, -TAILLE.y / 2.0)
	add_child(forme)


## Rectangle occupé par le Joueur (position = milieu des pieds).
func boite() -> Rect2:
	return Rect2(position - Vector2(TAILLE.x / 2.0, TAILLE.y), TAILLE)


func _physics_process(delta: float) -> void:
	_simuler(delta)
	_simuler_attrape(delta)
	_memoriser_actions()


## Vrai si un contact avec une Banane est maintenant une Attrape.
func peut_attraper() -> bool:
	return _etat_attrape == EtatAttrape.FENETRE and not en_ejection()


func en_ejection() -> bool:
	return _temps_ejection > 0.0


func invulnerable() -> bool:
	return _temps_invulnerabilite > 0.0


## Coup : le Joueur est projeté et perd le contrôle pendant `duree`.
func ejecter(vitesse_ejection: Vector2, duree: float) -> void:
	velocity = vitesse_ejection
	_temps_ejection = duree
	_temps_dash = 0.0
	_etat_attrape = EtatAttrape.NORMAL
	_temps_etat_attrape = 0.0


func devenir_invulnerable(duree: float) -> void:
	_temps_invulnerabilite = duree


## Remet le Joueur en jeu au point donné, immobile et sans état en cours.
func reapparaitre(point: Vector2) -> void:
	position = point
	velocity = Vector2.ZERO
	_temps_ejection = 0.0
	_temps_dash = 0.0
	_etat_attrape = EtatAttrape.NORMAL
	_temps_etat_attrape = 0.0


## Une Attrape ferme la Fenêtre d'attrape sans Récupération.
func confirmer_attrape() -> void:
	_etat_attrape = EtatAttrape.NORMAL
	_temps_etat_attrape = 0.0


func etat_attrape() -> EtatAttrape:
	return _etat_attrape


func _simuler_attrape(delta: float) -> void:
	_temps_etat_attrape = maxf(_temps_etat_attrape - delta, 0.0)
	match _etat_attrape:
		EtatAttrape.NORMAL:
			if _appui("catch") and not en_ejection():
				_etat_attrape = EtatAttrape.FENETRE
				_temps_etat_attrape = reglages.duree_fenetre_attrape
		EtatAttrape.FENETRE:
			if _temps_etat_attrape <= 0.0:
				_etat_attrape = EtatAttrape.RECUPERATION
				_temps_etat_attrape = reglages.duree_recuperation
		EtatAttrape.RECUPERATION:
			if _temps_etat_attrape <= 0.0:
				_etat_attrape = EtatAttrape.NORMAL


func _simuler(delta: float) -> void:
	_temps_invulnerabilite = maxf(_temps_invulnerabilite - delta, 0.0)
	if _temps_ejection > 0.0:
		# Éjection : aucun contrôle, seule la gravité agit.
		_temps_ejection -= delta
		velocity.y = minf(velocity.y + reglages.gravite * delta, reglages.vitesse_chute_max * 1.5)
		move_and_slide()
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		_orientation = signf(direction)
	_recharge_dash = maxf(_recharge_dash - delta, 0.0)
	_temps_traversee = maxf(_temps_traversee - delta, 0.0)
	set_collision_mask_value(Arene.COUCHE_HAUTES, _temps_traversee <= 0.0)

	if is_on_floor():
		_sauts_air_restants = 1
		_dash_air_disponible = true

	if _appui("dash") and _recharge_dash <= 0.0 and (is_on_floor() or _dash_air_disponible):
		_temps_dash = reglages.duree_dash
		_recharge_dash = reglages.recharge_dash
		_direction_dash = signf(direction) if direction != 0.0 else _orientation
		if not is_on_floor():
			_dash_air_disponible = false

	if _temps_dash > 0.0:
		_temps_dash -= delta
		velocity = Vector2(_direction_dash * reglages.vitesse_dash, 0.0)
	else:
		var acceleration: float = reglages.acceleration_sol if is_on_floor() else reglages.acceleration_air
		velocity.x = move_toward(velocity.x, direction * reglages.vitesse_course, acceleration * delta)
		velocity.y = minf(velocity.y + reglages.gravite * delta, reglages.vitesse_chute_max)
		if _appui("jump"):
			_sauter()
	move_and_slide()


func _sauter() -> void:
	if is_on_floor():
		if Input.is_action_pressed("down") and _sur_plateforme_haute():
			_temps_traversee = reglages.duree_traversee
			position.y += 2.0
		else:
			velocity.y = -reglages.vitesse_saut
	elif _sauts_air_restants > 0:
		_sauts_air_restants -= 1
		velocity.y = -reglages.vitesse_double_saut


func _sur_plateforme_haute() -> bool:
	for i: int in get_slide_collision_count():
		var corps: Object = get_slide_collision(i).get_collider()
		if corps is CollisionObject2D and (corps as CollisionObject2D).get_collision_layer_value(Arene.COUCHE_HAUTES):
			return true
	return false


## Vrai à l'image où l'action vient d'être pressée (détection de front indépendante des images de rendu).
func _appui(action: String) -> bool:
	return Input.is_action_pressed(action) and not _actions_precedentes.get(action, false)


func _memoriser_actions() -> void:
	for action: String in ["jump", "dash", "catch"]:
		_actions_precedentes[action] = Input.is_action_pressed(action)


func _process(delta: float) -> void:
	_temps_anim += delta * (1.0 + absf(velocity.x) / 120.0)
	queue_redraw()


# --- Rendu (aucune règle ici) ------------------------------------------------

const PEAU := Color(1.0, 0.8, 0.6)
const TENUE := Color(0.2, 0.55, 0.95)
const CHEVEUX := Color(0.95, 0.4, 0.15)
const GANTS := Color(0.98, 0.98, 1.0)

var _temps_anim: float = 0.0


func _draw() -> void:
	var alpha: float = 1.0
	if invulnerable() and int(Time.get_ticks_msec() / 70.0) % 2 == 0:
		alpha = 0.4
	var teinte := Color(1.0, 1.0, 1.0, alpha)
	if _etat_attrape == EtatAttrape.RECUPERATION:
		teinte = Color(0.65, 0.65, 0.7, alpha)
	var penche: float = 0.0
	if en_ejection():
		penche = sin(_temps_anim * 18.0) * 0.6
	elif _temps_dash > 0.0:
		penche = 0.35 * _direction_dash
	draw_set_transform(Vector2(0.0, -32.0), penche, Vector2(_orientation, 1.0))

	if _etat_attrape == EtatAttrape.FENETRE:
		draw_circle(Vector2(8.0, -14.0), 40.0, Color(0.5, 1.0, 0.6, 0.25))
		draw_arc(Vector2(8.0, -14.0), 40.0, 0.0, TAU, 32, Color(0.6, 1.0, 0.7, 0.8), 3.0)

	# Jambes : balancier à la course, repliées en l'air.
	var pas: float = sin(_temps_anim * 10.0) * 9.0 if is_on_floor() and absf(velocity.x) > 20.0 else 0.0
	var pli: float = -8.0 if not is_on_floor() else 0.0
	Dessin.membre(self, Vector2(-7.0, 14.0), Vector2(-7.0 + pas, 30.0 + pli), 8.0, TENUE.darkened(0.3) * teinte)
	Dessin.membre(self, Vector2(7.0, 14.0), Vector2(7.0 - pas, 30.0 + pli), 8.0, TENUE.darkened(0.3) * teinte)
	# Corps.
	Dessin.polygone(self, Dessin.rectangle_arrondi(Vector2(0.0, 4.0), Vector2(30.0, 28.0), 10.0), TENUE * teinte)
	# Bras selon l'état : tendus vers le haut pour attraper, ballants en Récupération.
	var main_avant := Vector2(16.0, 10.0)
	var main_arriere := Vector2(-15.0, 12.0)
	if _etat_attrape == EtatAttrape.FENETRE:
		main_avant = Vector2(22.0, -24.0)
		main_arriere = Vector2(10.0, -30.0)
	elif _etat_attrape == EtatAttrape.RECUPERATION:
		main_avant = Vector2(10.0, 20.0)
		main_arriere = Vector2(-8.0, 20.0)
	elif en_ejection():
		main_avant = Vector2(20.0, -18.0)
		main_arriere = Vector2(-22.0, -14.0)
	Dessin.membre(self, Vector2(-9.0, -4.0), main_arriere, 7.0, TENUE.darkened(0.15) * teinte)
	Dessin.membre(self, Vector2(9.0, -4.0), main_avant, 7.0, TENUE.darkened(0.15) * teinte)
	Dessin.cercle(self, main_arriere, 5.5, GANTS * teinte, 3.0)
	Dessin.cercle(self, main_avant, 5.5, GANTS * teinte, 3.0)
	# Tête et mèche.
	Dessin.polygone(self, PackedVector2Array([Vector2(-14.0, -22.0), Vector2(-4.0, -40.0), Vector2(2.0, -26.0), Vector2(12.0, -38.0), Vector2(14.0, -20.0)]), CHEVEUX * teinte, 3.0)
	Dessin.cercle(self, Vector2(2.0, -16.0), 14.0, PEAU * teinte)
	Dessin.polygone(self, PackedVector2Array([Vector2(-13.0, -20.0), Vector2(-6.0, -32.0), Vector2(6.0, -31.0), Vector2(15.0, -22.0), Vector2(4.0, -25.0)]), CHEVEUX * teinte, 0.0)
	# Yeux : en croix pendant l'Éjection, mi-clos en Récupération.
	var oeil := Vector2(8.0, -17.0)
	if en_ejection():
		for d: Vector2 in [Vector2(-3.0, -3.0), Vector2(3.0, -3.0)]:
			draw_line(oeil + d, oeil - d, Dessin.CONTOUR, 2.5)
	elif _etat_attrape == EtatAttrape.RECUPERATION:
		draw_line(oeil + Vector2(-3.0, 0.0), oeil + Vector2(3.0, 0.0), Dessin.CONTOUR, 2.5)
		draw_circle(Vector2(-10.0, -26.0), 3.0, Color(0.6, 0.85, 1.0, alpha))
	else:
		draw_circle(oeil, 3.2, Color(1.0, 1.0, 1.0, alpha))
		draw_circle(oeil + Vector2(1.0, 0.0), 1.8, Dessin.CONTOUR)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
