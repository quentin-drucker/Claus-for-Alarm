extends Node
## Autoload `Audio` (P18-T04/T06/T07/T08): the one place gameplay Events become sound. Presentation only: it listens
## to Events, scene changes and buttons, and never feeds back into the simulation. Buses: tower attacks + snowball hits
## on "Towers" (feeds "SFX"; own Settings slider, default 50%), other SFX on "SFX", "Music", "Ambience".
## Sounds: licensed Willosuna packs built by scripts/audio/build_sfx.py (provenance: assets/audio/CREDITS.md).

const SFX_DIR: String = "res://assets/audio/sfx/"
const MUSIC_DIR: String = "res://assets/audio/music/"
const MAX_VARIANTS: int = 12
## slot: [volume_db, voices per variant, random pitch spread (1 = none), min gap between starts in s].
## Frequent combat sounds are quiet, rate-limited and capped (A-10: merge pop storms); warnings (leak, immune,
## deny) never change pitch so they always read the same; player actions sit above combat.
const SFX: Dictionary[StringName, Array] = {
	&"crunch": [-8.0, 1, 1.06, 0.03], &"crunch_heavy": [-4.0, 1, 1.05, 0.07],
	&"immune": [-11.0, 2, 1.0, 0.12], &"leak": [-4.0, 1, 1.0, 0.35],
	&"throw": [-12.0, 3, 1.1, 0.07], &"cannon_fire": [-9.0, 2, 1.08, 0.1], &"cannon_boom": [-4.0, 3, 1.08, 0.09],
	&"ranger": [-10.0, 3, 1.06, 0.06], &"chime": [-12.0, 2, 1.06, 0.12], &"fireball": [-9.0, 2, 1.06, 0.12],
	&"wax": [-7.0, 2, 1.1, 0.1], &"hero_shot": [-7.0, 3, 1.08, 0.06],
	&"place": [-5.0, 2, 1.04, 0.0], &"place_hero": [-5.0, 1, 1.0, 0.0], &"upgrade": [-5.0, 2, 1.0, 0.0],
	&"sell": [-6.0, 2, 1.0, 0.0], &"deny": [-6.0, 1, 1.0, 0.15], &"ticket": [-9.0, 3, 1.05, 0.06],
	&"ticket_bank": [-12.0, 2, 1.08, 0.05], &"ticket_spawn": [-13.0, 2, 1.08, 0.05],
	&"frenzy": [-3.0, 1, 1.0, 0.0], &"focus_on": [-7.0, 1, 1.0, 0.0], &"focus_off": [-8.0, 1, 1.0, 0.0],
	&"level_up": [-5.0, 1, 1.0, 0.0], &"ability_ready": [-8.0, 1, 1.0, 0.5],
	&"round_start": [-6.0, 1, 1.0, 0.0], &"round_complete": [-5.0, 1, 1.0, 0.0],
	&"click": [-8.0, 2, 1.04, 0.03], &"hover": [-18.0, 1, 1.04, 0.06]}
## Slots on the "Towers" bus. Owner: tower sounds +40% louder (+5 dB above the first mix) at the 50% default.
const TOWER_SLOTS: Array[StringName] = [&"crunch", &"crunch_heavy", &"throw", &"cannon_fire", &"cannon_boom",
	&"ranger", &"chime", &"fireball", &"wax", &"hero_shot"]
## attack_fired tag prefix -> sound; first match wins. Wax has none: its splat plays when the slow lands.
const ATTACK_SFX: Array[Array] = [["snow_sorcerer_fireball", &"fireball"], ["snowball_rookie", &"throw"],
	["avalanche_cannon", &"cannon_fire"], ["biathlon_ranger", &"ranger"], ["snow_sorcerer", &"chime"],
	["camel_claus", &"hero_shot"]]
## Broken layer -> crunch pitch: outer Powder bright and light, deep Coral fuller (camo shares its colour).
## Other shells (Black / White / Aurora; Aurora's id stays `purple`) use crunch_heavy.
const LAYER_PITCH: Dictionary[String, float] = {"powder": 1.18, "blue": 1.1, "mint": 1.02, "violet": 0.95, "coral": 0.88}
const MUSIC_LOOPS: Dictionary[StringName, bool] = {&"menu": true, &"gameplay": true, &"victory": false, &"defeat": false}
const AMBIENCE_DIR: String = "res://assets/audio/ambience/"
## Ambience beds (atonal wind + festive crowd, ~12 dB under the music so they never fight it): level when on.
const AMBIENCE_DB: Dictionary[StringName, float] = {&"wind": -12.0, &"market_calm": -13.0, &"market_intense": -15.0}
const AMBIENCE_MENU: Array[StringName] = [&"wind"]
const AMBIENCE_MATCH: Array[StringName] = [&"wind", &"market_calm"]
const AMBIENCE_LATE: Array[StringName] = [&"wind", &"market_intense"]
## From this round the crowd swells to the intense market bed (wave escalation, P18-T01).
const LATE_ROUND: int = 16
const MUSIC_DB: float = -7.0
const SILENT_DB: float = -40.0
const CROSSFADE_S: float = 1.2
const DUCK_DB: float = -8.0

