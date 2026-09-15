extends Control

const LIBRARY_SCENE := "res://scenes/library_screen.tscn"

@onready var side_menu = $SideMenu


func _ready() -> void:
	side_menu.item_pressed.connect(_on_menu_item_pressed)


func _on_menu_item_pressed(item_id: StringName) -> void:
	match item_id:
		&"library":
			get_tree().change_scene_to_file(LIBRARY_SCENE)
		&"exit":
			get_tree().quit()
