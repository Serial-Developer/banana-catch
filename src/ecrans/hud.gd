class_name Hud
extends CanvasLayer
## Affichage pendant la Partie : Pourcentage façon Smash, Stocks restants, Score. Aucune règle ici.

const POURCENTAGE_ROUGE: float = 150.0

var partie: Partie

var _pourcentage: Label
var _stocks: HBoxContainer
var _score: Label


func _ready() -> void:
	_score = Ui.etiquette("", 40, Ui.COULEUR_ACCENT)
	_score.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_score.position = Vector2(-260.0, 16.0)
	_score.size = Vector2(240.0, 50.0)
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_score)

	var bas := VBoxContainer.new()
	bas.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	bas.position = Vector2(-120.0, -150.0)
	bas.size = Vector2(240.0, 140.0)
	bas.alignment = BoxContainer.ALIGNMENT_END
	add_child(bas)
	_pourcentage = Ui.etiquette("0%", 72)
	bas.add_child(_pourcentage)
	_stocks = HBoxContainer.new()
	_stocks.alignment = BoxContainer.ALIGNMENT_CENTER
	_stocks.add_theme_constant_override("separation", 10)
	bas.add_child(_stocks)


func _process(_delta: float) -> void:
	if partie == null:
		return
	var p: float = partie.pourcentage()
	_pourcentage.text = "%d%%" % int(p)
	_pourcentage.add_theme_color_override("font_color", Color.WHITE.lerp(Color(1.0, 0.12, 0.08), clampf(p / POURCENTAGE_ROUGE, 0.0, 1.0)))
	_score.text = "Score %d" % partie.score()
	while _stocks.get_child_count() > partie.stocks():
		var icone: Node = _stocks.get_child(0)
		_stocks.remove_child(icone)
		icone.queue_free()
	while _stocks.get_child_count() < partie.stocks():
		var icone := ColorRect.new()
		icone.color = Color(0.95, 0.75, 0.3)
		icone.custom_minimum_size = Vector2(22.0, 22.0)
		_stocks.add_child(icone)
