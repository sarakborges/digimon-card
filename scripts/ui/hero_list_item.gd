extends HBoxContainer

var hero_data: Dictionary = {}

@onready var portrait: TextureRect = $PortraitFrame/Portrait
@onready var name_label: Label = $Text/Name
@onready var description_label: Label = $Text/Description


func _ready() -> void:
	_apply_data()


func _apply_data() -> void:
	if hero_data.is_empty():
		return

	name_label.text = String(hero_data.get("name", ""))
	description_label.text = String(hero_data.get("description", ""))

	var art_path := String(hero_data.get("art_path", ""))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		push_warning("Hero art not found: %s" % art_path)
		return

	var texture := load(art_path) as Texture2D
	if texture == null:
		push_warning("Unable to load hero art: %s" % art_path)
		return

	portrait.texture = texture
