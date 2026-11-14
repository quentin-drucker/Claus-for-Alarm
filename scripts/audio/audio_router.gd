extends Node
## Autoload `Audio` (P18-T04/T06/T07/T08): the one place gameplay Events become sound. Presentation only: it listens
## to Events and scene changes and never feeds back into the simulation. SFX go to the "SFX" bus, music to "Music".

const SFX_DIR: String = "res://assets/audio/sfx/"
const MUSIC_DIR: String = "res://assets/audio/music/"
## Drop `<slot>.ogg` (or .mp3) into assets/audio/music/; missing slots stay silent. Looping slots loop.
const MUSIC_LOOPS: Dictionary[StringName, bool] = {&"menu": true, &"gameplay": true, &"victory": false, &"defeat": false}
## name: [volume_db, max voices, random pitch (1 = none), min gap between starts in s]. Warnings (leak, immune,
## deny) get no pitch variation so they always read the same; frequent sounds get a gap + small voice cap.
const SFX: Dictionary[StringName, Array] = {
	&"pop_1": [-16.0, 3, 1.12, 0.035], &"pop_2": [-16.0, 3, 1.12, 0.035], &"pop_3": [-15.0, 3, 1.12, 0.035],
	&"pop_4": [-15.0, 3, 1.12, 0.035], &"pop_5": [-14.0, 3, 1.12, 0.035], &"pop_heavy": [-10.0, 2, 1.06, 0.08],
	&"immune": [-14.0, 2, 1.0, 0.12], &"leak": [-8.0, 1, 1.0, 0.3],
	&"place": [-8.0, 2, 1.05, 0.0], &"upgrade": [-9.0, 2, 1.0, 0.0], &"sell": [-9.0, 2, 1.0, 0.0],
	&"throw": [-22.0, 3, 1.15, 0.06], &"cannon": [-12.0, 3, 1.08, 0.08], &"ranger": [-18.0, 3, 1.1, 0.05],
	&"wax": [-14.0, 2, 1.1, 0.1], &"chime": [-20.0, 2, 1.08, 0.1], &"hero_shot": [-14.0, 3, 1.08, 0.05],
	&"ticket": [-10.0, 3, 1.06, 0.05], &"frenzy": [-6.0, 1, 1.0, 0.0], &"focus": [-10.0, 1, 1.0, 0.0],
	&"level_up": [-8.0, 1, 1.0, 0.0], &"click": [-14.0, 2, 1.05, 0.03], &"deny": [-10.0, 1, 1.0, 0.15],
	&"round_start": [-9.0, 1, 1.0, 0.0], &"round_complete": [-8.0, 1, 1.0, 0.0]}
## attack_fired tag prefix -> sound. Wax has none: its splat plays on status_applied (slow landed), A-10.
const ATTACK_SFX: Dictionary[String, StringName] = {"snowball_rookie": &"throw", "avalanche_cannon": &"cannon",
	"biathlon_ranger": &"ranger", "snow_sorcerer": &"chime", "camel_claus": &"hero_shot"}
## Broken layer id -> pop; camo variants share their colour's pop. Unknown ids use pop_heavy (special shells).
const POP_DEPTH: Dictionary[String, int] = {"powder": 1, "blue": 2, "mint": 3, "violet": 4, "coral": 5}
const DUCK_DB: float = -8.0

var _players: Dictionary[StringName, AudioStreamPlayer] = {}
var _last_start: Dictionary[StringName, int] = {}
var _music: AudioStreamPlayer = AudioStreamPlayer.new()
var _music_slot: StringName = &""
## Browsers block audio until a user gesture; nothing plays before the first click/key/touch (A-10, P18-T08).
var _unlocked: bool = not OS.has_feature("web")
var _duck: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sfx_name: StringName in SFX:
		var cfg: Array = SFX[sfx_name]
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.stream = load(SFX_DIR + sfx_name + ".wav")
		player.volume_db = cfg[0]
		player.max_polyphony = cfg[1]
		player.bus = &"SFX"
		add_child(player)
		_players[sfx_name] = player
	_music.bus = &"Music"
	add_child(_music)
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


## Plays a named SFX unless it started less than its min gap ago (merges pop storms in big waves).
func play(sfx_name: StringName) -> void:
	if not _unlocked:
		return
	var now: int = Time.get_ticks_msec()
	if now - _last_start.get(sfx_name, -100000) < SFX[sfx_name][3] * 1000.0:
		return
	_last_start[sfx_name] = now
	var spread: float = SFX[sfx_name][2]
	_players[sfx_name].pitch_scale = randf_range(1.0 / spread, spread)
	_players[sfx_name].play()


## Switches music to `slot` (no-op if already playing it or the file isn't there yet).
func play_music(slot: StringName) -> void:
	if slot == _music_slot:
		return
	_music_slot = slot
	_music.stop()
	if not _unlocked or slot == &"":
		return
	for ext: String in [".ogg", ".mp3"]:
		var path: String = MUSIC_DIR + slot + ext
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			stream.set(&"loop", MUSIC_LOOPS[slot])
			_music.stream = stream
			_music.play()
			return


## Lowers the Music bus for `seconds`, then recovers smoothly (hero ability, win/loss).
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
	match e.type:
		&"layer_broken":
			var depth: int = POP_DEPTH.get(e.tags[0].trim_prefix("camo_"), 0)
			play(StringName("pop_%d" % depth) if depth else &"pop_heavy")
		&"enemy_immune":
			play(&"immune")
		&"enemy_leaked":
			play(&"leak")
		&"tower_placed":
			play(&"place")
		&"tower_upgraded":
			play(&"upgrade")
		&"tower_sold":
			play(&"sell")
		&"purchase_failed":
			play(&"deny")
		&"attack_fired":
			for prefix: String in ATTACK_SFX:
				if e.tags[0].begins_with(prefix):
					play(ATTACK_SFX[prefix])
		&"status_applied":
			if e.tags[0].begins_with("slope_wax_sprayer"):
				play(&"wax")
		&"income_collected":
			play(&"ticket")
		&"ability_used":
			if "snowball_frenzy" in e.tags:
				play(&"frenzy")
				duck(1.5)
			elif "focused_shot" in e.tags:
				play(&"focus")
		&"hero_level_up":
			play(&"level_up")
		&"round_started":
			play(&"round_start")
		&"round_complete":
			play(&"round_complete")
		&"match_won":
			play_music(&"victory")
		&"match_lost":
			play_music(&"defeat")


## Every Button anywhere gets the UI click; no scene needs to know about audio.
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play.bind(&"click"))


func _on_scene_changed() -> void:
	var scene: Node = get_tree().current_scene
	if scene:
		play_music(&"menu" if scene.scene_file_path.contains("title") else &"gameplay")
