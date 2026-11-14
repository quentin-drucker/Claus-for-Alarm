"""Winter-games Lodge (P15-T04 environment prop). Log chalet on a stone plinth; fits the 5 x 4 m Lodge blocker
(Blender X = 5 m, Y = 4 m), origin at footprint centre on the ground. Front (door, gable) faces Blender -Y
(= Godot +Z, toward the game camera), so it needs no rotation in the map. Run in Blender."""
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())

clear_scene()
M = {
    "stone": material("M_stone_plinth", PAL["stone"], 0.9),
    "log": material("M_wood_chalet", PAL["timber"], 0.8),
    "dark": material("M_wood_dark", PAL["dark_timber"], 0.8),
    "roof": material("M_roof_red", PAL["red"], 0.75),
    "snow": material("M_snow_powder", PAL["snow"], 0.9),
    "glow": material("M_festival_light", PAL["gold"], 0.5, emit=1.5),
    "teal": material("M_garland", PAL["teal"], 0.9),
}
parts = []


def box(name, size, loc, mat, bevel=0.03, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc, rotation=rot)
    o = bpy.context.object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    if bevel:
        m = o.modifiers.new("bevel", "BEVEL")
        m.width = bevel
        m.segments = 2
        m.limit_method = "ANGLE"
        apply_modifiers(o)
    o.data.materials.append(mat)
    parts.append(o)
    return o


def log(name, length, axis, loc, r=0.105):
    """Round log with chamfered ends (8 sides keeps the read cheap)."""
    rot = (0, math.radians(90), 0) if axis == "X" else (math.radians(90), 0, 0)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=r, depth=length, location=loc, rotation=rot)
    o = bpy.context.object
    o.name = name
    m = o.modifiers.new("bevel", "BEVEL")
    m.width = 0.03
    m.segments = 1
    m.limit_method = "ANGLE"
    apply_modifiers(o)
    shade_smooth(o)
    o.data.materials.append(M["log"])
    parts.append(o)
    return o


W, D = 4.5, 3.5  # wall centre lines (X, Y); logs overhang the corners like notched log-cabin joints
PLINTH = 0.38
box("plinth", (4.9, 3.9, PLINTH), (0, 0, PLINTH / 2), M["stone"], bevel=0.08)
z = PLINTH + 0.1
course = 0
while z < 2.35:
    off = 0.0 if course % 2 == 0 else 0.1  # alternate courses sit half a log higher at the notches
    for sy in (-1, 1):
        log("log_x", W + 0.4, "X", (0, sy * D / 2, z + off))
    for sx in (-1, 1):
        log("log_y", D + 0.4, "Y", (sx * W / 2, 0, z + 0.1 - off))
    z += 0.2
    course += 1
WALL_TOP = z + 0.05
# solid core so no gaps show between round logs
box("wall_core", (W - 0.1, D - 0.1, WALL_TOP - PLINTH), (0, 0, (WALL_TOP + PLINTH) / 2), M["dark"], bevel=0)

# ---- gable roof, ridge along Y so the gable faces the camera ----
PITCH = math.radians(32)
HALF = W / 2 + 0.45
RISE = HALF * math.tan(PITCH)
SLAB_L = HALF / math.cos(PITCH)
for sx in (-1, 1):
    cx = sx * HALF / 2
    box(f"roof_{sx}", (SLAB_L + 0.05, D + 0.9, 0.14), (cx, 0, WALL_TOP + RISE / 2 + 0.08), M["roof"], bevel=0.04,
        rot=(0, sx * PITCH, 0))
    # fascia boards along the eaves
    box(f"fascia_{sx}", (0.1, D + 0.95, 0.18), (sx * (HALF + 0.02), 0, WALL_TOP - 0.02), M["dark"], bevel=0.02)
box("ridge_beam", (0.22, D + 1.0, 0.2), (0, 0, WALL_TOP + RISE + 0.12), M["dark"], bevel=0.04)

# gable triangles (front and back): vertical boards
for sy in (-1, 1):
    bm = bmesh.new()
    y = sy * (D / 2 + 0.02)
    vs = [bm.verts.new(v) for v in ((-W / 2, y, WALL_TOP), (W / 2, y, WALL_TOP), (0, y, WALL_TOP + RISE))]
    bm.faces.new(vs)
    me = bpy.data.meshes.new("gable")
    bm.to_mesh(me)
    bm.free()
    g = bpy.data.objects.new("gable", me)
    bpy.context.scene.collection.objects.link(g)
    sol = g.modifiers.new("sol", "SOLIDIFY")
    sol.thickness = 0.12
    apply_modifiers(g)
    g.data.materials.append(M["dark"])
    parts.append(g)
for k in range(-4, 5):  # board battens on the front gable
    h = RISE * (1 - abs(k) * 0.5 / (W / 2))
    if h > 0.15:
        box("batten", (0.06, 0.06, h - 0.1), (k * 0.5, -(D / 2 + 0.1), WALL_TOP + (h - 0.1) / 2), M["log"], bevel=0.01)
# round attic window in the gable
bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.32, depth=0.1, location=(0, -(D / 2 + 0.14), WALL_TOP + RISE * 0.45),
                                    rotation=(math.radians(90), 0, 0))
