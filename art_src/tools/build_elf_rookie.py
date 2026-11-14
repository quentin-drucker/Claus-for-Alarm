"""Snowball Rookie elf (P15-T03/T04): chibi elf base body + Rookie outfit. Run in Blender:
exec(open(r"<proj>/art_src/tools/build_elf_rookie.py").read())
Each garment is one metaball group -> continuous remeshed surface; pieces overlap only where cloth tucks/laps.
"""
import math
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())

clear_scene()
M = {
    "skin": material("M_elf_skin", PAL["skin"], 0.55),  # DEC-036 rosy skin
    "jacket": material("M_puffy_cloth_navy", PAL["navy"], 0.85),
    "trousers": material("M_puffy_cloth_teal", PAL["teal"], 0.85),
    "trim": material("M_fur_trim", PAL["snow"], 0.95),
    "red": material("M_knit_red", PAL["red"], 0.9),
    "boot": material("M_leather_boot", PAL["dark_timber"], 0.6),
    "gold": material("M_gold_accent", PAL["gold"], 0.35, 0.8),
    "eye": material("M_eye_gloss", PAL["spruce"], 0.15),
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


def chain(points, radii, stiff=2.0, step=0.025):
    """Balls along a polyline with interpolated radius: a tapered tube that blends smoothly."""
    out = []
    for (a, ra), (b, rb) in zip(zip(points, radii), zip(points[1:], radii[1:])):
        a, b = Vector(a), Vector(b)
        n = max(1, int((b - a).length / step))
        for k in range(n):
            t = k / n
            out.append({"co": tuple(a.lerp(b, t)), "radius": ra + (rb - ra) * t, "stiff": stiff})
    out.append({"co": tuple(points[-1]), "radius": radii[-1], "stiff": stiff})
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


HEAD_Z = 0.80
# ---- skin: skull, jaw, cheeks, nose, neck and ears as one continuous surface ----
ear = chain([(0.15, -0.01, HEAD_Z + 0.0), (0.24, -0.045, HEAD_Z + 0.05), (0.33, -0.09, HEAD_Z + 0.13)],
            [0.042, 0.026, 0.006], step=0.01)
skin = metaball_mesh("elf_skin", [
    {"type": "ELLIPSOID", "co": (0, 0, HEAD_Z), "radius": 0.2, "size": (1.0, 0.95, 0.95)},
    {"type": "ELLIPSOID", "co": (0, 0.05, HEAD_Z - 0.07), "radius": 0.15, "size": (1.0, 0.85, 0.7)},
    {"co": (0.085, 0.12, HEAD_Z - 0.05), "radius": 0.065},
    {"co": (-0.085, 0.12, HEAD_Z - 0.05), "radius": 0.065},
    {"co": (0, 0.19, HEAD_Z - 0.02), "radius": 0.03},  # button nose
    {"co": (0, 0, HEAD_Z - 0.2), "radius": 0.065},  # neck
] + mirror(ear), resolution=0.007, remesh=0.006, mat=M["skin"])

# ---- jacket: torso, shoulders and sleeves are one garment, with two quilting grooves ----
sleeve = chain([(0.13, 0, 0.55), (0.25, 0.02, 0.45), (0.31, 0.04, 0.35)], [0.075, 0.062, 0.06], step=0.02)
jacket = metaball_mesh("elf_jacket", [
    {"type": "ELLIPSOID", "co": (0, 0.0, 0.44), "radius": 0.18, "size": (1.0, 0.85, 1.0)},
    {"co": (0, 0.03, 0.38), "radius": 0.17},
    {"type": "ELLIPSOID", "co": (0, 0, 0.53), "radius": 0.15, "size": (1.1, 0.85, 0.75)},
] + mirror(sleeve) + ring((0, 0.0, 0.47), (0, 0, 1), 0.205, 0.022, n=28, squash=0.85, neg=True, stiff=2.0)
  + ring((0, 0.015, 0.37), (0, 0, 1), 0.21, 0.022, n=28, squash=0.88, neg=True),
    mat=M["jacket"])

# ---- trousers ----
leg = chain([(0.085, 0, 0.26), (0.095, 0, 0.12)], [0.068, 0.06])
trousers = metaball_mesh("elf_trousers", [
    {"type": "ELLIPSOID", "co": (0, 0, 0.27), "radius": 0.15, "size": (1.0, 0.85, 0.6)},
] + mirror(leg), mat=M["trousers"])

# ---- boots with curled elf toes ----
boot = [{"type": "ELLIPSOID", "co": (0.095, 0.035, 0.055), "radius": 0.065, "size": (1.0, 1.6, 0.85)},
        {"co": (0.095, -0.005, 0.11), "radius": 0.06}] + \
    chain([(0.095, 0.11, 0.05), (0.095, 0.18, 0.07), (0.095, 0.215, 0.115), (0.095, 0.19, 0.15)],
          [0.045, 0.03, 0.018, 0.012], step=0.008)
boots = metaball_mesh("elf_boots", mirror(boot), mat=M["boot"])

# ---- mittens with thumbs ----
# Right mitten GRIPS the snowball: palm behind it, the finger lobe curls over its top-front, thumb on the inner side.
PELLET = Vector((0.35, 0.12, 0.25))  # snowball centre = muzzle_A socket (rig_elf.py)
PELLET_R = 0.05
grip = [{"type": "ELLIPSOID", "co": (0.338, 0.065, 0.29), "radius": 0.06, "size": (0.9, 0.8, 1.0)}]     + chain([(0.345, 0.09, 0.322), (0.352, 0.145, 0.312), (0.356, 0.178, 0.272), (0.354, 0.172, 0.232)],
            [0.03, 0.026, 0.022, 0.018], step=0.008)     + chain([(0.302, 0.085, 0.272), (0.3, 0.125, 0.252), (0.31, 0.155, 0.238)], [0.026, 0.022, 0.018], step=0.008)
# Left mitten: relaxed, thumb up.
open_mitt = [{"type": "ELLIPSOID", "co": (-0.335, 0.06, 0.285), "radius": 0.068, "size": (0.85, 0.85, 1.05)},
             {"co": (-0.31, 0.115, 0.315), "radius": 0.03}]
mittens = metaball_mesh("elf_mittens", grip + open_mitt, mat=M["red"])

# ---- fur trims hugging the real garment sections: wrist cuffs, jacket hem, collar, boot cuffs ----
cuff_n = Vector((0.06, 0.02, -0.1)).normalized()
trims = metaball_mesh("elf_trims",
    band_elements(jacket, (0.3, 0.038, 0.365), cuff_n, 0.026, push=0.004, max_r=0.12)
    + band_elements(jacket, (-0.3, 0.038, 0.365), (-cuff_n.x, cuff_n.y, cuff_n.z), 0.026, push=0.004, max_r=0.12)
    + band_elements(jacket, (0, 0, 0.3), (0, 0, 1), 0.034, push=0.006, max_r=0.3)
    + band_elements(skin, (0, 0, 0.625), (0, 0.15, 1), 0.034, push=0.012, max_r=0.15)
    + band_elements(trousers, (0.095, 0, 0.15), (0, 0, 1), 0.026, push=0.006, max_r=0.1)
    + band_elements(trousers, (-0.095, 0, 0.15), (0, 0, 1), 0.026, push=0.006, max_r=0.1),
    mat=M["trim"])

# ---- knit cap: dome conforming to the skull, cut at the brim, drooping tip, fur band, pompom ----
BRIM_N = Vector((0, -0.35, 1)).normalized()  # brim plane leans back: forehead shows
BRIM_C = Vector((0, 0.0, HEAD_Z + 0.075))
cap = metaball_mesh("elf_cap", [
    {"type": "ELLIPSOID", "co": (0, -0.01, HEAD_Z + 0.03), "radius": 0.212, "size": (1.0, 0.97, 0.95)},
] + chain([(0, -0.04, HEAD_Z + 0.19), (0, -0.09, HEAD_Z + 0.31), (0, -0.19, HEAD_Z + 0.38), (0.03, -0.3, HEAD_Z + 0.35),
           (0.05, -0.36, HEAD_Z + 0.27)], [0.125, 0.08, 0.05, 0.032, 0.025], step=0.012), mat=M["red"])
bm = bmesh.new()
bm.from_mesh(cap.data)
bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=BRIM_C, plane_no=BRIM_N,
                       clear_inner=True)
