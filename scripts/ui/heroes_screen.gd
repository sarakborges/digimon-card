extends Control

const LIBRARY_SCENE := "res://scenes/library_screen.tscn"
const HERO_LIST_ITEM_SCENE := preload("res://scenes/ui/hero_list_item.tscn")

@onready var side_menu = $SideMenu
@onready var hero_list: VBoxContainer = $HeroScroll/HeroList
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	side_menu.item_pressed.connect(_on_side_menu_item_pressed)
	return_button.pressed.connect(_on_return_pressed)
	_populate_heroes()


func _populate_heroes() -> void:
	for child in hero_list.get_children():
		child.queue_free()

	for hero in HeroRepository.load_all():
		var item = HERO_LIST_ITEM_SCENE.instantiate()
		hero_list.add_child(item)
		item.setup(hero)


func _on_side_menu_item_pressed(item_id: StringName) -> void:
	match String(item_id):
		"cards":
			pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(LIBRARY_SCENE)
