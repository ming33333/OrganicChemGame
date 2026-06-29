extends Control

@onready var title_label: Label = $Panel/VBox/Title
@onready var stars_label: Label = $Panel/VBox/Stars
@onready var stats_label: Label = $Panel/VBox/Stats
@onready var continue_button: Button = $Panel/VBox/ContinueButton
@onready var retry_button: Button = $Panel/VBox/RetryButton

var _level_id: String = ""


func setup(data: Dictionary = {}) -> void:
	var results: Dictionary = data.get("results", get_tree().current_scene.pending_results)
	_level_id = str(data.get("level_id", get_tree().current_scene.pending_level_id))

	var star_count: int = int(results.get("stars", 0))
	var star_str := ""
	for i in range(3):
		star_str += "★ " if i < star_count else "☆ "

	title_label.text = "Transformation Complete!" if star_count > 0 else "Puzzle Complete"
	stars_label.text = star_str
	stats_label.text = "Moves: %d (par %d)\nCost: %d (par %d)\nToxicity: %.1f (par %.1f)" % [
		int(results.get("moves", 0)),
		int(results.get("par_moves", 0)),
		int(results.get("cost", 0)),
		int(results.get("par_cost", 0)),
		float(results.get("toxicity", 0)),
		float(results.get("par_toxicity", 0)),
	]

	continue_button.pressed.connect(_on_continue)
	retry_button.pressed.connect(_on_retry)


func _on_continue() -> void:
	get_tree().current_scene.go_to("chapter_select")


func _on_retry() -> void:
	get_tree().current_scene.go_to("puzzle", {"level_id": _level_id})
