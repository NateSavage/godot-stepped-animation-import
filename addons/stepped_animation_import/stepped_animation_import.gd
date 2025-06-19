@tool
extends EditorPlugin

var stepped_animation_importer

func _enter_tree() -> void:
	stepped_animation_importer = preload("res://addons/stepped_animation_import/stepped_animation_importer.gd").new()
	add_scene_post_import_plugin(stepped_animation_importer)


func _exit_tree() -> void:
	remove_scene_post_import_plugin(stepped_animation_importer)
	stepped_animation_importer = null
