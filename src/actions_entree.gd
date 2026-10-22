extends Node
## Déclare les actions d'entrée du jeu (clavier et manette) au démarrage.
## Les lettres sont des touches physiques : WASD en QWERTY = ZQSD en AZERTY.

const TOUCHES: Dictionary = {
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"down": [KEY_DOWN, KEY_S],
	"jump": [KEY_UP, KEY_SPACE, KEY_W],
	"catch": [KEY_J, KEY_X],
	"dash": [KEY_K, KEY_C, KEY_SHIFT],
	"pause": [KEY_ESCAPE, KEY_P],
}

const BOUTONS: Dictionary = {
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"down": [JOY_BUTTON_DPAD_DOWN],
	"jump": [JOY_BUTTON_A, JOY_BUTTON_Y],
	"catch": [JOY_BUTTON_B, JOY_BUTTON_X],
	"dash": [JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_LEFT_SHOULDER],
	"pause": [JOY_BUTTON_START],
}

# Action → [axe, sens] du stick gauche.
const AXES: Dictionary = {
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"down": [JOY_AXIS_LEFT_Y, 1.0],
}


func _init() -> void:
	for action: String in TOUCHES:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.4)
		for code: Key in TOUCHES[action]:
			var touche := InputEventKey.new()
			touche.physical_keycode = code
			InputMap.action_add_event(action, touche)
		for bouton: JoyButton in BOUTONS[action]:
			var evenement := InputEventJoypadButton.new()
			evenement.button_index = bouton
			InputMap.action_add_event(action, evenement)
		if AXES.has(action):
			var axe := InputEventJoypadMotion.new()
			axe.axis = AXES[action][0]
			axe.axis_value = AXES[action][1]
			InputMap.action_add_event(action, axe)
