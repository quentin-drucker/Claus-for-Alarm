extends SceneTree
## P18-T03: renders every original SFX in code into assets/audio/sfx/*.wav (DEC-035). Deterministic: same seed,
## same files. Re-run after changing a recipe:
##   godot --headless --path . -s res://scripts/audio/sfx_synth.gd
## Provenance ledger: assets/audio/CREDITS.md.

const RATE: int = 22050
const OUT_DIR: String = "res://assets/audio/sfx/"
## Peak level every file is normalized to; per-sound loudness is set in the router.
const PEAK: float = 0.8

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _initialize() -> void:
	_rng.seed = 20261114
	# Snowball pops, one per layer depth (Powder 1 .. Coral 5): deeper layer = lower, fuller crump.
	for depth: int in range(1, 6):
		var b: PackedFloat32Array = _buf(0.09)
		_noise(b, 0.0, 0.07, 1.0, 0.018, 5200.0 - depth * 700.0, 1200.0)
		_tone(b, 0.0, 0.06, 420.0 - depth * 45.0, 180.0 - depth * 15.0, 0.6, 0.02)
		_save("pop_%d" % depth, b)
	var b: PackedFloat32Array = _buf(0.22)  # special shells (black/white/purple): ceramic crumble
	_noise(b, 0.0, 0.2, 1.0, 0.06, 2200.0, 300.0)
	_noise(b, 0.03, 0.05, 0.6, 0.015, 4000.0, 4000.0)
	_noise(b, 0.07, 0.05, 0.5, 0.015, 3500.0, 3500.0)
	_tone(b, 0.0, 0.15, 160.0, 70.0, 0.8, 0.05)
	_save("pop_heavy", b)

	b = _buf(0.18)  # immune: muted glassy tink, inharmonic partials, no low end
	_tone(b, 0.0, 0.17, 1760.0, 1740.0, 0.6, 0.05)
	_tone(b, 0.0, 0.12, 2690.0, 2670.0, 0.3, 0.03)
	_noise(b, 0.0, 0.01, 0.3, 0.004, 6000.0, 6000.0)
	_save("immune", b)

	b = _buf(0.42)  # leak: warm descending two-tone warning (triangle, mid range)
	_tone(b, 0.0, 0.18, 523.0, 523.0, 0.8, 0.12, true)
	_tone(b, 0.18, 0.24, 392.0, 380.0, 0.8, 0.14, true)
	_save("leak", b)

	b = _buf(0.18)  # tower placed: soft stomp
	_tone(b, 0.0, 0.16, 150.0, 60.0, 1.0, 0.05)
	_noise(b, 0.0, 0.08, 0.5, 0.025, 1800.0, 600.0)
	_save("place", b)

	b = _buf(0.5)  # upgrade: small triumphant chime C5-E5-G5
	for i: int in 3:
		_bell(b, i * 0.07, 0.36, [523.25, 659.25, 783.99][i], 0.6)
	_save("upgrade", b)

	b = _buf(0.3)  # sell: coin drop G5 -> D5
	_bell(b, 0.0, 0.14, 783.99, 0.6)
	_bell(b, 0.09, 0.2, 587.33, 0.6)
	_save("sell", b)

	b = _buf(0.45)  # cannon: pneumatic woom, then cushioned snow blast
	_tone(b, 0.0, 0.2, 70.0, 110.0, 0.7, 0.12)
	_noise(b, 0.0, 0.18, 0.4, 0.1, 400.0, 900.0)
	_noise(b, 0.16, 0.28, 1.0, 0.07, 2500.0, 400.0)
	_tone(b, 0.16, 0.2, 120.0, 50.0, 0.8, 0.06)
	_save("cannon", b)

	b = _buf(0.09)  # biathlon ranger: soft air-pellet snap
	_noise(b, 0.0, 0.05, 1.0, 0.008, 7000.0, 3000.0, true)
	_tone(b, 0.0, 0.04, 900.0, 500.0, 0.4, 0.01)
	_save("ranger", b)

	b = _buf(0.12)  # rookie throw: short rising whoosh
	_noise(b, 0.0, 0.11, 0.8, 0.04, 900.0, 3200.0)
	_save("throw", b)

	b = _buf(0.22)  # wax splat: soft slick low splat
	_noise(b, 0.0, 0.2, 1.0, 0.05, 1200.0, 300.0)
	_tone(b, 0.0, 0.16, 260.0, 110.0, 0.7, 0.05)
	_save("wax", b)

	b = _buf(0.5)  # sorcerer: soft glass-chime swish (kept below 2.7 kHz)
	_noise(b, 0.0, 0.15, 0.25, 0.06, 1500.0, 3000.0)
	_bell(b, 0.02, 0.45, 1046.5, 0.5)
	_bell(b, 0.05, 0.4, 1318.5, 0.35)
	_save("chime", b)

	b = _buf(0.2)  # ticket pickup: receipt flick + coin click
	_noise(b, 0.0, 0.03, 0.6, 0.01, 6000.0, 6000.0, true)
	_bell(b, 0.03, 0.16, 1567.98, 0.5)
	_bell(b, 0.06, 0.13, 2093.0, 0.35)
	_save("ticket", b)

	b = _buf(0.12)  # hero ski-pole shot: wood/elastic release
	_tone(b, 0.0, 0.1, 340.0, 170.0, 1.0, 0.03, true)
	_noise(b, 0.0, 0.015, 0.6, 0.005, 3000.0, 3000.0)
	_save("hero_shot", b)

	b = _buf(0.9)  # Snowball Frenzy: whoosh swell + melodic ascent
	_noise(b, 0.0, 0.6, 0.6, 0.4, 500.0, 4000.0, false, 0.35)
	for i: int in 4:
		_bell(b, 0.25 + i * 0.09, 0.5, [392.0, 523.25, 659.25, 783.99][i], 0.45)
	_save("frenzy", b)

	b = _buf(0.12)  # Focused Shot: lens click (two clicks)
	_noise(b, 0.0, 0.02, 1.0, 0.004, 5000.0, 5000.0)
	_noise(b, 0.045, 0.03, 0.8, 0.006, 3500.0, 3500.0)
	_tone(b, 0.045, 0.05, 1200.0, 1200.0, 0.3, 0.012)
	_save("focus", b)

	b = _buf(0.45)  # hero level up: uplifting two-note rise
	_bell(b, 0.0, 0.2, 587.33, 0.6)
	_bell(b, 0.12, 0.32, 880.0, 0.6)
	_save("level_up", b)

	b = _buf(0.05)  # UI click: tiny wooden tap
	_tone(b, 0.0, 0.04, 950.0, 800.0, 1.0, 0.008)
	_noise(b, 0.0, 0.01, 0.4, 0.003, 4000.0, 4000.0)
	_save("click", b)

	b = _buf(0.22)  # UI deny: low soft two-tone
	_tone(b, 0.0, 0.09, 233.0, 233.0, 0.8, 0.05, true)
	_tone(b, 0.09, 0.12, 196.0, 190.0, 0.8, 0.06, true)
	_save("deny", b)

	b = _buf(0.45)  # round start: rising G4 -> C5 call
	_bell(b, 0.0, 0.18, 392.0, 0.6)
	_bell(b, 0.12, 0.32, 523.25, 0.7)
	_save("round_start", b)

	b = _buf(0.85)  # round complete: three-note medal fanfare
	_bell(b, 0.0, 0.2, 523.25, 0.55)
	_bell(b, 0.12, 0.2, 659.25, 0.55)
	_bell(b, 0.24, 0.6, 783.99, 0.6)
	_bell(b, 0.24, 0.6, 1046.5, 0.25)
	_save("round_complete", b)
	quit()


