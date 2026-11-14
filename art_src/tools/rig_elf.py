"""Rookie elf: master_hi collection, game mesh (decimated, one skinned mesh), armature, B-11 sockets,
idle_loop + attack actions. Run after build_elf_rookie.py (same Blender session)."""
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())
from mathutils.geometry import intersect_point_line

GAME_TRIS = 14000
parts = [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith("elf_")]

# Keep the high-res master untouched in its own (hidden) collection; the game mesh is a copy.
hi = bpy.data.collections.get("master_hi") or bpy.data.collections.new("master_hi")
if hi.name not in bpy.context.scene.collection.children:
    bpy.context.scene.collection.children.link(hi)

# ---- armature (rest = A-pose of the sculpt; elf faces +Y, its right side is +X); joints from the build's JOINTS ----
J = JOINTS
NECK_Z = J["neck"][2]
BONES = {  # name: (head, tail, parent)
    "root": ((0, 0, 0), (0, 0.12, 0), None),
    "hips": ((0, 0, 0.2), (0, 0, NECK_Z - 0.24), "root"),
    "spine": ((0, 0, NECK_Z - 0.24), (0, 0, NECK_Z), "hips"),
    "head": ((0, 0, NECK_Z), J["head_top"], "spine"),
    "cap_tip": ((0, -0.02, J["head_top"][2] - 0.05), J["pompom"], "head"),
    "upper_arm.R": (J["shoulder"], J["elbow"], "spine"),
    "forearm.R": (J["elbow"], J["wrist"], "upper_arm.R"),
    "hand.R": (J["wrist"], J["hand_end"], "forearm.R"),
    "thigh.R": (J["hip"], J["knee"], "hips"),
    "foot.R": (J["knee"], J["toe"], "thigh.R"),
}
for n in list(BONES):
    if n.endswith(".R"):
        h, t, p = BONES[n]
        BONES[n[:-2] + ".L"] = ((-h[0], h[1], h[2]), (-t[0], t[1], t[2]), p.replace(".R", ".L") if p else None)

arm_data = bpy.data.armatures.new("elf_rig")
rig = bpy.data.objects.new("elf_rig", arm_data)
bpy.context.scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="EDIT")
for n, (h, t, p) in BONES.items():
    b = arm_data.edit_bones.new(n)
    b.head, b.tail = h, t
for n, (h, t, p) in BONES.items():
    if p:
        arm_data.edit_bones[n].parent = arm_data.edit_bones[p]
        arm_data.edit_bones[n].use_connect = Vector(h) == Vector(BONES[p][1])
bpy.ops.object.mode_set(mode="OBJECT")

# Which bones each garment may follow (no cross-garment weight bleed, e.g. jacket hem onto thighs).
ARMS = ["upper_arm.R", "forearm.R", "upper_arm.L", "forearm.L"]
HEAD_ONLY = ["elf_hair", "elf_cap_band", "elf_eyeball", "elf_lid", "elf_lash", "elf_brow", "elf_nose", "elf_smile"]
ALLOWED = {
    "elf_skin": ["head", "spine"], "elf_cap": ["head", "cap_tip"], "elf_pompom": ["cap_tip"],
    "elf_jacket": ["spine", "hips"] + ARMS, "elf_zipper": ["spine", "hips"], "elf_zip_pull": ["spine"],
    "elf_trims": ["spine", "hips", "forearm.R", "forearm.L"],
    "elf_trousers": ["hips", "thigh.R", "thigh.L"], "elf_boots": ["foot.R", "foot.L", "thigh.R", "thigh.L"],
    "elf_hands": ["hand.R", "hand.L"], "elf_pellet": ["hand.R"],
    "elf_belt": ["hips"], "elf_buckle": ["hips"], "elf_buckle_in": ["hips"],
    **{k: ["head"] for k in HEAD_ONLY},
}


def seg_dist(p, h, t):
    q, f = intersect_point_line(p, Vector(h), Vector(t))
    f = min(max(f, 0.0), 1.0)
    return (p - Vector(h).lerp(Vector(t), f)).length


