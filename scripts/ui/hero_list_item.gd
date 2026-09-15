extends Control

signal hero_pressed(hero_id: String)

const HERO_REPOSITORY := preload("res://scripts/data/hero_repository.gd")
const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)
const DETAILED_MIN_HEIGHT := 196.0

@export var hero_id := ""
@export var compact := true
@export var interactive := true

var _hero_data: Dictionary = {}

@onready var content: HBoxContainer = $Content
@onready var portrait_frame: MarginContainer = $Content/PortraitFrame
@onready var portrait: TextureRect = $Content/PortraitFrame/Portrait
@onready var text_container: VBoxContainer = $Content/Text
@onready var name_label: Label = $Content/Text/Name
@onready var description_label: Label = $Content/Text/Description
@onready var metadata: HBoxContainer = $Content/Text/Metadata
@onready var fields_value: Label = $Content/Text/Metadata/Fields/Value
@onready var element_value: Label = $Content/Text/Metadata/Element/Value
@onready var hit_area: Button = $HitArea


func _ready() -> void:
	_configure_layout()
	_apply_data()
	_configure_interaction()

	if not compact:
		resized.connect(_on_detailed_resized)
		call_deferred("_sync_detailed_minimum_height")


func _configure_layout() -> void:
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	if compact:
		custom_minimum_size = Vector2(0.0, 52.0)
		content.add_theme_constant_override("separation", 12)
		portrait_frame.custom_minimum_size = Vector2(48.0, 48.0)
		portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		portrait_frame.add_theme_constant_override("margin_left", 2)
		portrait_frame.add_theme_constant_override("margin_top", 2)
		portrait_frame.add_theme_constant_override("margin_right", 2)
		portrait_frame.add_theme_constant_override("margin_bottom", 2)
		portrait.custom_minimum_size = Vector2(44.0, 44.0)
		text_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		text_container.add_theme_constant_override("separation", 0)
		name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		name_label.add_theme_font_size_override("font_size", 24)
		description_label.visible = false
		metadata.visible = false
	else:
		custom_minimum_size = Vector2(0.0, DETAILED_MIN_HEIGHT)
		content.add_theme_constant_override("separation", 24)
		portrait_frame.custom_minimum_size = Vector2(132.0, 132.0)
		portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		portrait_frame.add_theme_constant_override("margin_left", 4)
		portrait_frame.add_theme_constant_override("margin_top", 4)
		portrait_frame.add_theme_constant_override("margin_right", 4)
		portrait_frame.add_theme_constant_override("margin_bottom", 4)
		portrait.custom_minimum_size = Vector2(124.0, 124.0)
		text_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		text_container.add_theme_constant_override("separation", 8)
		name_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		name_label.add_theme_font_size_override("font_size", 28)
		description_label.visible = true
		metadata.visible = true


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
	if hero_id.is_empty():
		push_warning("Hero item requires hero_id")
		return

	_hero_data = HERO_REPOSITORY.load_by_id(hero_id)
	if _hero_data.is_empty():
		return

	name_label.text = String(_hero_data.get("name", ""))
	description_label.text = String(_hero_data.get("description", ""))
	fields_value.text = _format_values(_hero_data.get("fields", []))
	element_value.text = _format_values(_hero_data.get("elements", []))

	var art_path := String(_hero_data.get("art_path", ""))
	if art_path.is_empty():
		push_warning("Hero art path is empty: %s" % hero_id)
		return

	var texture := _load_png_texture(art_path)
	if texture == null:
		push_warning("Unable to load hero art: %s" % art_path)
		return

	portrait.texture = texture


func _sync_detailed_minimum_height() -> void:
	if compact or not is_node_ready():
		return

	var target_height := max(DETAILED_MIN_HEIGHT, content.get_combined_minimum_size().y)
	if abs(custom_minimum_size.y - target_height) > 0.5:
		custom_minimum_size.y = target_height


func _on_detailed_resized() -> void:
	call_deferred("_sync_detailed_minimum_height")


func _format_values(values_variant: Variant) -> String:
	if typeof(values_variant) != TYPE_ARRAY:
		return "—"

	var values: Array[String] = []
	for value_variant in values_variant:
		var value := String(value_variant).strip_edges()
		if not value.is_empty():
			values.append(value)

	return "\n".join(values) if not values.is_empty() else "—"


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

	var mipmap_error := image.generate_mipmaps()
	if mipmap_error != OK:
		push_warning("Unable to generate mipmaps for hero art: %s" % path)

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
	if not hero_id.is_empty():
		hero_pressed.emit(hero_id)