var _players: Dictionary[StringName, Array] = {}
var _last_start: Dictionary[StringName, int] = {}
var _last_variant: Dictionary[StringName, int] = {}
## entity_id -> definition id, from tower_placed: lets the Cannon's own hits play its blast.
var _tower_kind: Dictionary[int, String] = {}
var _music: Array[AudioStreamPlayer] = [AudioStreamPlayer.new(), AudioStreamPlayer.new()]
var _music_slot: StringName = &""
var _ambience: Dictionary[StringName, AudioStreamPlayer] = {}
var _ambience_on: Array[StringName] = []
## Browsers block audio until a user gesture; nothing plays before the first click/key/touch (A-10, P18-T08).
var _unlocked: bool = not OS.has_feature("web")
var _duck: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for slot: StringName in SFX:
		var variants: Array[AudioStreamPlayer] = []
		for path: String in _variant_paths(slot):
			var player: AudioStreamPlayer = AudioStreamPlayer.new()
			player.stream = load(path)
			player.volume_db = SFX[slot][0]
			player.max_polyphony = SFX[slot][1]
			player.bus = &"Towers" if slot in TOWER_SLOTS else &"SFX"
			add_child(player)
			variants.append(player)
		if variants.is_empty():
			push_error("Audio: no file for SFX slot %s" % slot)
		_players[slot] = variants
	for player: AudioStreamPlayer in _music:
		player.bus = &"Music"
		add_child(player)
	for bed: StringName in AMBIENCE_DB:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		var stream: AudioStreamOggVorbis = load(AMBIENCE_DIR + bed + ".ogg")
		stream.loop = true
		player.stream = stream
		player.bus = &"Ambience"
		player.volume_db = SILENT_DB
		add_child(player)
		_ambience[bed] = player
	Events.emitted.connect(_on_event)
	get_tree().node_added.connect(_on_node_added)
	# The main scene is already in the tree before autoloads get _ready, so node_added missed its buttons.
	for button: Node in get_tree().root.find_children("*", "BaseButton", true, false):
		_on_node_added(button)
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed.call_deferred()


func _input(event: InputEvent) -> void:
	if not _unlocked and event.is_pressed() and (event is InputEventMouseButton or event is InputEventKey
			or event is InputEventScreenTouch):
		_unlocked = true
		var slot: StringName = _music_slot
		_music_slot = &""
		play_music(slot)
		set_ambience(_ambience_on)


## Plays a slot: a random variant (never the same one twice in a row), small random pitch and level, times
## `pitch`. Skipped if the slot started less than its min gap ago, which merges pop storms in big waves.
func play(slot: StringName, pitch: float = 1.0) -> void:
	if not _unlocked or _players[slot].is_empty():
		return
	var now: int = Time.get_ticks_msec()
	if now - _last_start.get(slot, -100000) < SFX[slot][3] * 1000.0:
		return
	_last_start[slot] = now
	var variants: Array = _players[slot]
	var i: int = randi() % variants.size()
	if variants.size() > 1 and i == _last_variant.get(slot, -1):
		i = (i + 1) % variants.size()
	_last_variant[slot] = i
	var player: AudioStreamPlayer = variants[i]
	var spread: float = SFX[slot][2]
	player.pitch_scale = pitch * randf_range(1.0 / spread, spread)
	player.volume_db = SFX[slot][0] - (randf() * 1.5 if spread > 1.0 else 0.0)
	player.play()


## Crossfades to `slot` (no-op if already on it, or silence if its file isn't there).
func play_music(slot: StringName) -> void:
	if slot == _music_slot:
		return
	_music_slot = slot
	if not _unlocked:
		return
	var old: AudioStreamPlayer = _music[0]
	var new: AudioStreamPlayer = _music[1]
	_music.reverse()
	if old.playing:
		var fade: Tween = create_tween()
		fade.tween_property(old, ^"volume_db", SILENT_DB, CROSSFADE_S)
		fade.tween_callback(old.stop)
	var path: String = MUSIC_DIR + slot + ".ogg"
	if slot == &"" or not ResourceLoader.exists(path):
		return
	var stream: AudioStreamOggVorbis = load(path)
	stream.loop = MUSIC_LOOPS[slot]
	new.stream = stream
	# Jingles start at once; loops fade in under the outgoing track.
	new.volume_db = MUSIC_DB if not MUSIC_LOOPS[slot] else SILENT_DB
	new.play()
	if MUSIC_LOOPS[slot]:
		create_tween().tween_property(new, ^"volume_db", MUSIC_DB, CROSSFADE_S)