# ---- vertex-colour "atlas": every part's colour + painted detail lives in COLOR_0, so the whole elf needs only two
# materials (matte + gloss) instead of one per part (B-09 draw-call budget). ----
from mathutils import noise
BASE = {"elf_skin": "skin", "elf_hands": "skin", "elf_jacket": "navy", "elf_trousers": "teal", "elf_trims": "snow",
        "elf_cap_band": "snow", "elf_pompom": "snow", "elf_cap": "red", "elf_boots": "timber", "elf_belt": "belt",
        "elf_buckle": "gold", "elf_buckle_in": "belt", "elf_zipper": "gold", "elf_zip_pull": "gold",
        "elf_hair": "hair", "elf_eyeball": "white_pure", "elf_lid": "lid", "elf_lash": "lid",
        "elf_brow": "dark_timber", "elf_nose": "nose", "elf_smile": "mouth", "elf_pellet": "snow"}
COLS = dict(PAL, white_pure="#FFFFFF")
GLOSS = {"elf_buckle", "elf_zipper", "elf_zip_pull", "elf_nose"}
M_MATTE = material("M_elf_matte", "#FFFFFF", 0.8, use_vcol=True)
M_GLOSS = material("M_elf_gloss", "#FFFFFF", 0.22, use_vcol=True)
# Eyes: the painted iris texture straight into Base Color (glTF exports it; Godot multiplies COLOR_0 = white).
M_EYE_GAME = material("M_elf_eye_game", "#FFFFFF", 0.15)
_nt = M_EYE_GAME.node_tree
_tex = _nt.nodes.new("ShaderNodeTexImage")
_tex.image = bpy.data.images["elf_eye"]
_nt.links.new(_tex.outputs["Color"], next(n for n in _nt.nodes if n.type == "BSDF_PRINCIPLED").inputs["Base Color"])
# Blush centres ON the cheek surface: ray straight back from in front of each cheek onto the skin.
CHEEKS = [bpy.data.objects["elf_skin"].ray_cast(Vector((sx * 0.12, 0.4, HEAD_Z - 0.1)), Vector((0, -1, 0)))[1]
          for sx in (1, -1)]


def lin(h):
    return Vector(hex_lin(COLS[h])[:3])


def paint(g, key):
    base = lin(BASE[key])
    attr = g.data.color_attributes.new("Col", "FLOAT_COLOR", "POINT")
    g.data.color_attributes.active_color = attr
    for v in g.data.vertices:
        c = base.copy()
        p = v.co
        if key == "elf_skin":  # round blush ovals on the cheeks (sheet 02)
            w = max(math.exp(-(((p - ch).x / 0.03) ** 2 + ((p - ch).z / 0.022) ** 2) ** 1.5) for ch in CHEEKS)
            c = c.lerp(lin("blush"), 0.85 * min(1.0, w))
        elif key == "elf_cap":  # knit ribs
            rib = 0.5 + 0.5 * math.cos(28 * math.atan2(p.x, p.y + 0.03))
            c = c * (0.86 + 0.14 * rib)
        elif key == "elf_hair":  # strand streaks + lighter top
            streak = 0.5 + 0.5 * math.cos(70 * math.atan2(p.x, p.y + 0.02) + 6 * p.z)
            c = c.lerp(lin("hair_light"), 0.35 * streak + 0.3 * min(1.0, max(0.0, (p.z - HEAD_Z) / 0.15)))
        elif key in ("elf_trims", "elf_cap_band", "elf_pompom"):  # fluffy fur
            c = c * (0.9 + 0.1 * noise.noise(p * 60))
        elif key in ("elf_jacket", "elf_trousers"):  # light from above + faint fabric grain
            c = c * (0.9 + 0.18 * min(1.0, max(0.0, (p.z - 0.25) / 0.4)) + 0.03 * noise.noise(p * 90))
        elif key == "elf_boots":  # darker sole and cuff
            c = c.lerp(lin("dark_timber"), 0.5 if p.z < 0.02 or p.z > 0.15 else 0.0)
        attr.data[v.index].color = (c.x, c.y, c.z, 1.0)
    g.data.materials.clear()
    g.data.materials.append(M_EYE_GAME if key == "elf_eyeball" else M_GLOSS if key in GLOSS else M_MATTE)


