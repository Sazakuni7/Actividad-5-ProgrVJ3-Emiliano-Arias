extends Node

const VERSION := "0.1"

signal load_completed(data: Dictionary)
signal load_failed(reason: String)

var save_manager: Node


func setup(manager: Node) -> void:
	save_manager = manager


func save_game(score: int, bgm_enabled: bool) -> void:
	var data := {
		"version": VERSION,
		"score": score,
		"bgm": bgm_enabled
	}

	save_manager.save_data(data)


func load_game() -> void:
	var data: Dictionary = save_manager.load_data()
	if data.is_empty():
		_emit_error("No hay datos validos para cargar.")
		return

	var save_version := str(data.get("version", "0.0"))
	if save_manager.compare_versions(save_version, VERSION) > 0:
		_emit_error("ERROR: la version 0.1 no puede cargar un archivo version %s." % save_version)
		return

	var loaded_data := {
		"version": save_version,
		"score": int(data.get("score", 0)),
		"bgm": bool(data.get("bgm", true))
	}

	load_completed.emit(loaded_data)


func _emit_error(reason: String) -> void:
	save_manager.show_message(reason)
	load_failed.emit(reason)
