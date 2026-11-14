class_name SimClock
extends Node
## Fixed-step simulation clock (P02-T08). Gameplay state changes only inside `ticked`, never per render frame,
## so 1x/2x, frame rate and pause cannot change outcomes. Speed scales time; it never alters attack data (M-05).

signal ticked(dt: float)

const STEP: float = 1.0 / 60.0
## Long frames run at most this many steps; the rest is dropped (slow motion, never skipped events).
const MAX_STEPS_PER_FRAME: int = 12

var tick: int = 0
var speed: float = 1.0
var paused: bool = false
var _accumulator: float = 0.0


func _process(delta: float) -> void:
	advance(delta)


## Runs the steps owed for `real_delta` seconds of wall time; returns how many ran.
func advance(real_delta: float) -> int:
	if paused:
		return 0
	_accumulator += real_delta * speed
	var steps: int = 0
	while _accumulator >= STEP - 1e-9 and steps < MAX_STEPS_PER_FRAME:
		_accumulator -= STEP
		tick += 1
		steps += 1
		ticked.emit(STEP)
	if steps == MAX_STEPS_PER_FRAME:
		_accumulator = 0.0
	return steps
