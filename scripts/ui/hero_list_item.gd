extends HBoxContainer

const AVATAR_SIZE := 124
const BORDER_WIDTH := 8.0
const BORDER_COLOR := Color(0.06, 0.08, 0.11, 1.0)

var hero_data: Dictionary = {}

@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $Name


func _ready() -> void:
	_apply_data()


func _apply_data() -> void:
	if hero_data.is_empty():
		return

	name_label.text = String(hero_data.get("name", ""))

	var art_path := String(hero_data.get("art_path", ""))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		push_warning("Hero art not found: %s" % art_path)
		return

	var source_texture := load(art_path) as Texture2D
	if source_texture == null:
		push_warning("Unable to load hero art: %s" % art_path)
		return

	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		push_warning("Unable to read hero art image: %s" % art_path)
		return

	portrait.texture = _create_circular_avatar(source_image)


func _create_circular_avatar(source_image: Image) -> ImageTexture:
	var side := mini(source_image.get_width(), source_image.get_height())
	var crop_x := (source_image.get_width() - side) / 2
	var crop_y := (source_image.get_height() - side) / 2
	var image := source_image.get_region(Rect2i(crop_x, crop_y, side, side))
	image.resize(AVATAR_SIZE, AVATAR_SIZE, Image.INTERPOLATE_LANCZOS)

	var center := Vector2((AVATAR_SIZE - 1) * 0.5, (AVATAR_SIZE - 1) * 0.5)
	var outer_radius := AVATAR_SIZE * 0.5
	var inner_radius := outer_radius - BORDER_WIDTH

	for y in range(AVATAR_SIZE):
		for x in range(AVATAR_SIZE):
			var distance := Vector2(x, y).distance_to(center)
			if distance >= outer_radius:
				var pixel := image.get_pixel(x, y)
				pixel.a = 0.0
				image.set_pixel(x, y, pixel)
			elif distance >= inner_radius:
				image.set_pixel(x, y, BORDER_COLOR)

	return ImageTexture.create_from_image(image)
