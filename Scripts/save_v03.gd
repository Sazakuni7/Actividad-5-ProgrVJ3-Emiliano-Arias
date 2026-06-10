extends Node

const VERSION := "0.3"

signal load_completed(data: Dictionary)
signal load_failed(reason: String)

var save_manager: Node


func setup(manager: Node) -> void:
	save_manager = manager


func save_game(score: int, frog_position: Vector2, bgm_enabled: bool, sfx_enabled: bool) -> void:
	var data := {
		"version": VERSION,
		"score": score,
		"frog_x": frog_position.x,
		"frog_y": frog_position.y,
		"bgm": bgm_enabled,
		"sfx": sfx_enabled
	}

	save_manager.save_data(data)


func load_game(default_frog_position: Vector2) -> void:
	var data: Dictionary = save_manager.load_data()
	if data.is_empty():
		_emit_error("No hay datos validos para cargar.")
		return

	var save_version := str(data.get("version", "0.0"))
	if save_manager.compare_versions(save_version, VERSION) > 0:
		_emit_error("ERROR: la version 0.3 no puede cargar un archivo version %s." % save_version)
		return

	var migrated_notes: Array[String] = []
	var frog_x := default_frog_position.x
	var frog_y := default_frog_position.y
	var sfx_enabled := true

	if data.has("frog_x") and data.has("frog_y"):
		frog_x = float(data["frog_x"])
		frog_y = float(data["frog_y"])
	else:
		migrated_notes.append("posicion de rana por defecto")

	if data.has("sfx"):
		sfx_enabled = bool(data["sfx"])
	else:
		migrated_notes.append("SFX activo por defecto")

	var loaded_data := {
		"version": save_version,
		"score": int(data.get("score", 0)),
		"frog_position": Vector2(frog_x, frog_y),
		"bgm": bool(data.get("bgm", true)),
		"sfx": sfx_enabled
	}

	load_completed.emit(loaded_data)

	if migrated_notes.is_empty():
		save_manager.show_file_content()
	else:
		save_manager.show_message("%s\n\nMigracion %s -> %s: %s." % [
			JSON.stringify(data, "\t"),
			save_version,
			VERSION,
			", ".join(migrated_notes)
		])


func _emit_error(reason: String) -> void:
	save_manager.show_message(reason)
	load_failed.emit(reason)
