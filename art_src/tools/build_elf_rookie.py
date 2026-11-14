"""Snowball Rookie elf (P15-T03/T04, DEC-039 redesign): chibi elf base body + Rookie outfit built to the owner's
concept sheets in references/characters/christmas_elf_v1/. Run in Blender:
exec(open(r"<proj>/art_src/tools/build_elf_rookie.py").read())
Each garment is one metaball group -> continuous remeshed surface; pieces overlap only where cloth tucks/laps.
Face = sculpted geometry (eyeballs, lid rims, lashes, brows, nose, mouth) + one painted eye texture (iris, pupil,
highlights, lid shadow) generated here (`elf_eye.png`, no third-party assets).
"""
import math
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())

clear_scene()
M = {
    "skin": material("M_elf_skin", PAL["skin"], 0.55),
    "jacket": material("M_puffy_cloth_navy", PAL["navy"], 0.85),
    "trousers": material("M_puffy_cloth_teal", PAL["teal"], 0.85),
    "trim": material("M_fur_trim", PAL["snow"], 0.95),
    "red": material("M_knit_red", PAL["red"], 0.9),
    "boot": material("M_leather_boot", PAL["timber"], 0.6),
    "belt": material("M_leather_belt", PAL["belt"], 0.6),
    "gold": material("M_gold_accent", PAL["gold"], 0.35, 0.8),
    "hair": material("M_hair", PAL["hair"], 0.7),
    "lid": material("M_lid", PAL["lid"], 0.6),
    "brow": material("M_brow", PAL["dark_timber"], 0.9),
    "nose": material("M_nose", PAL["nose"], 0.5),
    "mouth": material("M_mouth", PAL["mouth"], 0.6),
    "snow": material("M_snow_pellet", PAL["snow"], 0.75),
}


def ring(center, normal, radius, r, n=18, squash=1.0, neg=False, stiff=2.0):
    """Metaball ring (fur trim band / quilting groove) of n balls around `center`, perpendicular to `normal`.
    squash scales the ring's second axis (oval rings)."""
    nrm = Vector(normal).normalized()
    u = nrm.orthogonal().normalized()
    if abs(nrm.z) > 0.7:
        u = Vector((1, 0, 0))
        u = (u - nrm * u.dot(nrm)).normalized()
    v = nrm.cross(u)
    out = []
    for i in range(n):
        a = 2 * math.pi * i / n
        p = Vector(center) + u * math.cos(a) * radius + v * math.sin(a) * radius * squash
        out.append({"co": tuple(p), "radius": r, "stiff": stiff, "neg": neg})
    return out


def chain(points, radii, stiff=2.0, step=0.025, size=None):
    """Balls along a polyline with interpolated radius: a tapered tube that blends smoothly.
    size=(sx, sy, sz) makes every element an axis-aligned ellipsoid (flat clumps)."""
    out = []
    extra = {"type": "ELLIPSOID", "size": size} if size else {}
    for (a, ra), (b, rb) in zip(zip(points, radii), zip(points[1:], radii[1:])):
        a, b = Vector(a), Vector(b)
        n = max(1, int((b - a).length / step))
        for k in range(n):
            t = k / n
            out.append(dict({"co": tuple(a.lerp(b, t)), "radius": ra + (rb - ra) * t, "stiff": stiff}, **extra))
    out.append(dict({"co": tuple(points[-1]), "radius": radii[-1], "stiff": stiff}, **extra))
    return out


def mirror(elements):
    """Adds the -X twin of every element (euler rotations mirrored too)."""
    out = []
    for e in elements:
        m = dict(e, co=(-e["co"][0], e["co"][1], e["co"][2]))
        if "rot" in e:
            m["rot"] = (e["rot"][0], -e["rot"][1], -e["rot"][2])
        out.append(m)
    return elements + out


