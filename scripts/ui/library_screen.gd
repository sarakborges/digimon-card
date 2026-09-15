extends Control

const START_SCENE := "res://scenes/start_screen.tscn"
const RESTING_LABEL_X := 0.0
const HOVER_OFFSET := 8.0
const HOVER_DURATION := 0.14
const IDLE_GLOW := Color(0.36, 0.67, 1.0, 0.0)
const HOVER_GLOW := Color(0.36, 0.67, 1.0, 0.38)

@onready var heroes_button: Button = $Sidebar/HeroesButton
@onready var cards_button: Button = $Sidebar/CardsButton
@onready var heroes_label: Label = $Sidebar/HeroesButton/Label
@onready var cards_label: Label = $Sidebar/CardsButton/Label
@onready var return_button: Button = $ReturnButton

var heroes_tween: Tween
var cards_tween: Tween


func _ready() -> void:
	heroes_button.mouse_entered.connect(_on_heroes_hover_entered)
	heroes_button.mouse_exited.connect(_on_heroes_hover_exited)
	heroes_button.focus_entered.connect(_on_heroes_hover_entered)
	heroes_button.focus_exited.connect(_on_heroes_hover_exited)

	cards_button.mouse_entered.connect(_on_cards_hover_entered)
	cards_button.mouse_exited.connect(_on_cards_hover_exited)
	cards_button.focus_entered.connect(_on_cards_hover_entered)
	cards_button.focus_exited.connect(_on_cards_hover_exited)

	return_button.pressed.connect(_on_return_pressed)


func _on_heroes_hover_entered() -> void:
	heroes_tween = _set_hovered(heroes_label, true, heroes_tween)


func _on_heroes_hover_exited() -> void:
	heroes_tween = _set_hovered(heroes_label, false, heroes_tween)


func _on_cards_hover_entered() -> void:
	cards_tween = _set_hovered(cards_label, true, cards_tween)


func _on_cards_hover_exited() -> void:
	cards_tween = _set_hovered(cards_label, false, cards_tween)


func _set_hovered(label: Label, hovered: bool, active_tween: Tween) -> Tween:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()

	var glow := HOVER_GLOW if hovered else IDLE_GLOW
	label.add_theme_color_override("font_outline_color", glow)
	label.add_theme_color_override("font_shadow_color", glow)
	label.add_theme_constant_override("outline_size", 2 if hovered else 0)
	label.add_theme_constant_override("shadow_outline_size", 8 if hovered else 0)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)

	var target_x := RESTING_LABEL_X + (HOVER_OFFSET if hovered else 0.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:x", target_x, HOVER_DURATION)
	return tween


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(START_SCENE)
