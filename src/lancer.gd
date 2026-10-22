class_name Lancer
extends RefCounted
## L'envoi d'une Banane par le Singe : un type, un point de départ et une vitesse initiale.

enum Type { ARC, TIR_TENDU, LOB }

var type: Type
var depart: Vector2
var vitesse: Vector2


func _init(p_type: Type, p_depart: Vector2, p_vitesse: Vector2) -> void:
	type = p_type
	depart = p_depart
	vitesse = p_vitesse
