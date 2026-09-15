extends Control

const HEROES_SCENE := "res://scenes/heroes_screen.tscn"
const HERO_LIST_ITEM_SCENE := preload("res://scenes/ui/hero_list_item.tscn")
const HERO_REPOSITORY := preload("res://scripts/data/hero_repository.gd")

var hero_id := ""

@onready var side_menu = $SideMenu
@onready var hero_content: VBoxContainer = $HeroContent
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	side_menu.item_pressed.connect(_on_side_menu_item_pressed)
	return_button.pressed.connect(_on_return_pressed)
	_load_hero()


func _load_hero() -> void:
	var hero: Dictionary = HERO_REPOSITORY.load_by_id(hero_id)
	if hero.is_empty():
		return

	side_menu.set_title("Library / Heroes / %s" % String(hero.get("name", "")))

	var item = HERO_LIST_ITEM_SCENE.instantiate()
	item.hero_data = hero
	item.interactive = false
	hero_content.add_child(item)


func _on_side_menu_item_pressed(item_id: StringName) -> void:
	match String(item_id):
		"cards":
			pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(HEROES_SCENE)
