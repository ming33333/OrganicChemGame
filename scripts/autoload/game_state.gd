extends Node
## Meta-progression: guild rank, unlocks, currency.

signal profile_changed

var guild_rank: String = "apprentice"
var currency: int = 0
var unlocked_reactions: Array = []
var level_progress: Dictionary = {}


func _ready() -> void:
	SaveManager.load_profile(self)


func complete_level(level_id: String, stars: int, stats: Dictionary) -> void:
	var existing: Dictionary = level_progress.get(level_id, {})
	var best_stars: int = int(existing.get("stars", 0))
	var moves: int = int(stats.get("moves", 999))
	var cost: int = int(stats.get("cost", 9999))
	level_progress[level_id] = {
		"completed": true,
		"stars": maxi(best_stars, stars),
		"best_moves": moves if existing.is_empty() else mini(int(existing.get("best_moves", moves)), moves),
		"best_cost": cost if existing.is_empty() else mini(int(existing.get("best_cost", cost)), cost),
	}
	var new_gold: int = stars * 10 + 5
	currency += new_gold
	_unlock_chapter_reactions(level_id)
	profile_changed.emit()
	SaveManager.save_profile(self)


func get_level_stars(level_id: String) -> int:
	return int(level_progress.get(level_id, {}).get("stars", 0))


func is_level_completed(level_id: String) -> bool:
	return level_progress.get(level_id, {}).get("completed", false)


func _unlock_chapter_reactions(level_id: String) -> void:
	var level: Dictionary = ContentDB.get_level(level_id)
	for reaction_id in level.get("allowed_reactions", []):
		if reaction_id not in unlocked_reactions:
			unlocked_reactions.append(reaction_id)
