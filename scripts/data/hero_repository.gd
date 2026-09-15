extends RefCounted

const HERO_DATA_DIR := "res://data/heroes"
const HERO_INDEX_PATH := HERO_DATA_DIR + "/index.json"
const HERO_ASSET_DIR := "res://assets/heroes"


static func load_all() -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	var manifest_file := FileAccess.open(HERO_INDEX_PATH, FileAccess.READ)
	if manifest_file == null:
		push_warning("Unable to read hero manifest: %s" % HERO_INDEX_PATH)
		return heroes

	var parsed_manifest = JSON.parse_string(manifest_file.get_as_text())
	if typeof(parsed_manifest) != TYPE_ARRAY:
		push_warning("Invalid hero manifest: %s" % HERO_INDEX_PATH)
		return heroes

	for file_name_variant in parsed_manifest:
		var file_name := String(file_name_variant).strip_edges()
		if file_name.is_empty():
			continue

		var hero := _load_hero("%s/%s" % [HERO_DATA_DIR, file_name])
		if not hero.is_empty():
			heroes.append(hero)

	heroes.sort_custom(_sort_by_name)
	return heroes


static func load_by_id(hero_id: String) -> Dictionary:
	for hero in load_all():
		if String(hero.get("id", "")) == hero_id:
			return hero

	push_warning("Hero not found: %s" % hero_id)
	return {}


static func _sort_by_name(a: Dictionary, b: Dictionary) -> bool:
	return String(a["name"]).nocasecmp_to(String(b["name"])) < 0


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
	var description := String(hero_data.get("description", "")).strip_edges()
	if id.is_empty() or name.is_empty():
		push_warning("Hero data requires id and name: %s" % path)
		return {}

	var art_path := "%s/%s.png" % [HERO_ASSET_DIR, id]
	if not FileAccess.file_exists(art_path):
		push_warning("Hero art not found: %s" % art_path)

	return {
		"id": id,
		"name": name,
		"description": description,
		"art_path": art_path,
	}
