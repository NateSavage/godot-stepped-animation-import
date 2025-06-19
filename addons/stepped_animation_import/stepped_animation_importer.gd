@tool
extends EditorScenePostImportPlugin

const option_name = "animation/stepped"


func _get_import_options(path: String):
	add_import_option(option_name, true)


func _post_process(scene: Node):
	if(get_option_value(option_name) == false):
		return
		
	print("%s post import, converting animations to stepped..." % scene.name)
	iterate(scene)
	return scene
	
	
func iterate(node: Node):
	if node is AnimationPlayer == false:
		for child in node.get_children():
			iterate(child);
		return
		
	var animation_player = node as AnimationPlayer

	for anim_name in animation_player.get_animation_list():
		print("- %s" % anim_name)
		var animation = animation_player.get_animation(anim_name)
		set_interpolation_type(animation, Animation.InterpolationType.INTERPOLATION_NEAREST)


func set_interpolation_type(animation: Animation, interpolation: Animation.InterpolationType):
	var track_count = animation.get_track_count()
	for track_id in track_count:
		animation.track_set_interpolation_type(track_id, interpolation)
