class_name UpgradeDefinition
extends GameDefinition
## One tier of one upgrade path (M-07). Attack/stat effects are added per upgrade once verified (P09).

## 0 = top, 1 = middle, 2 = bottom.
@export_range(0, 2) var path: int = 0
@export_range(1, 5) var tier: int = 1
@export var display_name: String = ""
@export var source_name: String = ""
## Medium price.
@export var price: int = 0


func balance_fields() -> PackedStringArray:
	return ["price"]
