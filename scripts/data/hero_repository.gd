extends RefCounted

const HERO_DATA_DIR := "res://data/heroes"
const HERO_INDEX_PATH := HERO_DATA_DIR + "/index.json"
const HERO_LIST_PATH := HERO_DATA_DIR + "/list.json"
const HERO_ASSET_DIR := "res://assets/heroes"


static func load_all() -> Array[Dictionary]:
	return _load_manifest(HERO_INDEX_PATH)


static func load_listed() -> Array[Dictionary]:
	return _load_manifest(HERO_LIST_PATH)


static func load_by_id(hero_id: String) -> Dictionary:
	var normalized_id := hero_id.strip_edges()
	if normalized_id.is_empty() or normalized_id.contains("/") or normalized_id.contains("\\") or normalized_id.contains(".."):
		push_warning("Invalid hero id: %s" % hero_id)
		return {}

	return _load_hero("%s/%s.json" % [HERO_DATA_DIR, normalized_id])


static func _load_manifest(manifest_path: String) -> Array[Dictionary]:
	var heroes: Array[Dictionary] = []
	var manifest_file := FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file == null:
		push_warning("Unable to read hero manifest: %s" % manifest_path)
		return heroes

	var parsed_manifest = JSON.parse_string(manifest_file.get_as_text())
	if typeof(parsed_manifest) != TYPE_ARRAY:
		push_warning("Invalid hero manifest: %s" % manifest_path)
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

	var fields := _read_string_array(hero_data, "fields", path)
	var elements := _read_string_array(hero_data, "elements", path)
	var evolutions := _read_string_array(hero_data, "evolutions", path)

	var art_path := "%s/%s.png" % [HERO_ASSET_DIR, id]
	if not FileAccess.file_exists(art_path):
		push_warning("Hero art not found: %s" % art_path)

	return {
		"id": id,
		"name": name,
		"description": description,
		"fields": fields,
		"elements": elements,
		"evolutions": evolutions,
		"art_path": art_path,
	}


static func _read_string_array(hero_data: Dictionary, key: String, path: String) -> Array[String]:
	var values: Array[String] = []
	var raw_value = hero_data.get(key, [])
	if typeof(raw_value) == TYPE_ARRAY:
		for value_variant in raw_value:
			var value := String(value_variant).strip_edges()
			if not value.is_empty():
				values.append(value)
	elif hero_data.has(key):
		push_warning("Hero %s must be an array: %s" % [key, path])

	return values
