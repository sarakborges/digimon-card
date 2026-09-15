extends RefCounted

const HERO_DATA_DIR := "res://data/heroes"
const HERO_ASSET_DIR := "res://assets/heroes"


static func load_all() -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	var files := DirAccess.get_files_at(HERO_DATA_DIR)

	for file_name in files:
		if not file_name.ends_with(".json"):
			continue

		var hero := _load_hero("%s/%s" % [HERO_DATA_DIR, file_name])
		if not hero.is_empty():
			heroes.append(hero)

	heroes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["name"]).nocasecmp_to(String(b["name"])) < 0
	)
	return heroes


static func _load_hero(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Unable to read hero data: %s" % path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid hero JSON: %s" % path)
		return {}

	var hero_data: Dictionary = parsed
	var id := String(hero_data.get("id", "")).strip_edges()
	var name := String(hero_data.get("name", "")).strip_edges()
	if id.is_empty() or name.is_empty():
		push_warning("Hero data requires id and name: %s" % path)
		return {}

	var art_path := "%s/%s.png" % [HERO_ASSET_DIR, id]
	if not ResourceLoader.exists(art_path):
		push_warning("Hero art not found: %s" % art_path)

	return {
		"id": id,
		"name": name,
		"art_path": art_path,
	}
