extends HBoxContainer

@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $Name


func setup(hero: Dictionary) -> void:
	name_label.text = String(hero["name"])
	var art_path := String(hero["art_path"])
	if ResourceLoader.exists(art_path):
		portrait.texture = load(art_path)
