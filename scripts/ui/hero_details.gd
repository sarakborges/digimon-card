extends Control

const HEROES_SCENE := "res://scenes/heroes_screen.tscn"
const HERO_LIST_ITEM_SCENE := preload("res://scenes/ui/hero_list_item.tscn")
const HERO_REPOSITORY := preload("res://scripts/data/hero_repository.gd")

var hero_id := ""

@onready var side_menu = $SideMenu
@onready var hero_scroll: ScrollContainer = $HeroScroll
@onready var hero_content: VBoxContainer = $HeroScroll/HeroContent
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	side_menu.item_pressed.connect(_on_side_menu_item_pressed)
	return_button.pressed.connect(_on_return_pressed)
	_load_hero()


func _load_hero() -> void:
	_clear_content()

	var hero: Dictionary = HERO_REPOSITORY.load_by_id(hero_id)
	if hero.is_empty():
		return

	side_menu.set_title("Library / Heroes / %s" % String(hero.get("name", "")))

	var item = HERO_LIST_ITEM_SCENE.instantiate()
	item.hero_id = hero_id
	item.compact = false
	item.interactive = false
	hero_content.add_child(item)

	var evolutions = hero.get("evolutions", [])
	if not evolutions.is_empty():
		_add_evolutions(evolutions)

	call_deferred("_reset_scroll")


func _add_evolutions(evolution_ids: Array) -> void:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 8)
	hero_content.add_child(block)

	var title := Label.new()
	title.text = "Evolves to"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 24)
	block.add_child(title)

	var evolution_list := VBoxContainer.new()
	evolution_list.add_theme_constant_override("separation", 8)
	block.add_child(evolution_list)

	for evolution_variant in evolution_ids:
		var evolution_id := String(evolution_variant).strip_edges()
		if evolution_id.is_empty():
			continue

		var evolution_item = HERO_LIST_ITEM_SCENE.instantiate()
		evolution_item.hero_id = evolution_id
		evolution_item.compact = true
		evolution_item.interactive = true
		evolution_item.hero_pressed.connect(_on_evolution_pressed)
		evolution_list.add_child(evolution_item)


func _reset_scroll() -> void:
	hero_scroll.scroll_vertical = 0
	hero_scroll.scroll_horizontal = 0


func _clear_content() -> void:
	for child in hero_content.get_children():
		hero_content.remove_child(child)
		child.queue_free()


func _on_evolution_pressed(next_hero_id: String) -> void:
	if next_hero_id.is_empty() or next_hero_id == hero_id:
		return

	hero_id = next_hero_id
	_load_hero()


func _on_side_menu_item_pressed(item_id: StringName) -> void:
	match String(item_id):
		"cards":
			pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(HEROES_SCENE)
