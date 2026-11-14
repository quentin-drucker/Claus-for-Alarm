extends Node
## Autoload `Content`: loads and validates all balance data under res://resources (P02-T03/T10).
## Read-only at runtime; changing a stat means editing a .tres, never a HUD or combat script.

const ROOT: String = "res://resources/"

var towers: Array[TowerDefinition] = []
var enemies: Dictionary[StringName, EnemyDefinition] = {}
var rounds: Array[RoundDefinition] = []
var hero: HeroDefinition
var rules: MatchRules
var errors: PackedStringArray = []


func _ready() -> void:
	load_from(ROOT)
	for error: String in errors:
		push_error("Content: " + error)


func load_from(root: String) -> void:
	towers.clear()
	enemies.clear()
	rounds.clear()
	hero = null
	rules = null
	var all: Array[GameDefinition] = []
	for folder: String in ["towers", "enemies", "rounds", "heroes", "rules"]:
		var files: PackedStringArray = ResourceLoader.list_directory(root + folder)
		files.sort()  # list_directory order is not deterministic
		for file: String in files:
			if file.ends_with(".tres"):
				all.append(load(root + folder + "/" + file) as GameDefinition)
	errors = PackedStringArray()
	var ids: Dictionary[StringName, bool] = {}
	for def: GameDefinition in all:
		if def == null:
			errors.append("a file under %s is not a GameDefinition" % root)
			continue
		if ids.has(def.id):
			errors.append("duplicate id %s" % def.id)
		ids[def.id] = true
		if def is HeroDefinition:  # before TowerDefinition: a hero is a TowerDefinition
			hero = def
		elif def is TowerDefinition:
			towers.append(def)
		elif def is EnemyDefinition:
			enemies[def.id] = def
		elif def is RoundDefinition:
			rounds.append(def)
		elif def is MatchRules:
			rules = def
	errors.append_array(validate())


## Cross-reference checks on top of each definition's own validate(). Callable on hand-built fixtures.
func validate() -> PackedStringArray:
	var out: PackedStringArray = []
	if rules == null:
		out.append("no MatchRules")
	if hero == null:
		out.append("no HeroDefinition")
	var defs: Array[GameDefinition] = []
	defs.append_array(towers)
	defs.append_array(enemies.values())
	defs.append_array(rounds)
	if hero:
		defs.append(hero)
	if rules:
		defs.append(rules)
	for def: GameDefinition in defs:
		out.append_array(def.validate())
	for enemy: EnemyDefinition in enemies.values():
		if enemy.child_id != &"" and not enemies.has(enemy.child_id):
			out.append("%s: undefined child type %s" % [enemy.id, enemy.child_id])
		elif rbe(enemy.id) < 0:
			out.append("%s: child chain loops (a round with it could never end)" % enemy.id)
	for round_def: RoundDefinition in rounds:
		for group: SpawnGroup in round_def.groups:
			if not enemies.has(group.enemy_id):
				out.append("%s: undefined enemy %s" % [round_def.id, group.enemy_id])
	return out


## Red Bloon Equivalent: pops to fully destroy one enemy incl. descendants; also its leak damage.
## Returns -1 for a looping or broken child chain.
func rbe(enemy_id: StringName, depth: int = 0) -> int:
	var enemy: EnemyDefinition = enemies.get(enemy_id)
	if enemy == null or depth > enemies.size():
		return -1
	if enemy.child_count == 0:
		return 1
	var child: int = rbe(enemy.child_id, depth + 1)
	return -1 if child < 0 else 1 + enemy.child_count * child


func round_rbe(index: int) -> int:
	var total: int = 0
	for group: SpawnGroup in rounds[index].groups:
		total += group.count * rbe(group.enemy_id)
	return total


func get_tower(tower_id: StringName) -> TowerDefinition:
	for tower: TowerDefinition in towers:
		if tower.id == tower_id:
			return tower
	return null


## Development report: one line per balance value with its provenance status (P02-T03/T11).
func status_report() -> String:
	var lines: PackedStringArray = []
	var defs: Array[GameDefinition] = []
	if rules:
		defs.append(rules)
	defs.append_array(towers)
	for tower: TowerDefinition in towers:
		defs.append_array(tower.attacks)
		defs.append_array(tower.upgrades)
	if hero:
		defs.append_array([hero, hero.attacks[0]])
	defs.append_array(enemies.values())
	for def: GameDefinition in defs:
		for field: String in def.balance_fields():
			lines.append("%s.%s = %s [%s]" % [def.id, field, def.get(field), def.status.get(field, "MISSING")])
	for round_def: RoundDefinition in rounds:
		lines.append("%s.groups (%d, RBE %d) [%s]" % [round_def.id, round_def.groups.size(),
				round_rbe(rounds.find(round_def)), round_def.status.get("groups", "MISSING")])
	return "\n".join(lines)
