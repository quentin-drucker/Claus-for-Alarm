extends CanvasLayer
## Lives under SceneTree.root across scene replacement. Draw loading UI before touching map resources.

var destination: String
var message: Label
var web_overlay: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	web_overlay = OS.has_feature("web") and bool(JavaScriptBridge.eval("typeof window.clausShowMapLoading === 'function'"))
	if web_overlay:
		JavaScriptBridge.eval("window.clausShowMapLoading();")
	else:
		_build_fallback()
	_load.call_deferred()


func _build_fallback() -> void:
	var panel: ColorRect = ColorRect.new()
	panel.color = Color("8e1f2e")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	message = Label.new()
	message.theme = preload("res://scripts/ui/lodge_theme.gd").get_theme()
	message.theme_type_variation = &"Heading"
	message.text = "Claus for Alarm\n\nPreparing the ski course..."
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 30)
	message.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(message)


func _load() -> void:
	# Yield to the browser compositor before any loading/scene construction can block.
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout
	var error: Error = ResourceLoader.load_threaded_request(destination, "PackedScene")
	if error != OK:
		_fail()
		return
	while true:
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(destination)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_fail()
			return
		await get_tree().process_frame
	var packed: PackedScene = ResourceLoader.load_threaded_get(destination) as PackedScene
	if packed == null:
		_fail()
		return
	var old_scene: Node = get_tree().current_scene
	var old_id: int = old_scene.get_instance_id() if old_scene else 0
	if get_tree().change_scene_to_packed(packed) != OK:
		_fail()
		return
	while get_tree().current_scene == null or get_tree().current_scene.get_instance_id() == old_id:
		await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	if web_overlay:
		JavaScriptBridge.eval("window.clausMapReady();")
	queue_free()


func _fail() -> void:
	if web_overlay:
		JavaScriptBridge.eval("window.clausLoadFailure('Could not load the ski course. Please try again.');")
	else:
		message.text = "Could not load the ski course.\nRestart the game to try again."
