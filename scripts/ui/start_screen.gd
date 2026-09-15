extends Control

const RESTING_LABEL_X := 0.0
const HOVER_OFFSET := 8.0
const HOVER_DURATION := 0.14
const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)
const LIBRARY_SCENE := "res://scenes/library_screen.tscn"

@onready var library_button: Button = $Sidebar/LibraryButton
@onready var exit_button: Button = $Sidebar/ExitButton
@onready var library_label: Label = $Sidebar/LibraryButton/Label
@onready var exit_label: Label = $Sidebar/ExitButton/Label

var library_tween: Tween
var exit_tween: Tween


func _ready() -> void:
	library_button.mouse_entered.connect(_on_library_hover_entered)
	library_button.mouse_exited.connect(_on_library_hover_exited)
	library_button.focus_entered.connect(_on_library_hover_entered)
	library_button.focus_exited.connect(_on_library_hover_exited)
	library_button.pressed.connect(_on_library_pressed)

	exit_button.mouse_entered.connect(_on_exit_hover_entered)
	exit_button.mouse_exited.connect(_on_exit_hover_exited)
	exit_button.focus_entered.connect(_on_exit_hover_entered)
	exit_button.focus_exited.connect(_on_exit_hover_exited)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_library_hover_entered() -> void:
	library_tween = _set_hovered(library_label, true, library_tween)


func _on_library_hover_exited() -> void:
	library_tween = _set_hovered(library_label, false, library_tween)


func _on_exit_hover_entered() -> void:
	exit_tween = _set_hovered(exit_label, true, exit_tween)


func _on_exit_hover_exited() -> void:
	exit_tween = _set_hovered(exit_label, false, exit_tween)


func _set_hovered(label: Label, hovered: bool, active_tween: Tween) -> Tween:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()

	var glow := HOVER_GLOW if hovered else IDLE_GLOW
	label.add_theme_color_override("font_outline_color", glow)
	label.add_theme_color_override("font_shadow_color", glow)
	label.add_theme_constant_override("outline_size", 2 if hovered else 0)
	label.add_theme_constant_override("shadow_outline_size", 8 if hovered else 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)

	var target_x := RESTING_LABEL_X + (HOVER_OFFSET if hovered else 0.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:x", target_x, HOVER_DURATION)
	return tween


func _on_library_pressed() -> void:
	get_tree().change_scene_to_file(LIBRARY_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
