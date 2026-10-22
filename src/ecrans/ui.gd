class_name Ui
extends RefCounted
## Petits constructeurs d'interface au style commun (texte épais à contour, boutons arrondis).

const COULEUR_FOND := Color(0.08, 0.06, 0.16, 0.85)
const COULEUR_ACCENT := Color(1.0, 0.82, 0.2)


static func etiquette(texte: String, taille: int, couleur: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = texte
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", taille)
	label.add_theme_color_override("font_color", couleur)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.1))
	label.add_theme_constant_override("outline_size", maxi(4, taille / 6))
	return label


static func bouton(texte: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(320.0, 64.0)
	b.add_theme_font_size_override("font_size", 30)
	for etat: String in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.25, 0.18, 0.45) if etat == "normal" else Color(0.85, 0.35, 0.15)
		style.set_corner_radius_all(14)
		style.set_border_width_all(4)
		style.border_color = COULEUR_ACCENT if etat == "focus" else Color(0.05, 0.03, 0.1)
		b.add_theme_stylebox_override(etat, style)
	b.pressed.connect(action)
	return b


## Panneau plein écran semi-opaque avec une colonne centrée ; renvoie la colonne.
static func panneau_centre(parent: Node) -> VBoxContainer:
	var fond := ColorRect.new()
	fond.color = COULEUR_FOND
	fond.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(fond)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	fond.add_child(centre)
	var colonne := VBoxContainer.new()
	colonne.alignment = BoxContainer.ALIGNMENT_CENTER
	colonne.add_theme_constant_override("separation", 18)
	centre.add_child(colonne)
	return colonne
