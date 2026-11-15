"""P15-A01: non-destructive preparation of the supplied Tripo/AccuRIG FBXs -> runtime GLBs.

The source FBX and its texture folder under art_src/models/<name>/ are only ever read. Each run rebuilds the
derived art_src/prepared/<name>.blend and assets/models/<name>.glb from scratch, so the result is reproducible.

Headless (from the project root):
  blender -b --factory-startup --python art_src/tools/prepare_source_model.py -- inspect        # all sources
  blender -b --factory-startup --python art_src/tools/prepare_source_model.py -- avalanche_cannon

Conventions (docs/ART_STYLE.md 2, docs/CONVENTIONS.md): 1 unit = 1 m, origin = ground-contact centre (= the tower's
gameplay position and turn axis), model faces Blender +Y (= Godot -Z). The GLB is the *modelled* size; tower.gd's
display scale (DEC-036, 1.5x) is applied once at runtime by the PresentationProfile, never baked here.
"""
import math
import os
import sys
import tempfile

import bmesh
import bpy
from mathutils import Matrix, Vector

PROJECT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")) if "__file__" in dir() else os.getcwd()
MODELS = os.path.join(PROJECT, "art_src", "models")
PREPARED = os.path.join(PROJECT, "art_src", "prepared")
RUNTIME = os.path.join(PROJECT, "assets", "models")
GROUND_BAND = 0.02  # verts this close to the lowest point count as ground contact (source units)

