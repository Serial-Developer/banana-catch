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
	return _etat_attrape == EtatAttrape.FENETRE


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
			if _appui("catch"):
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


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var couleur := Color(0.95, 0.75, 0.3)
	if _etat_attrape == EtatAttrape.FENETRE:
		couleur = Color(0.4, 1.0, 0.5)
	elif _etat_attrape == EtatAttrape.RECUPERATION:
		couleur = Color(0.55, 0.5, 0.45)
	draw_rect(Rect2(-TAILLE.x / 2.0, -TAILLE.y, TAILLE.x, TAILLE.y), couleur)
