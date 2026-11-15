extends SceneTree
## Dev 13 upgrade audit: Hot Cocoa Barrier (Wall of Fire) leaves a damaging zone on the track that expires, and the
## substitute upgrades for MOAB-class / camo-reveal effects give real stats (Big-Game Breaker blast damage, Giant
## Snowball Wax pierce, Goggle Shimmer attack speed). Every tier 1-3 upgrade changes the tower's stats.
## Run: godot --headless --path . -s res://tests/test_audit.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _find(tower: Node3D, id: StringName) -> Resource:
	for a: Resource in tower.attacks:
		for sub: Resource in a.tree():
			if sub.id == id:
				return sub
	return null


func _snapshot(tower: Node3D) -> String:
	var parts: PackedStringArray = [str(tower.range_units), str(tower.pickups_per_round), str(tower.cash_per_pickup),
			str(tower.pickup_lifetime_s), str(tower.auto_collect_ratio), str(tower.bank_capacity), str(tower.sell_bonus)]
	for a: Resource in tower.attacks:
		for sub: Resource in a.tree():
			parts.append(var_to_str([sub.id, sub.damage, sub.pierce, sub.interval_s, sub.projectile_count, sub.radius_units,
					sub.slow_factor, sub.slow_duration_s, sub.soaks_layers, sub.detects_camo, sub.bonus_vs_camo,
					sub.dot_damage, sub.dot_interval_s, sub.damage_type, sub.bounce_range_units, sub.projectile_lifetime_s,
					sub.spread_deg, sub.zone_duration_s]))
	return ",".join(parts)


func _run() -> void:
	var content: Node = root.get_node("Content")
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	await process_frame
	m.ledger.credit(0, 100000, &"test", 0)

	# Every purchasable tier changes something (no dead upgrades).
	for def: Resource in content.towers:
		var t: Node3D = m.try_place(def, Vector2(2.0, 0))
		if t == null:
			_check(false, "%s placeable: %s" % [def.id, m.placement_reason(def, Vector2(2.0, 0))])
			continue
		for path: int in 3:
			for tier: int in range(1, 4):
				t.tiers = Vector3i.ZERO
				t.tiers[path] = tier - 1
				t.rebuild_stats()
				var before: String = _snapshot(t)
				t.tiers[path] = tier
				t.rebuild_stats()
				_check(_snapshot(t) != before, "%s path %d tier %d changes stats" % [def.id, path, tier])
		m.sell(t)

	# Hot Cocoa Barrier: a zone that damages snowballs inside it, then burns out.
	var sorc: Node3D = m.try_place(content.get_tower(&"snow_sorcerer"), Vector2(2.0, 0))
	sorc.tiers = Vector3i(0, 2, 0)
	sorc.rebuild_stats()
	var wall: Resource = _find(sorc, &"snow_sorcerer_wall")
	_check(wall != null and wall.zone_duration_s > 0.0 and wall.radius_units > 0.0, "wall is a zone attack")
	m._spawn(&"coral")
	var coral: Node3D = m.snowballs[-1]
	coral.distance = 20.0
	coral.position = m.course.position_at(20.0)
	m._place_zone(wall, coral.position, sorc.entity_id)
	_check(m.zones.size() == 1 and m.zones[0].node.is_inside_tree(), "zone placed with its visual")
	for k: int in 3:
		m._tick_zones(0.2)
	_check(sorc.pops >= 3, "zone pops the snowball standing in it (%d pops)" % sorc.pops)
	for k: int in 30:
		m._tick_zones(0.2)
	_check(m.zones.is_empty(), "zone burns out after its duration")
	m.sell(sorc)

	# Substitutes.
	var cannon: Node3D = m.try_place(content.get_tower(&"avalanche_cannon"), Vector2(2.0, 0))
	cannon.tiers = Vector3i(0, 3, 0)
	cannon.rebuild_stats()
	_check(_find(cannon, &"avalanche_cannon_blast").damage == 2, "Big-Game Breaker: blast damage 2")
	m.sell(cannon)
	var wax: Node3D = m.try_place(content.get_tower(&"slope_wax_sprayer"), Vector2(2.0, 0))
	wax.tiers = Vector3i(0, 0, 3)
	wax.rebuild_stats()
	_check(_find(wax, &"slope_wax_sprayer_base").pierce == 4, "Giant Snowball Wax: pierce 1 + 3")
	m.sell(wax)
	var sorc2: Node3D = m.try_place(content.get_tower(&"snow_sorcerer"), Vector2(2.0, 0))
	sorc2.tiers = Vector3i(0, 0, 3)
	sorc2.rebuild_stats()
	_check(is_equal_approx(_find(sorc2, &"snow_sorcerer_base").interval_s, 1.1 * 0.75), "Goggle Shimmer: 25% faster")
	m.free()
	print("test_audit: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