game = []
HI_TRIS = sum(tri_count(o) for o in parts)
for o in parts:
    o.users_collection[0].objects.unlink(o)
    hi.objects.link(o)
    g = o.copy()
    g.data = o.data.copy()
    bpy.context.scene.collection.objects.link(g)
    # Decimate big organic shells hardest; tiny face/kit pieces barely.
    t = tri_count(g)
    budget = max(120, GAME_TRIS * t / HI_TRIS)
    if t > budget and not o.name.startswith("elf_eyeball"):  # eyeballs keep their planar UVs
        decimate(g, budget / t)
    allowed = ALLOWED[o.name.split(".")[0]]
    for b in allowed:
        g.vertex_groups.new(name=b)
    for v in g.data.vertices:
        # Smooth inverse-distance weights over the 3 nearest allowed bones (no hard steps -> no tearing).
        d = sorted((seg_dist(v.co, BONES[b][0], BONES[b][1]), b) for b in allowed)[:3]
        ws = [(1.0 / (dist + 0.01) ** 4, b) for dist, b in d]
        tot = sum(w for w, _ in ws)
        for w, b in ws:
            if w / tot > 0.02:
                g.vertex_groups[b].add([v.index], w / tot, "REPLACE")
    paint(g, o.name.split(".")[0])
    if not g.data.uv_layers:  # join keeps a UV layer only if every part has one: the eyeballs' planar UVs must survive
        g.data.uv_layers.new(name="UVMap")
    game.append(g)
hi.hide_viewport = True
hi.hide_render = True

body = join(game, "elf_rookie")
body.parent = rig
mod = body.modifiers.new("rig", "ARMATURE")
mod.object = rig
# Baked ambient occlusion into the vertex colours (rest pose): short hemisphere rays against the whole elf.
from mathutils.bvhtree import BVHTree
bvh = BVHTree.FromObject(body, bpy.context.evaluated_depsgraph_get())
DIRS = [Vector((math.cos(a) * math.sin(e), math.sin(a) * math.sin(e), math.cos(e))) for e in (0.5, 1.1)
        for a in [2 * math.pi * k / 6 for k in range(6)]]
col = body.data.color_attributes["Col"]
eye_idx = body.data.materials.find(M_EYE_GAME.name)
eye_verts = {vi for poly in body.data.polygons if poly.material_index == eye_idx for vi in poly.vertices}
for v in body.data.vertices:
    if v.index in eye_verts:  # the painted eye carries its own shading
        continue
    n = v.normal
    basis = n.to_track_quat("Z", "Y")
    hits = sum(1 for d in DIRS if bvh.ray_cast(v.co + n * 0.003, basis @ d, 0.07)[0] is not None)
    k = 1.0 - 0.5 * hits / len(DIRS)
    r, g_, b_, a_ = col.data[v.index].color
    col.data[v.index].color = (r * k, g_ * k, b_ * k, 1.0)
print("game tris", tri_count(body), "of hi", HI_TRIS, "materials", len(body.data.materials))

# ---- B-11 sockets (empties; bone-parented ones follow the animation) ----
def socket(name, co, bone=None):
    e = empty(name, co, parent=rig)
    if bone:
        e.parent_type = "BONE"
        e.parent_bone = bone
        # bone-parent space is the bone tail: keep the world position
        e.matrix_world = __import__("mathutils").Matrix.Translation(Vector(co))
    return e


socket("root_ground", (0, 0, 0))
socket("shadow_anchor", (0, 0, 0.002))
socket("aim_pivot", (0, 0, 0.45))
socket("effect_center", (0, 0, 0.5), "spine")
socket("portrait_focus", (0, 0.2, HEAD_Z), "head")
socket("weapon_hand_r", J["palm_r"], "hand.R")
socket("weapon_hand_l", J["palm_l"], "hand.L")
socket("muzzle_A", tuple(PELLET), "hand.R")

