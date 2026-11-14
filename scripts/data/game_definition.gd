class_name GameDefinition
extends Resource
## Base of all balance data. Every balance number carries a provenance status (master plan §7.3).

const STATUSES: PackedStringArray = [
	"VERIFIED_SOURCE", "PATCHED_SOURCE", "PROTOTYPE_ASSUMPTION",
	"ORIGINAL_DEVIATION", "UNKNOWN_REFERENCE", "NOT_APPLICABLE"]
## Godot metres per BTD6 reference map unit (P03-T03): range 32 -> 3.2 m, Powder speed 25 -> 2.5 m/s.
const UNIT_M: float = 0.1

@export var id: StringName
## Source page the VERIFIED/PATCHED values were read from.
@export var source_url: String = ""
## Balance field name -> one of STATUSES. Required for every name in balance_fields().
@export var status: Dictionary[String, String] = {}
@export_multiline var notes: String = ""


## Numeric fields that are balance values: each needs a status and must be >= 0.
func balance_fields() -> PackedStringArray:
	return []


func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id == &"":
		errors.append("%s: empty id" % resource_path)
	for field: String in balance_fields():
		if not status.has(field):
			errors.append("%s.%s: missing status" % [id, field])
		if get(field) < 0:
			errors.append("%s.%s: negative value %s" % [id, field, get(field)])
	for field: String in status:
		if status[field] not in STATUSES:
			errors.append("%s.%s: unknown status '%s'" % [id, field, status[field]])
	return errors
