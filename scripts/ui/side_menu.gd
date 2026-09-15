extends TextureRect

signal item_pressed(item_id: StringName)

const ITEM_HEIGHT := 56.0
const HOVER_OFFSET := 8.0
const HOVER_DURATION := 0.14
const TITLE_RIGHT_MARGIN := 32.0
const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)

@export var title_text := ""
@export var item_ids: PackedStringArray = []
@export var item_labels: PackedStringArray = []
@export var active_item_id := ""

@onready var title_label: Label = $Title
@onready var items_container: VBoxContainer = $Content/Items

var _active_tweens: Dictionary = {}


func _ready() -> void:
	get_viewport().size_changed.connect(_update_title_width)
	_apply_title()
	_build_items()


func _apply_title() -> void:
	title_label.text = title_text
	title_label.visible = not title_text.is_empty()
	_update_title_width()


func _update_title_width() -> void:
	var viewport_width := get_viewport_rect().size.x
	title_label.size.x = maxf(0.0, viewport_width - title_label.position.x - TITLE_RIGHT_MARGIN)


func _build_items() -> void:
	for child in items_container.get_children():
		child.queue_free()

	var count := mini(item_ids.size(), item_labels.size())
	for index in range(count):
		items_container.add_child(_create_item(StringName(item_ids[index]), item_labels[index]))


func _create_item(item_id: StringName, label_text: String) -> Control:
	var item := Control.new()
	item.custom_minimum_size = Vector2(0.0, ITEM_HEIGHT)
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.clip_contents = true

	var button := Button.new()
	item.add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var empty_style := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty_style)
	button.add_theme_stylebox_override("hover", empty_style)
	button.add_theme_stylebox_override("pressed", empty_style)
	button.add_theme_stylebox_override("focus", empty_style)

	var label := Label.new()
	item.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", IDLE_GLOW)
	label.add_theme_color_override("font_shadow_color", IDLE_GLOW)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.add_theme_constant_override("shadow_outline_size", 0)
	label.add_theme_font_size_override("font_size", 28)
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var is_active := String(item_id) == active_item_id
	if is_active:
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		_apply_hover_style(label, true)
		label.position.x = HOVER_OFFSET
	else:
		button.mouse_entered.connect(_set_hovered.bind(button, label, true))
		button.mouse_exited.connect(_set_hovered.bind(button, label, false))
		button.focus_entered.connect(_set_hovered.bind(button, label, true))
		button.focus_exited.connect(_set_hovered.bind(button, label, false))
		button.pressed.connect(_on_item_pressed.bind(item_id))

	return item


func _set_hovered(button: Button, label: Label, hovered: bool) -> void:
	var active_tween: Tween = _active_tweens.get(button)
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()

	_apply_hover_style(label, hovered)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:x", HOVER_OFFSET if hovered else 0.0, HOVER_DURATION)
	_active_tweens[button] = tween


func _apply_hover_style(label: Label, hovered: bool) -> void:
	var glow := HOVER_GLOW if hovered else IDLE_GLOW
	label.add_theme_color_override("font_outline_color", glow)
	label.add_theme_color_override("font_shadow_color", glow)
	label.add_theme_constant_override("outline_size", 2 if hovered else 0)
	label.add_theme_constant_override("shadow_outline_size", 8 if hovered else 0)


func _on_item_pressed(item_id: StringName) -> void:
	item_pressed.emit(item_id)
