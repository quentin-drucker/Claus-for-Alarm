extends SceneTree
## DEC-049 screen finish: the autoload is a single overlay above every game layer and popup canvas, never takes
## mouse input, toggles OFF/SUBTLE, and its pixel cell follows the UI scale in whole physical pixels.
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
	var base: Vector2 = Vector2(1152, 648)
	_check(script.cell_for(3.0, base, base) == 3.0, "base window keeps 3 px cells")
	_check(script.cell_for(3.0, Vector2(800, 600), base) == 2.0, "800x600 shrinks cells with the UI")
	_check(script.cell_for(3.0, Vector2(2304, 1296), base) == 6.0, "2x DPI doubles cells")
	_check(script.cell_for(1.0, Vector2(320, 180), base) == 1.0, "never below 1 physical px")

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