func _buf(seconds: float) -> PackedFloat32Array:
	var b: PackedFloat32Array = PackedFloat32Array()
	b.resize(int(seconds * RATE))
	return b


## Fast attack, exponential decay (time constant `decay` seconds).
func _env(t: float, decay: float, attack: float = 0.002) -> float:
	return minf(t / attack, 1.0) * exp(-t / decay)


## Pitched tone sweeping f0 -> f1 (exponential); sine, or triangle for warmer warning/deny tones.
func _tone(b: PackedFloat32Array, start: float, dur: float, f0: float, f1: float, amp: float, decay: float,
		triangle: bool = false) -> void:
	var phase: float = 0.0
	var i0: int = int(start * RATE)
	for i: int in mini(int(dur * RATE), b.size() - i0):
		var t: float = float(i) / RATE
		phase += f0 * pow(f1 / f0, t / dur) / RATE
		var x: float = fposmod(phase, 1.0)
		var w: float = (4.0 * absf(x - 0.5) - 1.0) if triangle else sin(TAU * x)
		b[i0 + i] += w * amp * _env(t, decay)


## Noise through a one-pole low-pass whose cutoff sweeps c0 -> c1; `highpass` keeps the residual instead.
func _noise(b: PackedFloat32Array, start: float, dur: float, amp: float, decay: float, c0: float, c1: float,
		highpass: bool = false, attack: float = 0.002) -> void:
	var lp: float = 0.0
	var i0: int = int(start * RATE)
	for i: int in mini(int(dur * RATE), b.size() - i0):
		var t: float = float(i) / RATE
		var cutoff: float = lerpf(c0, c1, t / dur)
		var a: float = 1.0 - exp(-TAU * cutoff / RATE)
		var n: float = _rng.randf_range(-1.0, 1.0)
		lp += a * (n - lp)
		b[i0 + i] += (n - lp if highpass else lp) * amp * _env(t, decay, attack)


## Soft bell: fundamental + quiet 2.76x partial, slow-ish decay.
func _bell(b: PackedFloat32Array, start: float, dur: float, f: float, amp: float) -> void:
	_tone(b, start, dur, f, f, amp, dur * 0.35)
	_tone(b, start, dur * 0.5, f * 2.76, f * 2.76, amp * 0.15, dur * 0.12)


## Normalize, 5 ms fade-out, write 16-bit mono WAV.
func _save(sfx_name: String, b: PackedFloat32Array) -> void:
	var peak: float = 0.0001
	for s: float in b:
		peak = maxf(peak, absf(s))
	var fade: int = int(0.005 * RATE)
	var data: PackedByteArray = PackedByteArray()
	data.resize(b.size() * 2)
	for i: int in b.size():
		var s: float = b[i] / peak * PEAK * minf(1.0, float(b.size() - 1 - i) / fade)
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.data = data
	var err: Error = wav.save_to_wav(OUT_DIR + sfx_name + ".wav")
	print("%s %s %d samples" % [sfx_name, "ok" if err == OK else "ERROR %d" % err, b.size()])
