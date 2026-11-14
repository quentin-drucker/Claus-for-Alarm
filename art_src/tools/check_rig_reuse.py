"""Skeleton reuse check (P15-T10): rebuild the Rookie rig with other elves' proportions, play the Rookie's
actions on each, and report how far each bone's world direction drifts from the Rookie pose (degrees).
Run in Blender after opening art_src/characters/elf_rookie.blend (needs rig_elf.py's BONES table)."""
import math
import bpy
from mathutils import Vector

src = bpy.data.objects["elf_rig"]
BONES = {b.name: (tuple(b.head_local), tuple(b.tail_local), b.parent.name if b.parent else None) for b in src.data.bones}
# Proposed builds (DEC-034: visibly different size/build per tower). sx = width, sz = height, sy = depth.
VARIANTS = {"identity": (1.0, 1.0, 1.0), "ranger_slim": (0.85, 1.0, 1.12), "wax_broad": (1.25, 1.1, 0.95), "sorcerer_short": (1.0, 1.0, 0.85),
            "operator_stocky": (1.15, 1.1, 0.9)}
def mode(obj, m):
    bpy.context.view_layer.objects.active = obj
    with bpy.context.temp_override(active_object=obj, object=obj, selected_objects=[obj]):
        bpy.ops.object.mode_set(mode=m)


CHECK = ["upper_arm.R", "forearm.R", "hand.R", "upper_arm.L", "spine", "head", "thigh.R", "foot.R"]


def world_dirs(rig, action, frame):
    rig.animation_data.action = action
    rig.animation_data.action_slot = action.slots[0]  # Blender 5 slotted actions: bind the Rookie's slot too
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.update()
    return {b: (rig.matrix_world @ rig.pose.bones[b].tail - rig.matrix_world @ rig.pose.bones[b].head).normalized()
            for b in CHECK}


def build(name, sx, sy, sz):
    arm = bpy.data.armatures.new(name)
    rig = bpy.data.objects.new(name, arm)
    bpy.context.scene.collection.objects.link(rig)
    mode(rig, "EDIT")
    for n, (h, t, p) in BONES.items():
        e = arm.edit_bones.new(n)
        e.head = (h[0] * sx, h[1] * sy, h[2] * sz)
        e.tail = (t[0] * sx, t[1] * sy, t[2] * sz)
    for n, (h, t, p) in BONES.items():
        if p:
            arm.edit_bones[n].parent = arm.edit_bones[p]
    # match each bone's roll to the Rookie so rest-relative rotations mean the same thing
    mode(rig, "OBJECT")
    mode(src, "EDIT")
    rolls = {e.name: e.roll for e in src.data.edit_bones}
    mode(src, "OBJECT")
    mode(rig, "EDIT")
    for n, r in rolls.items():
        arm.edit_bones[n].roll = r
    mode(rig, "OBJECT")
    rig.animation_data_create()
    for b in rig.pose.bones:
        b.rotation_mode = "QUATERNION"
    return rig


report = {}
ref = {a: world_dirs(src, bpy.data.actions[a], f) for a, f in (("idle_loop", 1), ("attack", 4))}
for name, (sx, sy, sz) in VARIANTS.items():
    rig = build("check_" + name, sx, sy, sz)
    worst = {}
    for a, f in (("idle_loop", 1), ("attack", 4)):
        d = world_dirs(rig, bpy.data.actions[a], f)
        for b in CHECK:
            ang = math.degrees(d[b].angle(ref[a][b]))
            worst[b] = max(worst.get(b, 0.0), ang)
    report[name] = {b: round(v, 1) for b, v in worst.items()}
    bpy.data.objects.remove(rig, do_unlink=True)
src.animation_data.action = bpy.data.actions["idle_loop"]
bpy.context.scene.frame_set(1)
for k, v in report.items():
    print(k, v)
