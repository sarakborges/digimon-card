extends Control

const START_SCENE := "res://scenes/start_screen.tscn"

@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(START_SCENE)
