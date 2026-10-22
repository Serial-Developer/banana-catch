extends Logger
## Compte les erreurs moteur et de script : un test qui en provoque une échoue, même s'il renvoie "".

var _mutex := Mutex.new()
var _messages: PackedStringArray = []


func _log_error(_function: String, _file: String, _line: int, code: String, rationale: String, _editor_notify: bool, _error_type: int, _script_backtrace: Array[ScriptBacktrace]) -> void:
	_mutex.lock()
	_messages.append(rationale if rationale != "" else code)
	_mutex.unlock()


func _log_message(_message: String, _error: bool) -> void:
	pass


## Renvoie les erreurs survenues depuis le dernier appel et remet le compteur à zéro.
func vider() -> PackedStringArray:
	_mutex.lock()
	var messages: PackedStringArray = _messages
	_messages = []
	_mutex.unlock()
	return messages
