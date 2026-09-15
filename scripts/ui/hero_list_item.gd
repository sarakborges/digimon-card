extends Control

signal hero_pressed(hero_id: String)

const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)

var hero_data: Dictionary = {}
var interactive := true

@onready var portrait: TextureRect = $Content/PortraitFrame/Portrait
@onready var name_label: Label = $Content/Text/Name
@onready var description_label: Label = $Content/Text/Description
@onready var hit_area: Button = $HitArea


func _ready() -> void:
	_apply_data()
	_configure_interaction()


func _configure_interaction() -> void:
	if not interactive:
		hit_area.focus_mode = Control.FOCUS_NONE
		hit_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hit_area.mouse_default_cursor_shape = Control.CURSOR_ARROW
		return

	hit_area.mouse_entered.connect(_set_hovered.bind(true))
	hit_area.mouse_exited.connect(_set_hovered.bind(false))
	hit_area.focus_entered.connect(_set_hovered.bind(true))
	hit_area.focus_exited.connect(_set_hovered.bind(false))
	hit_area.pressed.connect(_on_pressed)


func _apply_data() -> void:
	if hero_data.is_empty():
		return

	name_label.text = String(hero_data.get("name", ""))
	description_label.text = String(hero_data.get("description", ""))

	var art_path := String(hero_data.get("art_path", ""))
	if art_path.is_empty():
		push_warning("Hero art path is empty")
		return

	var texture := _load_png_texture(art_path)
	if texture == null:
		push_warning("Unable to load hero art: %s" % art_path)
		return

	portrait.texture = texture


func _load_png_texture(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		return null

	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		return null

	var image := Image.new()
	var error := image.load_png_from_buffer(bytes)
	if error != OK:
		return null

	return ImageTexture.create_from_image(image)


func _set_hovered(hovered: bool) -> void:
	var glow := HOVER_GLOW if hovered else IDLE_GLOW
	name_label.add_theme_color_override("font_outline_color", glow)
	name_label.add_theme_color_override("font_shadow_color", glow)
	name_label.add_theme_constant_override("outline_size", 2 if hovered else 0)
	name_label.add_theme_constant_override("shadow_outline_size", 8 if hovered else 0)

	var portrait_material := portrait.material as ShaderMaterial
	if portrait_material != null:
		portrait_material.set_shader_parameter("hover_amount", 1.0 if hovered else 0.0)


func _on_pressed() -> void:
	var hero_id := String(hero_data.get("id", ""))
	if not hero_id.is_empty():
		hero_pressed.emit(hero_id)
