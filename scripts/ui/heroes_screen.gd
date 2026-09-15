extends Control

const LIBRARY_SCENE := "res://scenes/library_screen.tscn"
const HERO_LIST_ITEM_SCENE := preload("res://scenes/ui/hero_list_item.tscn")
const HERO_DETAILS_SCENE := preload("res://scenes/hero_details.tscn")
const HERO_REPOSITORY := preload("res://scripts/data/hero_repository.gd")

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

	var heroes: Array[Dictionary] = HERO_REPOSITORY.load_listed()
	for hero in heroes:
		var item = HERO_LIST_ITEM_SCENE.instantiate()
		item.hero_data = hero
		item.hero_pressed.connect(_on_hero_pressed)
		hero_list.add_child(item)


func _on_hero_pressed(hero_id: String) -> void:
	var details = HERO_DETAILS_SCENE.instantiate()
	details.hero_id = hero_id

	var current_scene := get_tree().current_scene
	get_tree().root.add_child(details)
	get_tree().current_scene = details

	if current_scene != null:
		current_scene.queue_free()


func _on_side_menu_item_pressed(item_id: StringName) -> void:
	match String(item_id):
		"cards":
			pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(LIBRARY_SCENE)
