"""B-14 QA captures for the P15 slice: per asset a clay turnaround sheet, a game-camera silhouette and a
close-up (material). Run in Blender after opening the asset's .blend; set ASSET first:
ASSET = "elf_rookie" | "snowball" | "lodge" | a prepared source model (open art_src/prepared/<id>.blend:
"avalanche_cannon" | "biathlon_ranger" | "slope_wax_sprayer" | "snow_sorcerer" | "ski_resort_ticket_booth"); optional PREFIX (evidence file prefix, default "p15"); exec(open(<this>).read())"""
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())

E = EVIDENCE
PFX = globals().get("PREFIX", "p15")
cfg = {
    # target centre, distance, ortho scale, close-up (target, dir, dist, ortho)
    "elf_rookie": ((0, 0, 0.62), 4, 1.45, ((0, 0.1, 0.8), (0.35, 1, 0.15), 3, 0.62)),
    "snowball": ((0, 0, 0), 4, 0.95, ((0, 0, 0), (0.4, 1, 0.5), 3, 0.55)),
    "lodge": ((0, 0, 2.3), 20, 6.6, ((0, -1.9, 1.3), (0.25, -1, 0.2), 12, 2.6)),
    # Prepared Tripo models (modelled size; the game shows them at 1.5x)
    "avalanche_cannon": ((0, 0, 0.31), 4, 0.95, ((0, 0.05, 0.31), (0.6, 1, 0.35), 3, 0.85)),
    "biathlon_ranger": ((0, 0, 0.6), 4, 1.45, ((-0.15, 0.2, 0.62), (-0.45, 1, 0.25), 3, 0.95)),
    "slope_wax_sprayer": ((0, 0, 0.6), 4, 1.3, ((0.08, 0.1, 0.62), (0.45, 1, 0.25), 3, 0.9)),
    "snow_sorcerer": ((0, 0, 0.5), 4, 1.2, ((0.1, 0.05, 0.62), (0.4, 1, 0.25), 3, 0.8)),
    "ski_resort_ticket_booth": ((0, 0, 0.81), 6, 2.1, ((0, 0.4, 0.75), (0.45, 1, 0.3), 6, 1.5)),
}[ASSET]
target, dist, ortho, close = cfg
# The game-facing side: elf faces +Y; the lodge front faces -Y (toward the Godot camera).
flip = -1 if ASSET == "lodge" else 1
views = [(n, (d[0] * flip, d[1] * flip, d[2])) for n, d in TURN]
hide = {"snowball_shell_hi", "snowball_marker"} if ASSET == "snowball" else set()
if ASSET == "elf_rookie":  # clay turnaround in the rest pose; silhouette/close-up in the shipped idle pose
    rig = bpy.data.objects["elf_rig"]
    rig.data.pose_position = "REST"
paths = render_views(f"{PFX}_{ASSET}_clay", target, views, dist, ortho, "clay", (420, 420), hide)
if ASSET == "snowball":  # the high-res master too, and the band seated on the game shell
    bpy.data.objects["snowball_shell_hi"].location.x = 0
    paths += render_views(f"{PFX}_snowball_clay_hi", target, [("hi_three_quarter", (0.75, 0.9, 0.35))], dist, ortho,
                          "clay", (420, 420), {"snowball_shell", "snowball_marker"})
tile_sheet(paths, os.path.join(E, f"{PFX}_{ASSET}_clay_turnaround.png"), 3)
if ASSET == "elf_rookie":
    rig.data.pose_position = "POSE"
    bpy.context.scene.frame_set(1)
gc = (0, -GAMECAM[1], GAMECAM[2]) if ASSET == "lodge" else GAMECAM
sil = render_views(f"{PFX}_{ASSET}_sil", target, [("gamecam", gc)], dist, ortho, "silhouette", (420, 420), hide)
sil += render_views(f"{PFX}_{ASSET}_sil", target, [("front", views[0][1])], dist, ortho, "silhouette", (420, 420), hide)
tile_sheet(sil, os.path.join(E, f"{PFX}_{ASSET}_silhouette.png"), 2)
ct, cd, cdist, co = close
if ASSET == "snowball":  # material lineup: 5 layer tints, then Black/White/Purple shells + band, Camo Mint + band
    shell, band = bpy.data.objects["snowball_shell"], bpy.data.objects["snowball_marker"]
    for o in (shell, band, bpy.data.objects["snowball_shell_hi"]):
        o.hide_render = True
    hide |= {"snowball_shell", "snowball_marker", "snowball_shell_hi"}
    row = [("powder", None), ("blue", None), ("mint", None), ("violet", None), ("coral", None),
           ("black", "black"), ("white", "white"), ("purple", "purple"), ("mint", "camo")]
    for k, (tint, mark) in enumerate(row):
        x = (k - 4) * 0.95
        s2 = shell.copy(); s2.data = shell.data.copy(); s2.name = f"QA_ball_{k}"
        s2.data.materials[0] = material(f"QA_tint_{tint}", PAL[tint], 0.75, use_vcol=True)
        s2.location = (x, 0, 0)
        bpy.context.scene.collection.objects.link(s2)
        if mark:
            b2 = band.copy(); b2.data = band.data.copy(); b2.name = f"QA_band_{k}"
            b2.data.materials[0] = bpy.data.materials[f"M_marker_{mark}"]
            b2.location = (x, 0, 0)
            b2.rotation_euler = (0.5, 0, 0.6)
            bpy.context.scene.collection.objects.link(b2)
    ct, cd, cdist, co = (0, 0, 0), (0, 1, 0.45), 12, 8.8
    render_views("p15_snowball", ct, [("closeup", cd)], cdist, co, "material", (1400, 360), hide)
    for o in [o for o in bpy.data.objects if o.name.startswith(("QA_ball", "QA_band"))]:
        bpy.data.objects.remove(o, do_unlink=True)
else:
    render_views(f"{PFX}_{ASSET}", ct, [("closeup", (cd[0], cd[1], cd[2]))], cdist, co, "material", (720, 720), hide)
print("QA renders done for", ASSET)
