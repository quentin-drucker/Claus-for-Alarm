extends Node3D
## Greybox snowball. Holds simulation state only; the Match moves and damages it on simulation ticks.

## Layer colours (A-01 enemy swatches) — presentation only, never read by the simulation.
const COLORS: Dictionary[StringName, Color] = {
	&"powder": Color("dbe9f5"), &"blue": Color("72cef5"), &"mint": Color("4acaaa"),
	&"violet": Color("bd8df1"), &"coral": Color("f59471"),
}
## Dark outline so pale Powder still reads on snow (P05-T10); shared by every layer.
const OUTLINE: Color = Color("173548")

var def: EnemyDefinition
var entity_id: int = 0
## Metres travelled along the track from the entry.
var distance: float = 0.0


func setup(definition: EnemyDefinition, id: int) -> void:
	entity_id = id
	set_layer(definition)


## Current outer layer; a break swaps it in place, keeping id, distance and position.
func set_layer(definition: EnemyDefinition) -> void:
	def = definition
	var outline: StandardMaterial3D = StandardMaterial3D.new()
	outline.albedo_color = OUTLINE
	outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline.cull_mode = BaseMaterial3D.CULL_FRONT
	outline.grow = true
	outline.grow_amount = 0.04
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = COLORS.get(def.id, Color.WHITE)
	material.next_pass = outline
	$Mesh.material_override = material
