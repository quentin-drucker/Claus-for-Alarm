class_name MatchRules
extends GameDefinition
## Difficulty-level match rules (M-04, decision D-04).

@export var start_cash: int = 650
@export var start_lives: int = 150
## End-of-round bonus = round_bonus_base + round number.
@export var round_bonus_base: int = 100
@export var sell_ratio: float = 0.7


func balance_fields() -> PackedStringArray:
	return ["start_cash", "start_lives", "round_bonus_base", "sell_ratio"]
