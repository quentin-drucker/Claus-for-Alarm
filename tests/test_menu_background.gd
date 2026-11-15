extends SceneTree
## Menu integration: isolated 3D world, bounded orbit and source animation.

var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + label)


func _run() -> void:
	var title: Control = load("res://scenes/ui/title_screen.tscn").instantiate()
	root.add_child(title)
	var viewport: SubViewport = title.get_node("VillageBackdrop/VillageViewport")
	var background: Node3D = viewport.get_node("MenuBackground")
	check(viewport.own_world_3d and viewport.gui_disable_input, "menu has its own world and ignores GUI input")
	check(background.camera != null and background.camera.projection == Camera3D.PROJECTION_PERSPECTIVE,
			"perspective orbit camera exists")
	check(background.field_of_view_degrees >= 70, "wide field of view")
	check(is_equal_approx(background.camera_height_m, 6.5), "owner lowered orbit camera")
	var winter: Environment = background.get_node("WinterEnvironment").environment
	check(winter.background_mode == Environment.BG_SKY and winter.sky != null, "winter sky replaces flat abyss")
	check(winter.fog_enabled and winter.fog_depth_begin >= background.orbit_radius_m,
			"distance mist keeps central tree clear")
	check(background.get_node("SnowHorizon").position.y < -0.3, "snow horizon sits below source ice")
	check(background.sun_energy < 1.0 and background.ambient_energy < 0.5, "lighting stays below previous overbright setup")
	var before: Vector3 = background.camera.position
	background._process(1.0)
	check(background.camera.position.distance_to(before) > 0.01, "orbit advances")
	check(is_equal_approx(Vector2(background.camera.position.x, background.camera.position.z).length(),
			background.orbit_radius_m), "camera stays on tree-centered circle")
	var target: Vector3 = Vector3(0, background.look_at_height_m, 0)
	check((-background.camera.global_basis.z).dot((target - background.camera.global_position).normalized()) > 0.999,
			"camera looks at central tree")
	var player: AnimationPlayer = background.animation_player
	check(player != null and player.is_playing(), "imported ambient animation is playing")
	if player:
		var clip: Animation = player.get_animation(player.current_animation)
		check(clip.loop_mode == Animation.LOOP_LINEAR and clip.length > 10.0, "source animation loops")
		var smoke: Node3D = background.find_child("Smoke1", true, false)
		check(smoke != null, "original smoke mesh retained")
		if smoke:
			player.seek(0.0, true)
			var smoke_before: Transform3D = smoke.global_transform
			player.seek(1.8, true)
			check(not smoke.global_transform.is_equal_approx(smoke_before), "source smoke transforms animate")
		player.seek(clip.length - 0.05, true)
		player.advance(0.1)
		check(player.current_animation_position < 0.2, "ambient timeline wraps and keeps playing")
	check(not title.has_node("EnvironmentCredit") and not title.has_node("CreditShade"),
			"owner moved public attribution to website, with no menu credit bar")
	title.get_node("%HowButton").pressed.emit()
	check(title.get_node("%HowPanel").visible and not title.get_node("%Menu").visible, "How to Play still opens")
	title.get_node("%HowBack").pressed.emit()
	title.get_node("%SettingsButton").pressed.emit()
	check(title.get_node("%SettingsPanel").visible, "Settings still opens")
	title.free()
	await process_frame
	print("test_menu_background: %s" % ("PASS" if failures == 0 else "%d FAILURES" % failures))
	quit(1 if failures else 0)