# One entry per supplied source. Measured values are from `inspect` (raw import, source units; 2026-11-14).
# `yaw_deg`: turn about Z so the model faces +Y. `fit`: ("envelope", r) scales the largest horizontal distance from
# the placement centre to r metres (modelled, before the 1.5x display scale); ("height", h) scales the height.
# `markers`: name -> "centre" (half height), ("tip", weapon yaw, z band) (weapon_tip) or ("top", x fraction)
# (staff_top). `ground`: "largest_cluster" centres on the feet when a prop also touches the ground. Only entries with `prepare: True` are exported.
PROFILES = {
    "avalanche_cannon": {
        "fbx": "avalanche_cannon/avalanche_cannon.fbx",
        "prepare": True,
        # Source muzzle faces -Y (front view shows the bore) -> 180 deg.
        "yaw_deg": 180.0,
        # Footprint r 0.6 m (data, unchanged). Displayed envelope 0.44 x 1.5 = 0.66 m: the diagonal sled feet stay
        # within ~6 cm of the footprint so a cannon at the nearest legal spot does not reach over the track edge.
        "fit": ("envelope", 0.44),
        # The 3 open edges are one isolated ~1 cm triangle floating by the left trunnion (each vertex has only that
        # face), not a hole in the shell: delete stray islands instead of filling.
        "drop_islands_below": 4,
        "texture_px": 1024,  # 2048 source maps; ~35 px tall at the game camera, 1024 keeps close-ups clean
        # Bore: front-most slab along the aim (yaw 0) above 35% height (the sled feet reach further forward).
        "markers": {"muzzle_A": ("tip", 0.0, 0.35, 1.0), "effect_center": "centre"},
    },
    "biathlon_ranger": {
        "fbx": "biathlon_ranger/biathlon_ranger.fbx",
        "prepare": True,
        "yaw_deg": 180.0,  # source faces -Y (front view shows the back)
        # Character: sized by height like the elves (ART_STYLE 2: base elf 1.2 m), not by the rifle's reach. The
        # rifle sets the envelope (0.559 of the height): 0.67 m modelled = 1.0 m displayed vs the 0.6 m footprint.
        "fit": ("height", 1.2),
        "texture_px": 1024,
        # Rifle barrel (PCA of the barrel verts) runs 60 deg off the body axis toward the character's left, at ~27%
        # height, pitched ~3 deg down. Same angle as the PresentationProfile weapon_yaw_deg.
        "markers": {"muzzle_A": ("tip", 60.0, 0.22, 0.36), "effect_center": "centre"},
    },
    "slope_wax_sprayer": {
        "fbx": "slope_wax_sprayer/slope_wax_sprayer.fbx",
        "prepare": True,
        "yaw_deg": 180.0,  # source faces -Y
        "fit": ("height", 1.2),  # character: elf height; tanks set the envelope (0.392 -> 0.71 m displayed)
        "texture_px": 1024,
        # Spray wand in the right hand points along the body axis (offset to the right), nozzle at ~37% height.
        "markers": {"muzzle_A": ("tip", 0.0, 0.28, 0.5), "effect_center": "centre"},
    },
    "snow_sorcerer": {
        "fbx": "snow_sorcerer/snow_sorcerer.fbx",
        "prepare": True,
        "yaw_deg": 180.0,  # source faces -Y (boots side by side along X)
        # Raw 0.719 tall and 7 mm below ground. The staff foot touches the ground beside the boots and drags the
        # contact-band centre 4 cm sideways: centre on the largest contact cluster (the boots) instead.
        "ground": "largest_cluster",
        # Robed elf: DEC-044 (owner, Dev 11) 1.13 m modelled = 1.70 m shown (was 1.0 / 1.5 m; Rookie 1.87 m) so the
        # staff reads at the game camera. Uniform scale: proportions, boots centre and grounding unchanged.
        "fit": ("height", 1.13),
        "texture_px": 1024,
        # Snowflake staff head: top slab of the verts on the staff side (+X after the turn, the right hand).
        "markers": {"muzzle_A": ("top", 0.5), "effect_center": "centre"},
    },
    "ski_resort_ticket_booth": {
        "fbx": "ski_resort_ticket_booth/ski_resort_ticket_booth.fbx",
        "prepare": True,
        "yaw_deg": 180.0,  # ticket window/counter faces -Y in the source
        # Building inside its 1.5 m data footprint: envelope 1.0 m modelled = 1.5 m shown (corners on the footprint
        # circle), 1.62 m tall modelled = 2.42 m shown.
        "fit": ("envelope", 1.0),
        "texture_px": 1024,
        # Ticket window: front-most slab (the counter) between 30% and 60% height.
        "markers": {"muzzle_A": ("tip", 0.0, 0.3, 0.6), "effect_center": "centre"},
    },
    # Inspected only (not prepared in this slice). Raw import: height, footprint size, notes.
    "snowball_rookie": {"fbx": "snowball_rookie/snowball_rookie_rigged.fbx", "prepare": False,
                        "note": "AccuRIG 71 bones, 0.01 armature scale, only T-Pose actions; embedded maps"},
    "camel_claus": {
        "fbx": "camel_claus/camel_claus.fbx",
        "prepare": True,
        "yaw_deg": 180.0,  # source faces -Y (front view shows the back sack)
        # Hero: ART_STYLE 2 "1.4 x elf" = 1.68 m modelled (2.52 m shown, Rookie 1.87 m). Sack/launcher set the
        # envelope (0.338 of the height).
        "fit": ("height", 1.68),
        "texture_px": 1024,
        # Candy-striped launcher held across the waist: front-most slab between 25% and 45% height (the snout
        # reaches further forward higher up). Goggles: front-most slab on the hat band. Hat pin: the pompom top.
        "markers": {"muzzle_A": ("tip", 0.0, 0.25, 0.45), "effect_center": "centre",
                    "focus_goggle": ("tip", 0.0, 0.84, 0.95), "hat_top": ("top", -1e9)},
    },
    "hockey_slapper": {"fbx": "hockey_slapper/hockey_slapper.fbx", "prepare": False,
                       "note": "no gameplay; 11 mm below ground, off-centre"},
    "snowboard_trickster": {"fbx": "snowboard_trickster/snowboard_trickster.fbx", "prepare": False,
                            "note": "no gameplay; object yaw -10 deg"},
}


def import_source(name):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=os.path.join(MODELS, PROFILES[name]["fbx"]))
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    assert len(meshes) == 1, f"{name}: expected one mesh, got {len(meshes)}"
    return meshes[0]


