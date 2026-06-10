extends Node

const SAVE_PATH := "user://save_data.json"
const EMPTY_TEXT := "SAVE DATA TEXT CONTENT"

var output_label: Label


func setup(label: Label) -> void:
	output_label = label
	show_file_content()


func save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		show_message("ERROR: no se pudo abrir el archivo para guardar.")
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	show_file_content()


func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		show_message("ERROR: no existe archivo de guardado.")
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		show_message("ERROR: no se pudo abrir el archivo para cargar.")
		return {}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		show_message("ERROR: JSON invalido.\n%s" % json.get_error_message())
		return {}

	if not (json.data is Dictionary):
		show_message("ERROR: el archivo no contiene un diccionario JSON.")
		return {}

	return json.data as Dictionary


func clear_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	show_message(EMPTY_TEXT)


func show_file_content() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		show_message(EMPTY_TEXT)
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		show_message("ERROR: no se pudo leer el archivo guardado.")
		return

	var json_text := file.get_as_text()
	file.close()
	show_message(json_text)


func show_message(text: String) -> void:
	if output_label != null:
		output_label.text = text


func compare_versions(a: String, b: String) -> int:
	var parts_a := a.split(".")
	var parts_b := b.split(".")
	var max_size: int = maxi(parts_a.size(), parts_b.size())

	for i in range(max_size):
		var value_a := int(parts_a[i]) if i < parts_a.size() else 0
		var value_b := int(parts_b[i]) if i < parts_b.size() else 0

		if value_a > value_b:
			return 1
		if value_a < value_b:
			return -1

	return 0
