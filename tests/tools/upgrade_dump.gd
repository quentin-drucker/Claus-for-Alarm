extends SceneTree
## Dev 13 audit: print every tower's base attacks and each upgrade (availability + effects) from the live data.
##   godot --headless --path . -s res://tests/tools/upgrade_dump.gd


func _initialize() -> void:
	_run.call_deferred()


func _attack(a: Resource, indent: String) -> String:
	var s: String = "%s%s dmg %d type %s pierce %d int %s rng? speed %s radius %s slow %s dot %d/%s proj %d spread %s bounce %s camo %s life %s" % [
		indent, a.id, a.damage, a.damage_type, a.pierce, a.interval_s, a.projectile_speed_units, a.radius_units,
		a.slow_factor, a.dot_damage, a.dot_interval_s, a.projectile_count, a.spread_deg, a.bounce_range_units,
		a.detects_camo, a.projectile_lifetime_s]
	for sub: Resource in a.on_contact:
		s += "\n" + _attack(sub, indent + "  contact> ")
	for sub: Resource in a.on_expire:
		s += "\n" + _attack(sub, indent + "  expire> ")
	return s


func _run() -> void:
	var content: Node = root.get_node("Content")
	for def: Resource in content.towers:
		print("=== %s $%d range %s" % [def.id, def.price, def.range_units])
		for a: Resource in def.attacks:
			print(_attack(a, "  "))
		for path: int in 3:
			for tier: int in range(1, 6):
				var u: Resource = def.get_upgrade(path, tier)
				if u == null:
					continue
				var effects: PackedStringArray = []
				for e: Resource in u.effects:
					effects.append("%s %s %s %s %s" % [e.field, e.op, e.value, e.text, e.attack.id if e.attack else ""])
				print("  P%d T%d %-26s $%-5d avail %s | %s" % [path, tier, u.display_name, u.price, u.is_available(), " ; ".join(effects)])
				for e: Resource in u.effects:
					if e.attack:
						print(_attack(e.attack, "      + "))
	quit(0)
