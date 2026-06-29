extends Control

@onready var level_list: VBoxContainer = $Panel/Margin/VBox/Scroll/LevelList
@onready var back_button: Button = $Panel/Margin/VBox/BackButton
@onready var chapter_title: Label = $Panel/Margin/VBox/ChapterTitle


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_build_level_list()


func setup(_data: Dictionary = {}) -> void:
	_build_level_list()


func _build_level_list() -> void:
	for child in level_list.get_children():
		child.queue_free()

	var chapter: Dictionary = ContentDB.chapters[0] if ContentDB.chapters.size() > 0 else {}
	chapter_title.text = chapter.get("title", "Chapter 1")

	var levels: Array = ContentDB.get_chapter_levels(1)
	for level in levels:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var stars := GameState.get_level_stars(level.id)
		var star_text := ""
		for i in range(3):
			star_text += "★" if i < stars else "☆"

		var btn := Button.new()
		btn.text = "%s  %s" % [level.get("title", level.id), star_text]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_level_pressed.bind(level.id))
		row.add_child(btn)
		level_list.add_child(row)


func _on_level_pressed(level_id: String) -> void:
	get_tree().current_scene.go_to("puzzle", {"level_id": level_id})


func _on_back() -> void:
	get_tree().current_scene.go_to("main_menu")
