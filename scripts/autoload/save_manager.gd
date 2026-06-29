extends Node
## Local save via user:// — offline-first progression.

const SAVE_PATH := "user://alchemist_save.json"
const SAVE_VERSION := 1


func save_profile(game_state: Node) -> void:
	var data := {
		"version": SAVE_VERSION,
		"guild_rank": game_state.guild_rank,
		"currency": game_state.currency,
		"unlocked_reactions": game_state.unlocked_reactions,
		"level_progress": game_state.level_progress,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_profile(game_state: Node) -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		return
	game_state.guild_rank = parsed.get("guild_rank", "apprentice")
	game_state.currency = int(parsed.get("currency", 0))
	game_state.unlocked_reactions = parsed.get("unlocked_reactions", [])
	game_state.level_progress = parsed.get("level_progress", {})
