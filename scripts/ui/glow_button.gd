extends Button

const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)

var _hovered := false
var _focused := false


func _ready() -> void:
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_focus_color", Color.WHITE)
	add_theme_constant_override("shadow_offset_x", 0)
	add_theme_constant_override("shadow_offset_y", 0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	_apply_glow()


func _on_mouse_entered() -> void:
	_hovered = true
	_apply_glow()


func _on_mouse_exited() -> void:
	_hovered = false
	_apply_glow()


func _on_focus_entered() -> void:
	_focused = true
	_apply_glow()


func _on_focus_exited() -> void:
	_focused = false
	_apply_glow()


func _apply_glow() -> void:
	var active := _hovered or _focused
	var glow := HOVER_GLOW if active else IDLE_GLOW
	add_theme_color_override("font_outline_color", glow)
	add_theme_color_override("font_shadow_color", glow)
	add_theme_constant_override("outline_size", 2 if active else 0)
	add_theme_constant_override("shadow_outline_size", 8 if active else 0)