def tube(name, points, radii, mat, res=4):
    """Swept circle along a polyline with per-point radius (curve bevel -> mesh): exact thin lines (lid rims,
    lashes) that metaballs below ~5 mm cannot resolve."""
    cu = bpy.data.curves.new(name + "_cu", "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = 1.0
    cu.bevel_resolution = res
    cu.use_fill_caps = True
    sp = cu.splines.new("NURBS")
    sp.points.add(len(points) - 1)
    for pt, co, r in zip(sp.points, points, radii):
        pt.co = (co[0], co[1], co[2], 1.0)
        pt.radius = r
    sp.use_endpoint_u = True
    sp.order_u = min(4, len(points))
    tmp = bpy.data.objects.new(name + "_cu", cu)
    bpy.context.scene.collection.objects.link(tmp)
    bpy.context.view_layer.update()
    me = bpy.data.meshes.new_from_object(tmp.evaluated_get(bpy.context.evaluated_depsgraph_get()))
    bpy.data.objects.remove(tmp, do_unlink=True)
    bpy.data.curves.remove(cu)
    me.name = name
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    shade_smooth(ob)
    ob.data.materials.append(mat)
    return ob


def box(name, center, size, mat, bevel=0.004):
    """Bevelled block (buckles, zipper pull): the only hard-surface forms on the elf."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector(size), verts=bm.verts)
    bmesh.ops.bevel(bm, geom=bm.verts[:] + bm.edges[:], offset=bevel, segments=2, affect="EDGES")
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    shade_smooth(ob)
    ob.data.materials.append(mat)
    return ob


# ---- proportions (sheet 01): head + hat about half the height, wide flat face, short padded limbs ----
HEAD_Z = 0.80
# ---- skin: skull, cheeks, chin, neck and ears as one continuous surface ----
ear = chain([(0.17, -0.02, HEAD_Z), (0.27, -0.05, HEAD_Z + 0.03), (0.37, -0.085, HEAD_Z + 0.075)],
            [0.05, 0.032, 0.007], step=0.01)
SKULL = [
    {"type": "ELLIPSOID", "co": (0, 0, HEAD_Z), "radius": 0.225, "size": (1.0, 0.9, 0.93)},
    {"type": "ELLIPSOID", "co": (0, 0.04, HEAD_Z - 0.07), "radius": 0.175, "size": (1.05, 0.88, 0.68)},
    {"co": (0.105, 0.11, HEAD_Z - 0.07), "radius": 0.055},
    {"co": (-0.105, 0.11, HEAD_Z - 0.07), "radius": 0.055},
    {"co": (0, 0.09, HEAD_Z - 0.155), "radius": 0.048},  # small round chin
    {"co": (0, 0, HEAD_Z - 0.23), "radius": 0.07},  # neck
]
skull = metaball_mesh("tmp_skull", SKULL, resolution=0.01, remesh=0.01, smooth=0)  # ear-free projection target
skin = metaball_mesh("elf_skin", SKULL + mirror(ear), resolution=0.007, remesh=0.006, mat=M["skin"])


def onto(co, off, target=None):
    ok, loc, nrm, _ = (target or skin).closest_point_on_mesh(Vector(co))
    return tuple(loc + nrm * off)


def front(co, off):
    """Projects a face landmark straight back (-Y) onto the skin: keeps the drawn x/z layout (closest-point
    snapping pulls features toward the nose bump)."""
    ok, loc, nrm, _ = skin.ray_cast(Vector((co[0], 1.0, co[2])), Vector((0, -1, 0)))
    return tuple(loc + nrm * off)


def face_chain(name, pts, radii, off, mat, step=0.005):
    return metaball_mesh(name, chain([front(p, off) for p in pts], radii, step=step),
                         resolution=0.004, remesh=0, smooth=0, mat=mat)


# ---- eyes: bulging eyeballs with planar UVs (front hemisphere -> one painted texture), dark lid rim, lashes ----
EYE_R = 0.043
EYE_DEPTH = 0.5  # eyeball scale along the face normal
EYE_SINK = 0.01  # centre this far under the skin: protrudes EYE_R*EYE_DEPTH - EYE_SINK
EYES = {}


def eye_frame(sx):
    ok, loc, nrm, _ = skin.ray_cast(Vector((sx * 0.082, 1.0, HEAD_Z - 0.045)), Vector((0, -1, 0)))
    y = nrm.normalized()
    z = (Vector((0, 0, 1)) - y * y.z).normalized()
    x = y.cross(z).normalized()
    return loc, x, y, z


def eyeball(name, sx):
    loc, x, y, z = eye_frame(sx)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=36, v_segments=18, radius=EYE_R)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    c = loc - y * EYE_SINK
    uv = me.uv_layers.new(name="UVMap")
    for v in me.vertices:
        p = v.co.copy()  # sphere local: X right, Y out, Z up
        v.co = c + x * p.x + y * (p.y * EYE_DEPTH) + z * p.z
    for poly in me.polygons:
        poly.use_smooth = True
        for li in poly.loop_indices:
            p = me.vertices[me.loops[li].vertex_index].co - c
            uv.data[li].uv = (0.5 + 0.5 * p.dot(x) / EYE_R, 0.5 + 0.5 * p.dot(z) / EYE_R)
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    ob.data.materials.append(M_EYE)
    EYES[sx] = (c, x, y, z)
    return ob


def paint_eye_texture(path, size=256):
    """Iris, pupil, limbal ring, two highlights and an upper-lid shadow on a white sclera (planar eye UVs)."""
    import numpy as np
    px = 1.0 / size
    u, v = np.meshgrid((np.arange(size) + 0.5) * px, (np.arange(size) + 0.5) * px)
    rgb = np.ones((size, size, 3))
    rgb[:] = np.array(hex_srgb(PAL["white"]))

    def cov(d):
        return np.clip(0.5 - d / px, 0.0, 1.0)

    def disc(cx, cy, r):
        return np.hypot(u - cx, v - cy) - r

    def put(c, col):
        rgb[:] = rgb * (1 - c[..., None]) + np.array(col) * c[..., None]

    ir, pr = 0.36, 0.16  # radii in UV: iris fills most of the visible eye (less white = less staring)
    cx, cy = 0.5, 0.49
    t = np.clip(np.hypot(u - cx, v - cy) / ir, 0, 1)
    base, dark = np.array(hex_srgb(PAL["iris"])), np.array(hex_srgb(PAL["iris_dark"]))
    light = np.minimum(base * 1.35 + 0.05, 1.0)
    low = np.clip((cy - v) / ir + 0.4, 0, 1)[..., None]  # lower iris catches bounce light
    iris = dark + (light - dark) * ((1 - t ** 2.5)[..., None]) * (0.6 + 0.4 * low)
    put(cov(disc(cx, cy, ir)), iris)
    put(cov(np.abs(disc(cx, cy, ir)) - 0.018), dark)
    put(cov(disc(cx, cy - 0.01, pr)), hex_srgb("#141A12"))
    shadow = np.clip((v - 0.68) / 0.12, 0, 1)  # upper lid shadow
    rgb *= (1 - 0.3 * shadow)[..., None]
    put(cov(disc(cx - 0.1, cy + 0.12, 0.085)), hex_srgb("#FFFFFF"))
    put(cov(disc(cx + 0.11, cy - 0.12, 0.04)), hex_srgb("#FFFFFF"))
    img = bpy.data.images.new("elf_eye", size, size, alpha=True)
    img.pixels.foreach_set(np.dstack([rgb, np.ones((size, size))]).astype(np.float32).ravel())
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    return img


EYE_TEX = os.path.join(PROJ, "art_src", "characters", "elf_eye.png")
eye_img = paint_eye_texture(EYE_TEX)
M_EYE = material("M_elf_eye", "#FFFFFF", 0.15)
nt = M_EYE.node_tree
tex = nt.nodes.new("ShaderNodeTexImage")
tex.image = eye_img
tex.interpolation = "Linear"
nt.links.new(tex.outputs["Color"], next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED").inputs["Base Color"])

for sx in (1, -1):
    eyeball("elf_eyeball", sx)
    c, x, y, z = EYES[sx]
    rim_r = EYE_R * math.sin(math.acos(EYE_SINK / (EYE_R * EYE_DEPTH)))  # where the eyeball meets the skin
    rim, radii = [], []
    for k in range(29):  # upper lid line only: outer corner, over the top, to the inner corner
        a = math.radians(-15 + 7.5 * k)
        rim.append(c + y * (EYE_SINK + 0.003) + x * (sx * rim_r * math.cos(a)) + z * (rim_r * math.sin(a)))
        radii.append(0.0018 + 0.0032 * max(0.0, math.sin(a)))
    tube("elf_lid", rim, radii, M["lid"])
    for a_deg in (25, 52):  # two lashes flicking off the outer upper corner
        a = math.radians(a_deg)
        radial = (x * (sx * math.cos(a)) + z * math.sin(a)).normalized()
        p0 = c + y * (EYE_SINK + 0.003) + radial * (rim_r - 0.003)
        up = (radial * 0.7 + z * 0.6 + y * 0.15).normalized()
        tube("elf_lash", [p0, p0 + up * 0.007, p0 + up * 0.013, p0 + up * 0.018], [0.0045, 0.0035, 0.002, 0.0005],
             M["lid"])
    face_chain("elf_brow", [(sx * 0.05, 0.3, HEAD_Z + 0.012), (sx * 0.085, 0.3, HEAD_Z + 0.024),
                            (sx * 0.12, 0.3, HEAD_Z + 0.016)], [0.008, 0.01, 0.005], 0.003, M["brow"])
metaball_mesh("elf_nose", [{"co": front((0, 0.3, HEAD_Z - 0.085), -0.005), "radius": 0.021}],
              resolution=0.004, remesh=0, smooth=0, mat=M["nose"])
face_chain("elf_smile", [(-0.035, 0.3, HEAD_Z - 0.128), (-0.012, 0.3, HEAD_Z - 0.141), (0.012, 0.3, HEAD_Z - 0.141),
                         (0.035, 0.3, HEAD_Z - 0.128)], [0.005, 0.006, 0.006, 0.005], 0.002, M["mouth"])

# ---- hair (sheet 02): swept forelock, side tufts in front of the ears, clumps around the back under the hat ----
def lay(pts, radii, k=0.5, size=None):
    """Clump chain lying on the skull: each element sunk to k of its radius; size flattens it (ellipsoids)."""
    return chain([onto(p, r * k, skull) for p, r in zip(pts, radii)], radii, step=0.012, size=size)


FLAT_Y, FLAT_X = (1.0, 0.6, 1.0), (0.6, 1.0, 1.0)
hair_el = lay([(-0.13, 0.3, HEAD_Z + 0.165), (-0.04, 0.3, HEAD_Z + 0.155), (0.05, 0.3, HEAD_Z + 0.135),
               (0.12, 0.3, HEAD_Z + 0.095)], [0.055, 0.055, 0.046, 0.016], size=FLAT_Y)  # forelock over the right brow
hair_el += lay([(-0.17, 0.3, HEAD_Z + 0.14), (-0.21, 0.3, HEAD_Z + 0.07)], [0.045, 0.024], size=FLAT_Y)  # temple wisp
for sx in (1, -1):
    hair_el += lay([(sx * 0.4, 0.11, HEAD_Z + 0.04), (sx * 0.4, 0.13, HEAD_Z - 0.1), (sx * 0.4, 0.14, HEAD_Z - 0.19)],
                   [0.042, 0.038, 0.015], size=(0.55, 0.8, 1.0))  # front side tuft to the jaw
    hair_el += lay([(sx * 0.4, -0.06, HEAD_Z + 0.04), (sx * 0.4, -0.04, HEAD_Z - 0.1), (sx * 0.4, -0.02, HEAD_Z - 0.17)],
                   [0.05, 0.045, 0.018], size=FLAT_X)  # behind the ear
for a in (-55, -28, 0, 28, 55):  # back clumps
    s, cth = math.sin(math.radians(a)), math.cos(math.radians(a))
    hair_el += lay([(0.4 * s, -0.4 * cth, HEAD_Z + 0.05), (0.4 * s, -0.4 * cth, HEAD_Z - 0.08),
                    (0.4 * s, -0.4 * cth, HEAD_Z - 0.17)], [0.05, 0.048, 0.024], size=FLAT_Y)
hair_el.append({"type": "ELLIPSOID", "co": (0, -0.035, HEAD_Z + 0.02), "radius": 0.232, "size": (1.03, 0.9, 0.97)})  # shell under the clumps: no scalp gaps
hair = metaball_mesh("elf_hair", hair_el, resolution=0.006, remesh=0.005, smooth=4, mat=M["hair"])
bpy.data.objects.remove(skull, do_unlink=True)

# ---- knit beanie: rounded dome over the skull and hair, fur band, big pompom at the top back (no drooping tip) ----
BRIM_N = Vector((0, -0.08, 1)).normalized()  # band nearly level, a touch lower at the back
BRIM_C = Vector((0, 0.0, HEAD_Z + 0.1))
cap = metaball_mesh("elf_cap", [
    {"type": "ELLIPSOID", "co": (0, -0.01, HEAD_Z + 0.075), "radius": 0.26, "size": (1.0, 0.95, 0.9)},
    {"type": "ELLIPSOID", "co": (0, -0.02, HEAD_Z + 0.215), "radius": 0.175, "size": (1.0, 0.95, 0.92)},
], mat=M["red"])
bm = bmesh.new()
bm.from_mesh(cap.data)
bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=BRIM_C, plane_no=BRIM_N,
                       clear_inner=True)
bm.to_mesh(cap.data)
bm.free()
band = metaball_mesh("elf_cap_band", band_elements(cap, BRIM_C + BRIM_N * 0.012, BRIM_N, 0.045, push=0.006),
                     mat=M["trim"])
POM = Vector((0.11, -0.1, HEAD_Z + 0.375))
pompom = metaball_mesh("elf_pompom", [{"co": tuple(POM), "radius": 0.08}]
                       + [{"co": tuple(POM + Vector((0.04 * math.cos(a), 0.04 * math.sin(a) * 0.6, 0.04 * math.sin(a)))),
                           "radius": 0.034} for a in (0.4, 1.7, 3.0, 4.3, 5.4)], mat=M["trim"])

# ---- jacket: pear torso with four horizontal quilt bands, hem skirt under the belt, banded sleeves (A-pose) ----
SHOULDER = (0.135, 0.0, 0.515)
ELBOW = (0.21, 0.01, 0.43)
WRIST = (0.265, 0.02, 0.345)
HAND_END = (0.31, 0.06, 0.27)
sleeve_axis = (Vector(WRIST) - Vector(SHOULDER)).normalized()
sleeve = chain([SHOULDER, ELBOW, WRIST], [0.068, 0.062, 0.058], step=0.02)
sleeve_grooves = []
for t in (0.4, 0.68):
    cen = Vector(SHOULDER).lerp(Vector(WRIST), t)
    sleeve_grooves += ring(cen, sleeve_axis, 0.072, 0.024, n=16, neg=True)
jacket = metaball_mesh("elf_jacket", [
    {"type": "ELLIPSOID", "co": (0, 0.0, 0.44), "radius": 0.175, "size": (1.0, 0.82, 0.95)},
    {"type": "ELLIPSOID", "co": (0, 0.015, 0.36), "radius": 0.17, "size": (1.0, 0.85, 0.8)},
    {"type": "ELLIPSOID", "co": (0, 0, 0.52), "radius": 0.15, "size": (1.1, 0.8, 0.7)},
    {"type": "ELLIPSOID", "co": (0, 0.01, 0.285), "radius": 0.185, "size": (1.0, 0.85, 0.38)},  # hem skirt
] + mirror(sleeve + sleeve_grooves)
  + ring((0, 0.0, 0.515), (0, 0, 1), 0.175, 0.028, n=32, squash=0.85, neg=True)
  + ring((0, 0.005, 0.46), (0, 0, 1), 0.185, 0.03, n=32, squash=0.85, neg=True)
  + ring((0, 0.01, 0.405), (0, 0, 1), 0.185, 0.03, n=32, squash=0.86, neg=True),
    mat=M["jacket"])

# ---- trousers and boots ----
leg = chain([(0.085, 0, 0.26), (0.09, 0, 0.15)], [0.07, 0.062])
trousers = metaball_mesh("elf_trousers", [
    {"type": "ELLIPSOID", "co": (0, 0, 0.28), "radius": 0.15, "size": (1.0, 0.85, 0.5)},
] + mirror(leg), mat=M["trousers"])
boot = [{"type": "ELLIPSOID", "co": (0.09, 0.0, 0.165), "radius": 0.075, "size": (1.0, 1.05, 0.5)},  # wide top cuff
        {"co": (0.09, -0.005, 0.11), "radius": 0.064},
        {"type": "ELLIPSOID", "co": (0.09, 0.04, 0.055), "radius": 0.068, "size": (1.0, 1.7, 0.8)}] + \
    chain([(0.09, 0.12, 0.048), (0.09, 0.18, 0.058), (0.09, 0.205, 0.085), (0.09, 0.195, 0.11)],
          [0.048, 0.034, 0.02, 0.012], step=0.008)
boots = metaball_mesh("elf_boots", mirror(boot), mat=M["boot"])

# ---- bare hands: padded palm, three short fingers and a thumb; the right hand cups the snowball ----
PALM_R = Vector(WRIST) + sleeve_axis * 0.06
PELLET = PALM_R + Vector((0.045, 0.125, 0.02))  # snowball centre = muzzle_A socket (rig_elf.py)
PELLET_R = 0.055


def hand(sx, pellet):
    palm_c = Vector((sx * PALM_R.x, PALM_R.y, PALM_R.z))
    down = sleeve_axis.copy()
    down.x *= sx
    el = [{"type": "ELLIPSOID", "co": tuple(palm_c), "radius": 0.052, "size": (0.95, 0.7, 1.0)}]
    for i, dx in enumerate((-0.024, 0.0, 0.024)):
        base = palm_c + Vector((sx * dx, 0.012, 0)) + down * 0.025
        if pellet:  # fingers curl forward and up, cupping the snowball
            tip = base + Vector((0, 0.05, 0.01 + 0.012 * i))
        else:
            tip = base + down * 0.04 + Vector((sx * dx * 0.3, 0.01, 0))
        el += chain([tuple(base), tuple(tip)], [0.021, 0.017], step=0.01)
    thumb_base = palm_c + Vector((-sx * 0.035, 0.03, 0.01))
    thumb_tip = thumb_base + Vector((-sx * 0.012, 0.04, 0.015 if pellet else -0.01))
    el += chain([tuple(thumb_base), tuple(thumb_tip)], [0.02, 0.015], step=0.01)
    return el


hands = metaball_mesh("elf_hands", hand(1, True) + hand(-1, False), resolution=0.006, remesh=0.005, mat=M["skin"])
pellet = metaball_mesh("elf_pellet", [{"co": tuple(PELLET), "radius": PELLET_R}]
                       + [{"co": tuple(PELLET + Vector((0.03 * math.cos(a), 0.03 * math.sin(a), 0.02 * math.sin(2 * a)))),
                           "radius": 0.03} for a in (0.3, 1.9, 3.3, 4.8)], mat=M["snow"])

# ---- fur trims hugging the real garment sections: big collar, wrist cuffs ----
trims = metaball_mesh("elf_trims",
    band_elements(jacket, (0, 0, 0.585), (0, 0.08, 1), 0.05, push=0.004, max_r=0.22)
    + band_elements(jacket, WRIST, sleeve_axis, 0.036, push=0.004, max_r=0.12)
    + band_elements(jacket, (-WRIST[0], WRIST[1], WRIST[2]), (-sleeve_axis.x, sleeve_axis.y, sleeve_axis.z), 0.036,
                    push=0.004, max_r=0.12),
    mat=M["trim"])

# ---- belt with a gold frame buckle, centre zipper with a pull tab ----
belt = metaball_mesh("elf_belt", band_elements(jacket, (0, 0, 0.345), (0, 0, 1), 0.021, push=0.007, max_r=0.3),
                     resolution=0.006, remesh=0, smooth=0, mat=M["belt"])
ok, bk, bn, _ = jacket.closest_point_on_mesh(Vector((0, 0.4, 0.345)))
buckle = box("elf_buckle", bk + bn * 0.018, (0.075, 0.016, 0.052), M["gold"])
buckle_in = box("elf_buckle_in", bk + bn * 0.022, (0.045, 0.012, 0.024), M["belt"], bevel=0.002)
zip_pts = section_points(jacket, Vector((0, 0, 0)), Vector((1, 0, 0)), max_r=2.0, spacing=0.012)
zip_pts = [p for p in zip_pts if p.y > 0 and 0.375 < p.z < 0.56]
zipper = metaball_mesh("elf_zipper", [{"co": tuple(p + Vector((0, 0.005, 0))), "radius": 0.011} for p in zip_pts],
                       resolution=0.004, remesh=0, smooth=0, mat=M["gold"])
top = max(zip_pts, key=lambda p: p.z)
pull = box("elf_zip_pull", top + Vector((0, 0.012, -0.02)), (0.026, 0.01, 0.04), M["gold"], bevel=0.003)

# Landmarks for rig_elf.py (bone heads/tails follow the sculpt).
JOINTS = {"shoulder": SHOULDER, "elbow": ELBOW, "wrist": WRIST, "hand_end": HAND_END, "pompom": tuple(POM),
          "head_top": (0, 0, HEAD_Z + 0.2), "neck": (0, 0, 0.58), "hip": (0.085, 0, 0.27), "knee": (0.09, 0, 0.15),
          "toe": (0.09, 0.17, 0.05), "palm_r": tuple(PALM_R), "palm_l": (-PALM_R.x, PALM_R.y, PALM_R.z)}
print("built", [o.name for o in bpy.data.objects])