o = bpy.context.object; o.name = "attic_frame"; o.data.materials.append(M["dark"]); parts.append(o)
bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.24, depth=0.12, location=(0, -(D / 2 + 0.16), WALL_TOP + RISE * 0.45),
                                    rotation=(math.radians(90), 0, 0))
o = bpy.context.object; o.name = "attic_glass"; o.data.materials.append(M["glow"]); parts.append(o)

# ---- snow load: one continuous drift per roof slope, thick at the ridge side, curling over the eave ----
for sx in (-1, 1):
    els = []
    for i in range(16):
        for j in range(16):
            t = 0.03 + 0.8 * i / 15  # 0 at ridge, 1 at eave; the last fifth of red roof stays visible
            y = -D / 2 - 0.3 + (j + 0.5) / 16 * (D + 0.6)
            x = sx * t * HALF
            zz = WALL_TOP + 0.08 + RISE * (1 - t) + 0.08
            els.append({"co": (x, y, zz), "radius": 0.2 - 0.05 * t + 0.03 * math.sin(i * 1.7 + j * 2.3)})
    snow = metaball_mesh(f"roof_snow_{sx}", els, resolution=0.04, remesh=0.035, smooth=10, mat=M["snow"])
    decimate(snow, 1800 / tri_count(snow))
    parts.append(snow)

# ---- front: door with frame + wreath, two lit windows with shutters and snowy sills ----
FY = -(D / 2 + 0.11)
box("door_frame", (1.0, 0.12, 1.5), (0, FY, PLINTH + 0.75), M["dark"], bevel=0.03)
box("door", (0.8, 0.14, 1.36), (0, FY - 0.02, PLINTH + 0.7), M["roof"], bevel=0.03)
bpy.ops.mesh.primitive_torus_add(major_radius=0.17, minor_radius=0.05, location=(0, FY - 0.1, PLINTH + 1.05),
                                 rotation=(math.radians(90), 0, 0))
o = bpy.context.object; o.name = "wreath"; o.data.materials.append(M["teal"]); parts.append(o)
box("step", (1.3, 0.5, 0.18), (0, -(D / 2 + 0.4), 0.09), M["stone"], bevel=0.04)
for sx in (-1, 1):
    x = sx * 1.4
    box("win_frame", (0.85, 0.12, 0.8), (x, FY, PLINTH + 1.05), M["dark"], bevel=0.03)
    box("win_glass", (0.65, 0.14, 0.6), (x, FY - 0.01, PLINTH + 1.05), M["glow"], bevel=0.01)
    box("win_mullion", (0.06, 0.16, 0.62), (x, FY - 0.02, PLINTH + 1.05), M["dark"], bevel=0)
    box("win_sill", (0.95, 0.22, 0.07), (x, FY - 0.06, PLINTH + 0.62), M["dark"], bevel=0.02)
    box("sill_snow", (0.9, 0.2, 0.06), (x, FY - 0.07, PLINTH + 0.68), M["snow"], bevel=0.025)
    for s2 in (-1, 1):
        box("shutter", (0.3, 0.07, 0.85), (x + s2 * 0.6, FY - 0.03, PLINTH + 1.05), M["roof"], bevel=0.02)
# side windows
for sx in (-1, 1):
    box("side_win", (0.12, 0.7, 0.6), (sx * (W / 2 + 0.12), 0, PLINTH + 1.05), M["glow"], bevel=0.01)
    box("side_frame", (0.1, 0.85, 0.75), (sx * (W / 2 + 0.1), 0, PLINTH + 1.05), M["dark"], bevel=0.02)

# ---- stone chimney through the right slope, with snow cap ----
cx = 1.2
cz = WALL_TOP + RISE * (1 - cx / HALF)
box("chimney", (0.55, 0.55, 1.4), (cx, 0.6, cz + 0.3), M["stone"], bevel=0.05)
box("chimney_cap", (0.7, 0.7, 0.12), (cx, 0.6, cz + 1.05), M["dark"], bevel=0.03)
parts.append(metaball_mesh("chimney_snow", [{"co": (cx + dx, 0.6 + dy, cz + 1.14), "radius": 0.2}
                                            for dx in (-0.12, 0.12) for dy in (-0.12, 0.12)],
                           resolution=0.03, remesh=0.03, mat=M["snow"]))
decimate(parts[-1], min(1.0, 400 / tri_count(parts[-1])))

# ---- festive light string along both front eaves ----
for sx in (-1, 1):
    for k in range(9):
        t = (k + 0.5) / 9
        x = sx * t * HALF
        zz = WALL_TOP + RISE * (1 - t) - 0.05 - 0.06 * math.sin(t * 9 * math.pi) ** 2
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.055, location=(x, -(D / 2 + 0.5), zz))
        o = bpy.context.object; o.name = "bulb"; o.data.materials.append(M["glow"] if k % 2 else M["roof"]); parts.append(o)

for o in parts:
    if o.type == "MESH" and o.name.startswith(("log", "roof_snow", "chimney_snow", "wreath", "bulb", "attic")):
        shade_smooth(o)
lodge = join(parts, "lodge")
print("lodge tris", tri_count(lodge), "dims", tuple(round(d, 2) for d in lodge.dimensions))

os.makedirs(os.path.join(PROJ, "art_src", "environment"), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(PROJ, "art_src", "environment", "lodge.blend"))
export_glb([lodge], os.path.join(PROJ, "assets", "models", "lodge.glb"))
print("exported lodge.glb")