bm.to_mesh(cap.data)
bm.free()
band = metaball_mesh("elf_cap_band", band_elements(cap, BRIM_C + BRIM_N * 0.012, BRIM_N, 0.036, push=0.004),
                     mat=M["trim"])
pompom = metaball_mesh("elf_pompom", [{"co": (0.05, -0.37, HEAD_Z + 0.225), "radius": 0.048}]
                       + [{"co": (0.05, -0.37 + 0.032 * math.cos(a), HEAD_Z + 0.225 + 0.032 * math.sin(a)), "radius": 0.026}
                          for a in (0.5, 2.0, 3.6, 5.0)], mat=M["trim"])

# ---- face: every detail is projected onto the real skin surface so nothing floats (B-01) ----
def onto(co, off):
    ok, loc, nrm, _ = skin.closest_point_on_mesh(Vector(co))
    return tuple(loc + nrm * off)


def face_chain(name, pts, radii, off, mat):
    return metaball_mesh(name, chain([onto(p, off) for p in pts], radii, step=0.005),
                         resolution=0.004, remesh=0, smooth=0, mat=mat)


brow_mat = material("M_brow", PAL["dark_timber"], 0.9)
for sx in (1, -1):
    ok, loc, nrm, _ = skin.closest_point_on_mesh(Vector((sx * 0.07, 0.2, HEAD_Z + 0.018)))
    eye_c = tuple(loc - nrm * 0.001)  # seated on the face, thin axis along the face normal (no uneven sinking)
    eye_rot = [math.degrees(a) for a in Vector((0, 1, 0)).rotation_difference(nrm).to_euler()]
    metaball_mesh("elf_eye", [{"type": "ELLIPSOID", "co": eye_c, "radius": 0.044, "size": (0.8, 0.3, 1.1),
                               "rot": eye_rot}], resolution=0.004, remesh=0, smooth=0, mat=M["eye"])
    metaball_mesh("elf_glint", [{"co": tuple(Vector(eye_c) + Vector((0.011, 0.014, 0.017))), "radius": 0.01}],
                  resolution=0.003, remesh=0, smooth=0, mat=M["trim"])
    face_chain("elf_brow", [(sx * 0.04, 0.2, HEAD_Z + 0.06), (sx * 0.075, 0.2, HEAD_Z + 0.072),
                            (sx * 0.102, 0.2, HEAD_Z + 0.064)], [0.013, 0.014, 0.009], 0.002, brow_mat)
