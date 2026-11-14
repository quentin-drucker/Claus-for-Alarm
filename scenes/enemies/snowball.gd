extends Node3D
## Greybox snowball. Holds simulation state only; the Match moves it on simulation ticks.

## Layer colours (A-01 enemy swatches) — presentation only, never read by the simulation.
const COLORS: Dictionary[StringName, Color] = {
	&"powder": Color("dbe9f5"), &"blue": Color("72cef5"), &"mint": Color("4acaaa"),
	&"violet": Color("bd8df1"), &"coral": Color("f59471"),
}

var def: EnemyDefinition
var entity_id: int = 0
## Metres travelled along the track from the entry.
var distance: float = 0.0


func setup(definition: EnemyDefinition, id: int) -> void:
	def = definition
	entity_id = id
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = COLORS.get(def.id, Color.WHITE)
	$Mesh.material_override = material
