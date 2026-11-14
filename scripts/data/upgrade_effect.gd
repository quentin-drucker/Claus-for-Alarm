class_name UpgradeEffect
extends Resource
## One stat mutation of an upgrade (P09-T03). A tower rebuilds its working stats from its definition and
## applies every owned tier's effects in path order (top, middle, bottom), then tier, then list order.
## Values come from the upgrade's source page; provenance lives on the UpgradeDefinition (status "effects").

enum Op { ADD, MULTIPLY, SET, APPEND }

## Attack id anywhere in the tower's attack tree; empty = the tower itself (range_units, pickups_per_round, ...).
## An effect whose attack is absent (added by a path the tower does not own) changes nothing.
@export var target: StringName
## Property to change. APPEND: an Array[AttackDefinition] property (attacks, on_contact, on_expire).
@export var field: StringName
@export var op: Op = Op.ADD
@export var value: float = 0.0
## SET of a StringName property (damage_type) uses this instead of `value`.
@export var text: StringName
## APPEND: the attack added (deep-copied per tower).
@export var attack: AttackDefinition