## Fades the ambience beds in `beds` up to their level and the rest out. All beds start together and keep running
## (silent when off), so the sample-aligned calm and intense market loops crossfade without a jump.
func set_ambience(beds: Array[StringName]) -> void:
	_ambience_on = beds
	if not _unlocked:
		return
	for bed: StringName in _ambience:
		var player: AudioStreamPlayer = _ambience[bed]
		if not player.playing:
			player.play()
		create_tween().tween_property(player, ^"volume_db", AMBIENCE_DB[bed] if bed in beds else SILENT_DB, 2.5)


## Lowers the Music bus for `seconds`, then recovers smoothly (hero ability).
func duck(seconds: float) -> void:
	var bus: int = AudioServer.get_bus_index(&"Music")
	if _duck:
		_duck.kill()
	_duck = create_tween()
	_duck.tween_method(func(db: float) -> void: AudioServer.set_bus_volume_db(bus, db),
			AudioServer.get_bus_volume_db(bus), DUCK_DB, 0.15)
	_duck.tween_interval(seconds)
	_duck.tween_method(func(db: float) -> void: AudioServer.set_bus_volume_db(bus, db), DUCK_DB, 0.0, 0.8)


func _on_event(e: GameEvent) -> void:
	var tag: String = e.tags[0] if e.tags.size() > 0 else ""
	match e.type:
		&"layer_broken":
			var colour: String = tag.trim_prefix("camo_")
			if LAYER_PITCH.has(colour):
				play(&"crunch", LAYER_PITCH[colour])
			else:
				play(&"crunch_heavy")
		&"enemy_hit":
			if _tower_kind.get(e.source_id, "") == "avalanche_cannon":
				play(&"cannon_boom")
		&"enemy_immune":
			play(&"immune")
		&"enemy_leaked":
			play(&"leak")
		&"tower_placed":
			_tower_kind[e.source_id] = tag
			play(&"place_hero" if tag == "camel_claus" else &"place")
		&"tower_upgraded":
			play(&"upgrade")
		&"tower_sold":
			_tower_kind.erase(e.source_id)
			play(&"sell")
		&"purchase_failed":
			play(&"deny")
		&"attack_fired":
			for pair: Array in ATTACK_SFX:
				if tag.begins_with(pair[0]):
					play(pair[1])
					break
		&"status_applied":
			if tag.begins_with("slope_wax_sprayer"):
				play(&"wax")
		&"income_collected":
			play(&"ticket")
		&"income_banked":
			play(&"ticket_bank")
		&"pickup_spawned":
			play(&"ticket_spawn")
		&"ability_ready":
			play(&"ability_ready")
		&"ability_used":
			if "snowball_frenzy" in e.tags:
				play(&"frenzy")
				duck(1.5)
			elif "focused_shot" in e.tags:
				play(&"focus_on" if e.magnitude > 0.0 else &"focus_off")
		&"hero_level_up":
			play(&"level_up")
		&"round_started":
			play(&"round_start")
			if e.magnitude >= LATE_ROUND:
				set_ambience(AMBIENCE_LATE)
		&"round_complete":
			play(&"round_complete")
		&"match_won":
			play_music(&"victory")
		&"match_lost":
			play_music(&"defeat")


## `<slot>.ogg`, or its variants `<slot>_01.ogg` ... `<slot>_12.ogg`.
func _variant_paths(slot: StringName) -> Array[String]:
	var single: String = SFX_DIR + slot + ".ogg"
	if ResourceLoader.exists(single):
		return [single]
	var out: Array[String] = []
	for i: int in range(1, MAX_VARIANTS + 1):
		var path: String = SFX_DIR + "%s_%02d.ogg" % [slot, i]
		if ResourceLoader.exists(path):
			out.append(path)
	return out


## Every Button anywhere gets the UI click and a quiet hover tick; no scene needs to know about audio.
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play.bind(&"click"))
		node.mouse_entered.connect(func() -> void:
			if not node.disabled:
				play(&"hover"))


func _on_scene_changed() -> void:
	var scene: Node = get_tree().current_scene
	if scene:
		_tower_kind.clear()
		var menu: bool = scene.scene_file_path.contains("title")
		play_music(&"menu" if menu else &"gameplay")
		set_ambience(AMBIENCE_MENU if menu else AMBIENCE_MATCH)