def measure(ob):
    """Bounds, ground-contact centre, envelope, topology and normal checks in world space."""
    pts = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    ground = [p for p in pts if p.z < lo.z + GROUND_BAND]
    gx = (min(p.x for p in ground) + max(p.x for p in ground)) / 2
    gy = (min(p.y for p in ground) + max(p.y for p in ground)) / 2
    envelope = max(math.hypot(p.x - gx, p.y - gy) for p in pts)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    open_edges = [e for e in bm.edges if not e.is_manifold]
    before = [f.normal.copy() for f in bm.faces]
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    flipped = sum(1 for f, n in zip(bm.faces, before) if f.normal.dot(n) < 0)
    tris = sum(len(f.verts) - 2 for f in bm.faces)
    bm.free()
    images = sorted({(os.path.basename(n.image.filepath) or n.image.name, tuple(n.image.size))
                     for m in ob.data.materials if m for n in m.node_tree.nodes
                     if n.type == "TEX_IMAGE" and n.image})
    return {"lo": lo, "hi": hi, "size": hi - lo, "ground_centre": Vector((gx, gy, lo.z)), "envelope": envelope,
            "tris": tris, "open_edges": len(open_edges), "flipped_vs_recalc": flipped,
            "materials": [m.name for m in ob.data.materials if m], "images": images,
            "object_rot_deg": tuple(round(math.degrees(a), 1) for a in ob.rotation_euler)}


def fmt(v):
    return "(" + ", ".join(f"{c:.3f}" for c in v) + ")"


def inspect_all():
    rows = []
    for name in PROFILES:
        ob = import_source(name)
        m = measure(ob)
        rows.append((name, m))
        print(f"{name}: size {fmt(m['size'])} min z {m['lo'].z:.3f} ground centre {fmt(m['ground_centre'])} "
              f"envelope {m['envelope']:.3f} tris {m['tris']} open edges {m['open_edges']} "
              f"normals flipped vs recalc {m['flipped_vs_recalc']} obj rot {m['object_rot_deg']} "
              f"armatures {len(bpy.data.armatures)} actions {[a.name for a in bpy.data.actions]} "
              f"images {m['images']}")
    return rows


def drop_islands(ob, max_faces):
    """Deletes connected face islands with fewer than `max_faces` faces (stray generator debris)."""
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    seen, doomed = set(), []
    for f in bm.faces:
        if f.index in seen:
            continue
        island, stack = [], [f]
        seen.add(f.index)
        while stack:
            cur = stack.pop()
            island.append(cur)
            for e in cur.edges:
                for n in e.link_faces:
                    if n.index not in seen:
                        seen.add(n.index)
                        stack.append(n)
        if len(island) < max_faces:
            doomed += island
    verts = {v for f in doomed for v in f.verts}
    print(f"  dropped {len(doomed)} stray face(s) at {[fmt(v.co) for v in list(verts)[:3]]}")
    bmesh.ops.delete(bm, geom=list(verts), context="VERTS")
    bm.to_mesh(ob.data)
    bm.free()


def weapon_tip(ob, yaw_deg, z_lo, z_hi):
    """Centre of a muzzle/nozzle opening: among the verts between z_lo and z_hi of the height, the front-most 3 cm slab
    along the weapon direction (`yaw_deg` from the model's +Y forward, Godot rotation.y sense: + turns toward -X),
    middle of its cross-section bounds, 4 cm back inside the barrel."""
    a = math.radians(yaw_deg)
    fwd, side = Vector((-math.sin(a), math.cos(a), 0)), Vector((math.cos(a), math.sin(a), 0))
    pts = [ob.matrix_world @ v.co for v in ob.data.vertices]
    top = max(p.z for p in pts)
    pts = [p for p in pts if z_lo * top < p.z <= z_hi * top]
    front = max(p.dot(fwd) for p in pts)
    slab = [p for p in pts if p.dot(fwd) > front - 0.03]
    s = (min(p.dot(side) for p in slab) + max(p.dot(side) for p in slab)) / 2
    z = (min(p.z for p in slab) + max(p.z for p in slab)) / 2
    return fwd * (front - 0.04) + side * s + Vector((0, 0, z))


def staff_top(ob, x_frac):
    """Centroid of the top 6% (of the height) of the verts beyond `x_frac` of the model's +X reach (a held staff)."""
    pts = [ob.matrix_world @ v.co for v in ob.data.vertices]
    reach = max(p.x for p in pts)
    side = [p for p in pts if p.x > x_frac * reach]
    top = max(p.z for p in side)
    head = [p for p in side if p.z > top - 0.06 * max(p.z for p in pts)]
    return sum(head, Vector()) / len(head)


