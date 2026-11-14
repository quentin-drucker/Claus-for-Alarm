class_name TowerDefinition
extends GameDefinition
## One regular tower family (M-06/M-07/M-10): base kit plus three 5-tier upgrade paths.

@export var display_name: String = ""
@export var source_tower: String = ""
## Medium price.
@export var price: int = 0
## Circular attack range in reference units (0 with global_range = whole map).
@export var range_units: float = 0.0
@export var global_range: bool = false
## Placement radius in reference units (Dart = 6).
@export var footprint_units: float = 6.0
@export var attacks: Array[AttackDefinition] = []
@export var upgrades: Array[UpgradeDefinition] = []
## Income towers (Ticket Booth): pickups per round and cash per pickup.
@export var pickups_per_round: int = 0
@export var cash_per_pickup: int = 0


func balance_fields() -> PackedStringArray:
	return ["price", "range_units", "footprint_units", "pickups_per_round", "cash_per_pickup"]


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	for attack: AttackDefinition in attacks:
		errors.append_array(attack.validate())
	var seen: Dictionary[Vector2i, bool] = {}
	for upgrade: UpgradeDefinition in upgrades:
		errors.append_array(upgrade.validate())
		var key: Vector2i = Vector2i(upgrade.path, upgrade.tier)
		if seen.has(key):
			errors.append("%s: duplicate upgrade path %d tier %d" % [id, key.x, key.y])
		seen[key] = true
	for key: Vector2i in seen:
		if key.y > 1 and not seen.has(Vector2i(key.x, key.y - 1)):
			errors.append("%s: path %d tier %d lacks its tier %d prerequisite" % [id, key.x, key.y, key.y - 1])
	return errors


func get_upgrade(path: int, tier: int) -> UpgradeDefinition:
	for upgrade: UpgradeDefinition in upgrades:
		if upgrade.path == path and upgrade.tier == tier:
			return upgrade
	return null


## BTD6 crosspath rule (M-07): one path up to 5, one other up to 2, the third stays 0.
static func is_legal_crosspath(tiers: Vector3i) -> bool:
	var sorted: Array[int] = [tiers.x, tiers.y, tiers.z]
	sorted.sort()
	return sorted[0] == 0 and sorted[1] <= 2 and sorted[2] <= 5


## Whether buying the next tier of `path` keeps the tower legal (also needs the upgrade to exist in data).
func can_upgrade(tiers: Vector3i, path: int) -> bool:
	var next: Vector3i = tiers
	next[path] += 1
	return is_legal_crosspath(next) and get_upgrade(path, next[path]) != null
