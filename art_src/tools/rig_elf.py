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

# ---- armature (rest = A-pose of the sculpt; elf faces +Y, its right side is +X) ----
BONES = {  # name: (head, tail, parent)
    "root": ((0, 0, 0), (0, 0.12, 0), None),
    "hips": ((0, 0, 0.22), (0, 0, 0.36), "root"),
    "spine": ((0, 0, 0.36), (0, 0, 0.6), "hips"),
    "head": ((0, 0, 0.6), (0, 0, 1.0), "spine"),
    "cap_tip": ((0, -0.06, 0.98), (0.05, -0.37, 1.03), "head"),
    "upper_arm.R": ((0.13, 0, 0.55), (0.25, 0.02, 0.45), "spine"),
    "forearm.R": ((0.25, 0.02, 0.45), (0.31, 0.04, 0.35), "upper_arm.R"),
    "hand.R": ((0.31, 0.04, 0.35), (0.34, 0.1, 0.26), "forearm.R"),
    "thigh.R": ((0.09, 0, 0.26), (0.095, 0, 0.13), "hips"),
    "foot.R": ((0.095, 0, 0.13), (0.095, 0.16, 0.05), "thigh.R"),
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
ALLOWED = {
    "elf_skin": ["head", "spine"], "elf_cap": ["head", "cap_tip"], "elf_cap_band": ["head"],
    "elf_pompom": ["cap_tip"], "elf_eye": ["head"], "elf_glint": ["head"], "elf_brow": ["head"],
    "elf_smile": ["head"], "elf_jacket": ["spine", "hips"] + ARMS, "elf_zipper": ["spine", "hips"],
    "elf_strap": ["spine", "hips"], "elf_trims": ["spine", "hips", "forearm.R", "forearm.L", "thigh.R", "thigh.L"],
    "elf_trousers": ["hips", "thigh.R", "thigh.L"], "elf_boots": ["foot.R", "foot.L", "thigh.R", "thigh.L"],
    "elf_mittens": ["hand.R", "hand.L"], "elf_pellet": ["hand.R"], "elf_pouch": ["hips"],
    "elf_buckle": ["hips"], "elf_spare_snow": ["hips"],
}


def seg_dist(p, h, t):
    q, f = intersect_point_line(p, Vector(h), Vector(t))
    f = min(max(f, 0.0), 1.0)
    return (p - Vector(h).lerp(Vector(t), f)).length


game = []
for o in parts:
    o.users_collection[0].objects.unlink(o)
    hi.objects.link(o)
    g = o.copy()
    g.data = o.data.copy()
    bpy.context.scene.collection.objects.link(g)
    # Decimate big organic shells hardest; tiny face/kit pieces barely.
    t = tri_count(g)
    budget = max(120, GAME_TRIS * t / 140000)
    if t > budget:
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
    game.append(g)
hi.hide_viewport = True
hi.hide_render = True

body = join(game, "elf_rookie")
body.parent = rig
mod = body.modifiers.new("rig", "ARMATURE")
mod.object = rig
print("game tris", tri_count(body), "materials", len(body.data.materials))

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
socket("portrait_focus", (0, 0.15, 0.8), "head")
socket("weapon_hand_r", (0.34, 0.1, 0.27), "hand.R")
socket("weapon_hand_l", (-0.34, 0.1, 0.27), "hand.L")
socket("muzzle_A", (0.34, 0.135, 0.28), "hand.R")

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