def largest_ground_cluster(ob):
    """Centre (x, y, min z) of the biggest connected patch of contact-band verts (1.5 cm grid): the feet, not a prop."""
    pts = [ob.matrix_world @ v.co for v in ob.data.vertices]
    lo = min(p.z for p in pts)
    cells = {}
    for p in pts:
        if p.z < lo + GROUND_BAND:
            cells.setdefault((int(p.x // 0.015), int(p.y // 0.015)), []).append(p)
    seen, best = set(), []
    for c in cells:
        if c in seen:
            continue
        stack, grp = [c], []
        seen.add(c)
        while stack:
            k = stack.pop()
            grp += cells[k]
            for n in [(k[0] + dx, k[1] + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)]:
                if n in cells and n not in seen:
                    seen.add(n)
                    stack.append(n)
        best = grp if len(grp) > len(best) else best
    return Vector(((min(p.x for p in best) + max(p.x for p in best)) / 2,
                   (min(p.y for p in best) + max(p.y for p in best)) / 2, lo))


def prepare(name):
    prof = PROFILES[name]
    ob = import_source(name)
    raw = measure(ob)
    print(f"{name} raw: size {fmt(raw['size'])} envelope {raw['envelope']:.3f} open edges {raw['open_edges']} "
          f"flipped {raw['flipped_vs_recalc']}")
    if prof.get("drop_islands_below"):
        drop_islands(ob, prof["drop_islands_below"])
    # Bake object transform, then centre on the ground contact, turn to +Y and scale to the profile fit.
    ob.data.transform(ob.matrix_world)
    ob.matrix_world = Matrix.Identity(4)
    g = largest_ground_cluster(ob) if prof.get("ground") == "largest_cluster" else raw["ground_centre"]
    kind, target = prof["fit"]
    scale = target / (raw["envelope"] if kind == "envelope" else raw["size"].z)
    ob.data.transform(Matrix.Scale(scale, 4) @ Matrix.Rotation(math.radians(prof["yaw_deg"]), 4, "Z")
                      @ Matrix.Translation(-g))
    ob.data.update()
    ob.name = ob.data.name = name
    for mat in ob.data.materials:
        mat.name = f"M_{name}"
        mat.surface_render_method = "DITHERED"  # source HASHED; opaque maps (JPEG, no alpha) -> glTF OPAQUE
        mat.use_backface_culling = True  # closed shell: export single-sided (glTF doubleSided false)
    out = measure(ob)
    print(f"{name} prepared: scale x{scale:.4f}, size {fmt(out['size'])} (display x1.5 = {fmt(out['size'] * 1.5)}), "
          f"min z {out['lo'].z:.4f}, ground centre {fmt(out['ground_centre'])}, envelope {out['envelope']:.3f} "
          f"(display {out['envelope'] * 1.5:.3f}), tris {out['tris']}, open edges {out['open_edges']}")
    # Markers import into Godot as plain Node3D children of the scene root.
    for marker, spec in prof["markers"].items():
        e = bpy.data.objects.new(marker, None)
        e.empty_display_size = 0.05
        e.location = (Vector((0, 0, out["size"].z * 0.5)) if spec == "centre" else staff_top(ob, spec[1])
                      if spec[0] == "top" else weapon_tip(ob, *spec[1:]))
        bpy.context.scene.collection.objects.link(e)
        print(f"  marker {marker} at {fmt(e.location)} (display {fmt(e.location * 1.5)})")
    os.makedirs(PREPARED, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(PREPARED, name + ".blend"), relative_remap=True)
    # Runtime textures: downscaled PNG copies in a temp folder (the source maps and the .blend's references stay
    # 2048 JPEG). PNG, because Godot 4.7's JPEG loader rejects Blender-written JPEGs ("glTF: Couldn't load image
    # index '1' with its given mimetype: image/jpeg").
    tmp = tempfile.mkdtemp(prefix="cc_prepare_")
    for img in [i for i in bpy.data.images if i.size[0] > 0]:
        img.scale(min(img.size[0], prof["texture_px"]), min(img.size[1], prof["texture_px"]))
        img.filepath_raw = os.path.join(tmp, img.name.rsplit(".", 1)[0] + ".png")
        img.file_format = "PNG"
        img.save()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=os.path.join(RUNTIME, name + ".glb"), export_format="GLB",
                              use_selection=True, export_yup=True, export_apply=True, export_animations=False,
                              export_image_format="AUTO", export_extras=False)
    print(f"  wrote assets/models/{name}.glb")


if __name__ == "__main__":
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else ["inspect"]
    for arg in args:
        inspect_all() if arg == "inspect" else prepare(arg)
