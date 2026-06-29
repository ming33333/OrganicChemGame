extends Control

@onready var narrative_label: Label = $Layout/Top/Narrative
@onready var moves_label: Label = $Layout/Top/MovesLabel
@onready var start_panel: PanelContainer = $Layout/Workbench/CompareRow/StartPanel
@onready var current_panel: PanelContainer = $Layout/Workbench/CompareRow/CurrentPanel
@onready var target_panel: PanelContainer = $Layout/Workbench/CompareRow/TargetPanel
@onready var start_name: Label = $Layout/Workbench/CompareRow/StartPanel/VBox/Name
@onready var current_name: Label = $Layout/Workbench/CompareRow/CurrentPanel/VBox/Name
@onready var target_name: Label = $Layout/Workbench/CompareRow/TargetPanel/VBox/Name
@onready var start_icon: TextureRect = $Layout/Workbench/CompareRow/StartPanel/VBox/Icon
@onready var current_icon: TextureRect = $Layout/Workbench/CompareRow/CurrentPanel/VBox/Icon
@onready var target_icon: TextureRect = $Layout/Workbench/CompareRow/TargetPanel/VBox/Icon
@onready var spell_grid: GridContainer = $Layout/SpellPalette/VBox/Scroll/SpellGrid
@onready var undo_button: Button = $Layout/BottomBar/UndoButton
@onready var hint_button: Button = $Layout/BottomBar/HintButton
@onready var back_button: Button = $Layout/BottomBar/BackButton
@onready var feedback_label: Label = $Layout/BottomBar/Feedback

var _level_id: String = ""


func _ready() -> void:
	PuzzleEngine.state_changed.connect(_on_state_changed)
	PuzzleEngine.puzzle_solved.connect(_on_solved)
	PuzzleEngine.puzzle_failed.connect(_on_failed)
	undo_button.pressed.connect(_on_undo)
	hint_button.pressed.connect(_on_hint)
	back_button.pressed.connect(_on_back)


func setup(data: Dictionary = {}) -> void:
	_level_id = str(data.get("level_id", get_tree().current_scene.pending_level_id))
	if not PuzzleEngine.load_level(_level_id):
		feedback_label.text = "Failed to load level."
		return
	var level: Dictionary = ContentDB.get_level(_level_id)
	narrative_label.text = level.get("narrative", "")
	_refresh_all()


func _refresh_all() -> void:
	_refresh_compare()
	_refresh_spells()
	_refresh_moves()


func _refresh_compare() -> void:
	var level: Dictionary = ContentDB.get_level(_level_id)
	var start_mol: Dictionary = ContentDB.get_molecule(level.get("start_molecule", ""))
	var current_mol: Dictionary = ContentDB.get_molecule(PuzzleEngine.state.current_molecule)
	var goal_mol: Dictionary = ContentDB.get_molecule(level.get("goal_molecule", ""))

	_set_molecule_display(start_panel, start_name, start_icon, start_mol)
	_set_molecule_display(current_panel, current_name, current_icon, current_mol)
	_set_molecule_display(target_panel, target_name, target_icon, goal_mol)


func _set_molecule_display(_panel: PanelContainer, name_label: Label, icon: TextureRect, mol: Dictionary) -> void:
	name_label.text = mol.get("fantasy_name", mol.get("id", "?"))
	var icon_id: String = mol.get("icon", "molecule_alkane")
	var path := "res://assets/sprites/%s.png" % icon_id
	if ResourceLoader.exists(path):
		icon.texture = load(path)


func _refresh_spells() -> void:
	for child in spell_grid.get_children():
		child.queue_free()

	var moves: Array = PuzzleEngine.get_legal_moves()
	if moves.is_empty():
		var lbl := Label.new()
		lbl.text = "No spells available for this material."
		spell_grid.add_child(lbl)
		return

	for move in moves:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(96, 96)
		btn.text = move.fantasy_name
		btn.tooltip_text = "Cost: %d gold" % int(move.cost)
		var icon_path := "res://assets/sprites/%s.png" % move.get("icon", "spell_water")
		if ResourceLoader.exists(icon_path):
			btn.icon = load(icon_path)
			btn.expand_icon = true
		btn.pressed.connect(_on_spell_pressed.bind(move.reaction_id))
		spell_grid.add_child(btn)


func _refresh_moves() -> void:
	var level: Dictionary = ContentDB.get_level(_level_id)
	var max_moves: Variant = level.get("max_moves", null)
	if max_moves == null:
		moves_label.text = "Moves: %d" % PuzzleEngine.state.move_count
	else:
		moves_label.text = "Moves: %d / %d" % [PuzzleEngine.state.move_count, int(max_moves)]


func _on_spell_pressed(reaction_id: String) -> void:
	var result: Dictionary = PuzzleEngine.apply_move(reaction_id)
	if result.ok:
		feedback_label.text = "The reaction succeeds!"
	else:
		feedback_label.text = result.get("error", "That spell cannot be cast here.")


func _on_state_changed(_state: Dictionary) -> void:
	_refresh_all()


func _on_solved(stars: Dictionary) -> void:
	GameState.complete_level(_level_id, int(stars.stars), stars)
	get_tree().current_scene.go_to("results", {"results": stars, "level_id": _level_id})


func _on_failed(reason: String) -> void:
	feedback_label.text = reason


func _on_undo() -> void:
	if PuzzleEngine.undo():
		feedback_label.text = "Undid last spell."
	else:
		feedback_label.text = "Nothing to undo."


func _on_hint() -> void:
	var path: Array = PuzzleEngine.hint_shortest_path()
	if path.is_empty():
		feedback_label.text = "You're already at the goal — or no path found."
		return
	var reaction_id: String = path[0]
	var reaction: Dictionary = ContentDB.get_reaction(reaction_id)
	feedback_label.text = "Hint: try %s" % reaction.get("fantasy_name", reaction_id)


func _on_back() -> void:
	get_tree().current_scene.go_to("chapter_select")
