class_name UpgradeDefinition
extends GameDefinition
## One tier of one upgrade path (M-07). Only tiers whose effects were read from their source page are
## purchasable (status "effects" VERIFIED_SOURCE / PATCHED_SOURCE); the rest show as "coming soon" (D-07).

const SHIPPED: PackedStringArray = ["VERIFIED_SOURCE", "PATCHED_SOURCE"]

## 0 = top, 1 = middle, 2 = bottom.
@export_range(0, 2) var path: int = 0
@export_range(1, 5) var tier: int = 1
@export var display_name: String = ""
@export var source_name: String = ""
## Medium price.
@export var price: int = 0
## Stat mutations (P09-T03), applied when owned.
@export var effects: Array[UpgradeEffect] = []


func balance_fields() -> PackedStringArray:
	return ["price"]


func is_available() -> bool:
	return status.get("effects", "") in SHIPPED and not effects.is_empty()


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if status.get("effects", "") in SHIPPED and effects.is_empty():
		errors.append("%s: effects marked verified but empty" % id)
	return errors
