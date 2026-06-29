extends Node
## Loads and validates all game content from JSON data files.

var molecules: Dictionary = {}
var reactions: Dictionary = {}
var chapters: Array = []
var levels: Dictionary = {}


func _ready() -> void:
	_load_all()


func _load_all() -> void:
	molecules = _load_json_dict("res://data/molecules.json", "id")
	reactions = _load_json_dict("res://data/reactions.json", "id")
	chapters = _load_json_array("res://data/chapters.json")
	for chapter in chapters:
		var path: String = chapter.get("levels_file", "")
		if path.is_empty():
			continue
		var chapter_levels: Array = _load_json_array(path)
		for level in chapter_levels:
			levels[level.id] = level
	print("[ContentDB] Loaded %d molecules, %d reactions, %d levels" % [
		molecules.size(), reactions.size(), levels.size()
	])


func _load_json_dict(path: String, key_field: String) -> Dictionary:
	var data: Variant = _load_json(path)
	var result: Dictionary = {}
	if data is Array:
		for item in data:
			result[item[key_field]] = item
	return result


func _load_json_array(path: String) -> Array:
	var data: Variant = _load_json(path)
	return data if data is Array else []


func _load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("[ContentDB] Missing file: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("[ContentDB] JSON parse error in %s" % path)
	return parsed


func get_molecule(id: String) -> Dictionary:
	return molecules.get(id, {})


func get_reaction(id: String) -> Dictionary:
	return reactions.get(id, {})


func get_level(id: String) -> Dictionary:
	return levels.get(id, {})


func get_chapter_levels(chapter_id: int) -> Array:
	var result: Array = []
	for level_id in levels:
		var level: Dictionary = levels[level_id]
		if int(level.get("chapter", 0)) == chapter_id:
			result.append(level)
	result.sort_custom(func(a, b): return int(a.order) < int(b.order))
	return result
