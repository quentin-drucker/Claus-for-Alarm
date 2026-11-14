extends Node
## Autoload `Events`: one-way gameplay event bus (P02-T09). The simulation calls send(); UI/VFX/audio listen.

signal emitted(event: GameEvent)

const TYPES: PackedStringArray = [
	"tower_placed", "tower_sold", "purchase_failed", "tower_upgraded", "target_changed", "attack_fired",
	"enemy_spawned", "enemy_hit", "enemy_immune", "layer_broken", "enemy_split", "enemy_leaked",
	"status_applied", "ability_ready", "ability_used", "hero_level_up", "round_started", "round_complete",
	"income_collected", "income_banked", "pickup_spawned", "pickup_expired", "match_won", "match_lost"]

## Simulation tick stamped on events; the running match updates it every tick.
var tick: int = 0
## Subscriber stub until presentation exists: print every event (run with `-- --log-events`).
var log_events: bool = OS.get_cmdline_user_args().has("--log-events")


func send(type: StringName, source_id: int = 0, target_id: int = 0, magnitude: float = 0.0,
		position: Vector3 = Vector3.ZERO, tags: PackedStringArray = []) -> GameEvent:
	if type not in TYPES:
		push_error("Events: unknown event type %s" % type)
	var event: GameEvent = GameEvent.new()
	event.type = type
	event.tick = tick
	event.source_id = source_id
	event.target_id = target_id
	event.magnitude = magnitude
	event.position = position
	event.tags = tags
	if log_events:
		print(event)
	emitted.emit(event)
	return event
