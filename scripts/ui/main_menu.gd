extends Control

@onready var title_label: Label = $VBox/Title
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var play_button: Button = $VBox/PlayButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var gold_label: Label = $TopBar/GoldLabel
@onready var bg: TextureRect = $Background


func _ready() -> void:
	title_label.text = "Alchemist's Path"
	subtitle_label.text = "Transform matter. Master the guild spells."
	play_button.pressed.connect(_on_play)
	quit_button.pressed.connect(_on_quit)
	GameState.profile_changed.connect(_refresh_gold)
	_refresh_gold()
	if bg.texture == null:
		var tex := load("res://assets/sprites/bg_workshop.png") as Texture2D
		if tex:
			bg.texture = tex
			bg.stretch_mode = TextureRect.STRETCH_SCALE


func _refresh_gold() -> void:
	gold_label.text = "Gold: %d" % GameState.currency


func _on_play() -> void:
	get_tree().current_scene.go_to("chapter_select")


func _on_quit() -> void:
	get_tree().quit()
