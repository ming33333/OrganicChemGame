extends Control

const SCENES := {
	"main_menu": "res://scenes/main_menu.tscn",
	"chapter_select": "res://scenes/chapter_select.tscn",
	"puzzle": "res://scenes/puzzle.tscn",
	"results": "res://scenes/results.tscn",
}

var pending_level_id: String = ""
var pending_results: Dictionary = {}


func _ready() -> void:
	go_to("main_menu")


func go_to(scene_key: String, data: Dictionary = {}) -> void:
	if data.has("level_id"):
		pending_level_id = str(data.level_id)
	if data.has("results"):
		pending_results = data.results

	for child in get_children():
		child.queue_free()

	var scene: PackedScene = load(SCENES[scene_key])
	var instance: Node = scene.instantiate()
	add_child(instance)

	if instance.has_method("setup"):
		instance.setup(data)
