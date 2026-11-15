extends SceneTree
## DEC-049 screen finish (vignette + powder): the autoload is a single overlay above every game layer and popup
## canvas, never takes mouse input, toggles OFF/ON, and stays single across scene changes.
## Run: godot --headless --path . -s res://tests/test_screen_finish.gd   (exit 1 = failure)

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var script: Script = load("res://scripts/presentation/screen_finish.gd")
	var finish: CanvasLayer = root.get_node("ScreenFinish")
	_check(finish.layer > 1024, "above the embedded-popup canvas (1024)")
	var rect: Control = finish.get_child(0)
	_check(rect.mouse_filter == Control.MOUSE_FILTER_IGNORE, "overlay ignores the mouse")
	finish.enabled = false
	_check(not finish.visible, "OFF hides the pass")
	finish.enabled = true
	change_scene_to_file("res://scenes/ui/title_screen.tscn")
	await process_frame
	await process_frame
	var overlays: int = 0
	for child: Node in root.get_children():
		if child.get_script() == script:
			overlays += 1
	_check(overlays == 1, "one overlay after a scene change")
	print("test_screen_finish: ", "PASS" if _failures == 0 else "FAIL (%d)" % _failures)
	quit(1 if _failures > 0 else 0)