face_chain("elf_smile", [(-0.045, 0.2, HEAD_Z - 0.075), (0, 0.2, HEAD_Z - 0.095), (0.045, 0.2, HEAD_Z - 0.075)],
           [0.009, 0.011, 0.009], 0.0, material("M_mouth", "#8E2F3A", 0.6))

# ---- Rookie kit: snowball satchel on the left hip (strap follows the jacket), snowball in the right mitten ----
pouch = metaball_mesh("elf_pouch", [{"type": "ELLIPSOID", "co": (-0.235, 0.06, 0.225), "radius": 0.075,
                                     "size": (0.7, 0.85, 0.85)},
                                    {"type": "ELLIPSOID", "co": (-0.24, 0.085, 0.27), "radius": 0.05, "size": (0.8, 0.8, 0.45)}],
                      mat=M["red"])
strap_n = Vector((1, 0, 0.75)).normalized()  # diagonal plane: right shoulder -> left hip
strap = metaball_mesh("elf_strap", [e for e in band_elements(jacket, (0, 0, 0.42), strap_n, 0.016, push=0.006,
                                                              max_r=0.35, spacing=0.008)],
                      resolution=0.005, remesh=0, smooth=0, mat=material("M_strap", PAL["spruce"], 0.7))
ok, b_loc, b_nrm, _ = pouch.closest_point_on_mesh(Vector((-0.25, 0.2, 0.255)))
buckle = metaball_mesh("elf_buckle", [{"type": "ELLIPSOID", "co": tuple(b_loc), "radius": 0.022, "size": (1, 0.45, 1)}],
                       resolution=0.004, remesh=0, smooth=0, mat=M["gold"])
spare = metaball_mesh("elf_spare_snow", [{"co": (-0.25 + 0.035 * k, 0.04, 0.29 + 0.01 * k), "radius": 0.034}
                                         for k in (0, 1)], mat=M["snow"])
pellet = metaball_mesh("elf_pellet", [{"co": tuple(PELLET), "radius": PELLET_R}]
                       + [{"co": tuple(PELLET + Vector((0.028 * math.cos(a), 0.028 * math.sin(a), 0.018 * math.sin(2 * a)))),
                           "radius": 0.028} for a in (0.3, 1.9, 3.3, 4.8)], mat=M["snow"])
zip_pts = section_points(jacket, Vector((0, 0, 0)), Vector((1, 0, 0)), max_r=2.0, spacing=0.01)
zip_pts = [p for p in zip_pts if p.y > 0 and 0.3 < p.z < 0.6]
zipper = metaball_mesh("elf_zipper", [{"co": tuple(p + Vector((0, 0.004, 0))), "radius": 0.012} for p in zip_pts],
                       resolution=0.004, remesh=0, smooth=0, mat=M["gold"])
print("built", [o.name for o in bpy.data.objects])
