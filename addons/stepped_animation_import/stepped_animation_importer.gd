@tool
extends EditorScenePostImportPlugin

const option_name = "animation/stepped"

var _optimizer_enabled_players: Array[AnimationPlayer] = []


func _get_import_options(path: String):
	add_import_option(option_name, true)


func _internal_process(category: int, base_node: Node, node: Node, resource: Resource) -> void:
	if category != EditorScenePostImportPlugin.INTERNAL_IMPORT_CATEGORY_ANIMATION_NODE:
		return
	if node is AnimationPlayer and get_option_value("optimizer/enabled"):
		_optimizer_enabled_players.append(node)


func _post_process(scene: Node):
	if(get_option_value(option_name) == false):
		_optimizer_enabled_players.clear()
		return

	print("%s post import, converting animations to stepped..." % scene.name)
	iterate(scene)

	# The animation Optimizer strips keyframes assuming linear interpolation, which can delete
	# keyframes that Nearest/stepped interpolation needs (godotengine/godot#105385), silently
	# breaking the stepped result. Warn since this plugin can't recover keys already stripped.
	for player in _optimizer_enabled_players:
		push_warning("Stepped Animation Import: AnimationPlayer '%s' in '%s' still has the animation Optimizer enabled. The Optimizer can delete keyframes that stepped/Nearest interpolation needs, so this asset's stepped animation may not play back correctly. Disable Optimizer for this AnimationPlayer in Advanced Import Settings." % [scene.get_path_to(player), scene.name])
	_optimizer_enabled_players.clear()

	return scene
	
	
func iterate(node: Node):
	if node is AnimationPlayer:
		var animation_player = node as AnimationPlayer

		for anim_name in animation_player.get_animation_list():
			print("- %s" % anim_name)
			var animation = animation_player.get_animation(anim_name)
			set_interpolation_type(animation, Animation.InterpolationType.INTERPOLATION_NEAREST)

	# Recurse regardless of node type in case an AnimationPlayer has a nested
	# AnimationPlayer among its own children.
	for child in node.get_children():
		iterate(child)


func set_interpolation_type(animation: Animation, interpolation: Animation.InterpolationType):
	var track_id = 0
	while track_id < animation.get_track_count():
		# Bezier tracks always sample along their curve and ignore track_set_interpolation_type,
		# so the only way to make one step is to rebuild it as a value track from its keyed
		# values (dropping the bezier handles, since the curve shape is what we're removing).
		if animation.track_get_type(track_id) == Animation.TrackType.TYPE_BEZIER:
			convert_bezier_track_to_value(animation, track_id)
		animation.track_set_interpolation_type(track_id, interpolation)
		track_id += 1


func convert_bezier_track_to_value(animation: Animation, track_id: int) -> void:
	var path = animation.track_get_path(track_id)
	var enabled = animation.track_is_enabled(track_id)

	var times: Array[float] = []
	var values: Array[float] = []
	for key_id in animation.track_get_key_count(track_id):
		times.append(animation.track_get_key_time(track_id, key_id))
		# track_get_key_value on a bezier track returns the packed
		# [value, in.x, in.y, out.x, out.y] array, not the plain value.
		values.append(animation.bezier_track_get_key_value(track_id, key_id))

	animation.remove_track(track_id)
	var value_track_id = animation.add_track(Animation.TrackType.TYPE_VALUE, track_id)
	animation.track_set_path(value_track_id, path)
	animation.track_set_enabled(value_track_id, enabled)
	for i in times.size():
		animation.track_insert_key(value_track_id, times[i], values[i])