# ---- actions: idle_loop (cocked throw stance, breathing, cap sway) and attack (overhand throw) ----
rig.animation_data_create()
D = math.radians


def pose_bone(b, spec):
    """spec: (rx, ry, rz) degrees in bone space, or a world-space direction Vector the bone should point along."""
    pb = rig.pose.bones[b]
    pb.rotation_mode = "QUATERNION"
    if isinstance(spec, Vector):
        bpy.context.view_layer.update()
        pb.rotation_quaternion = (1, 0, 0, 0)
        bpy.context.view_layer.update()
        m = (rig.matrix_world @ pb.matrix).to_3x3().normalized()
        pb.rotation_quaternion = Vector((0, 1, 0)).rotation_difference(m.inverted() @ spec.normalized())
    else:
        from mathutils import Euler
        pb.rotation_quaternion = Euler([D(a) for a in spec]).to_quaternion()


def key(action_name, poses, loop=False):
    """poses: {frame: {bone: spec}}; bones are posed parent-first; unlisted bones stay at rest."""
    act = bpy.data.actions.new(action_name)
    act.use_fake_user = True
    rig.animation_data.action = act
    bones = [b for b in BONES if any(b in p for p in poses.values())]
    for f, pose in poses.items():
        for b in rig.pose.bones:
            b.rotation_mode = "QUATERNION"
            b.rotation_quaternion = (1, 0, 0, 0)
        for b in bones:
            pose_bone(b, pose.get(b, (0, 0, 0)))
            rig.pose.bones[b].keyframe_insert("rotation_quaternion", frame=f)
    act.frame_range = (min(poses), max(poses))
    act.use_cyclic = loop
    for b in rig.pose.bones:
        b.rotation_quaternion = (1, 0, 0, 0)
    return act


V = Vector
# Cocked: upper arm out to the side, forearm up and back, snowball beside the head; spine (local X = lean,
# local Y = twist) turns the throwing shoulder back.
COCK = {"spine": (0, -12, 0), "head": (0, 10, 0), "upper_arm.R": V((0.95, -0.25, 0.15)),
        "forearm.R": V((0.15, -0.35, 1)), "hand.R": V((0.1, -0.2, 1)),
        "upper_arm.L": V((-0.6, 0.55, -0.55)), "forearm.L": V((-0.3, 0.9, -0.3)), "hand.L": V((-0.2, 1, -0.2))}
BREATHE = dict(COCK, spine=(4, -12, 0), head=(-4, 10, 0), cap_tip=(10, 0, 8))
idle = key("idle_loop", {1: dict(COCK, cap_tip=(-5, 0, -5)), 25: BREATHE, 48: dict(COCK, cap_tip=(-5, 0, -5))},
           loop=True)
THROW = {"spine": (18, 20, 0), "head": (-12, -12, 0), "cap_tip": (-20, 0, -12),
         "upper_arm.R": V((0.35, 1, 0.05)), "forearm.R": V((0.1, 1, -0.45)), "hand.R": V((0, 1, -0.7)),
         "upper_arm.L": V((-0.8, -0.4, -0.45)), "forearm.L": V((-0.6, -0.5, -0.6)), "hand.L": V((-0.5, -0.4, -0.7))}
attack = key("attack", {1: COCK, 4: THROW, 12: COCK})
for act in (idle, attack):
    tr = rig.animation_data.nla_tracks.new()
    tr.name = act.name
    tr.strips.new(act.name, int(act.frame_range[0]), act)
    tr.mute = True
rig.animation_data.action = idle
print("rig ok", [b.name for b in arm_data.bones])

# ---- save source + export game GLB (rig, skinned mesh, sockets, actions) ----
bpy.context.scene.frame_set(1)
os.makedirs(os.path.join(PROJ, "art_src", "characters"), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(PROJ, "art_src", "characters", "elf_rookie.blend"))
export_glb([rig, body] + [c for c in rig.children if c.type == "EMPTY"],
           os.path.join(PROJ, "assets", "models", "elf_rookie.glb"), animations=True)
print("exported elf_rookie.glb")
