extends Control

const START_SCENE := "res://scenes/start_screen.tscn"
const HEROES_SCENE := "res://scenes/heroes_screen.tscn"

@onready var side_menu = $SideMenu
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	side_menu.item_pressed.connect(_on_side_menu_item_pressed)
	return_button.pressed.connect(_on_return_pressed)


func _on_side_menu_item_pressed(item_id: StringName) -> void:
	match String(item_id):
		"heroes":
			get_tree().change_scene_to_file(HEROES_SCENE)
		"cards":
			pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(START_SCENE)
