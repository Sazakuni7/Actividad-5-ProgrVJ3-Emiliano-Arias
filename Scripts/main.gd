extends Control

@onready var save_01_button: Button = %Save01
@onready var load_01_button: Button = %Load01
@onready var save_03_button: Button = %Save03
@onready var load_03_button: Button = %Load03
@onready var clear_button: Button = %Clear
@onready var save_text: Label = %SaveText
@onready var score_label: Label = %Score
@onready var sfx_button: CheckButton = %SFXButton
@onready var bgm_button: CheckButton = %BGMButton
@onready var game_panel: Panel = $HBoxContainer/GamePanel
@onready var frog: Sprite2D = %FrogIdle
@onready var frog_position_label: Label = %Position
@onready var sfx_player: AudioStreamPlayer = $Game/FrogIdle/SFX
@onready var bgm_player: AudioStreamPlayer = $Game/BGM
@onready var save_manager = $SaveManager
@onready var save_v01 = $SaveV01
@onready var save_v03 = $SaveV03

var score := 0
var bgm_enabled := true
var sfx_enabled := true
var initial_frog_position := Vector2.ZERO


func _ready() -> void:
	initial_frog_position = frog.global_position

	save_manager.setup(save_text)
	save_v01.setup(save_manager)
	save_v03.setup(save_manager)

	save_01_button.pressed.connect(_on_save_01_pressed)
	load_01_button.pressed.connect(_on_load_01_pressed)
	save_03_button.pressed.connect(_on_save_03_pressed)
	load_03_button.pressed.connect(_on_load_03_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	sfx_button.toggled.connect(_on_sfx_toggled)
	bgm_button.toggled.connect(_on_bgm_toggled)
	game_panel.gui_input.connect(_on_game_panel_gui_input)

	save_v01.load_completed.connect(_apply_v01_data)
	save_v03.load_completed.connect(_apply_v03_data)

	_update_ui()


func _on_game_panel_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	score += 1
	frog.global_position = game_panel.get_global_transform() * mouse_event.position

	if sfx_enabled:
		sfx_player.play()

	_update_ui()


func _on_save_01_pressed() -> void:
	save_v01.save_game(score, bgm_enabled)


func _on_load_01_pressed() -> void:
	save_v01.load_game()


func _on_save_03_pressed() -> void:
	save_v03.save_game(score, frog.global_position, bgm_enabled, sfx_enabled)


func _on_load_03_pressed() -> void:
	save_v03.load_game(initial_frog_position)


func _on_clear_pressed() -> void:
	score = 0
	bgm_enabled = true
	sfx_enabled = true
	frog.global_position = initial_frog_position
	save_manager.clear_data()
	_update_ui()


func _on_sfx_toggled(toggled_on: bool) -> void:
	sfx_enabled = toggled_on
	_update_ui()


func _on_bgm_toggled(toggled_on: bool) -> void:
	bgm_enabled = toggled_on
	_update_ui()


func _apply_v01_data(data: Dictionary) -> void:
	score = int(data.get("score", 0))
	bgm_enabled = bool(data.get("bgm", true))
	_update_ui()
	save_manager.show_file_content()


func _apply_v03_data(data: Dictionary) -> void:
	score = int(data.get("score", 0))
	bgm_enabled = bool(data.get("bgm", true))
	sfx_enabled = bool(data.get("sfx", true))
	frog.global_position = data.get("frog_position", initial_frog_position)
	_update_ui()


func _update_ui() -> void:
	score_label.text = "SCORE: %d" % score
	frog_position_label.text = "X: %.0f  Y: %.0f" % [frog.global_position.x, frog.global_position.y]

	sfx_button.set_pressed_no_signal(sfx_enabled)
	bgm_button.set_pressed_no_signal(bgm_enabled)

	if bgm_enabled:
		if not bgm_player.playing:
			bgm_player.play()
		bgm_player.stream_paused = false
	else:
		bgm_player.stream_paused = true
