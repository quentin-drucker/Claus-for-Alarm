"""Claus for Alarm art helpers (P15). Run inside Blender: exec(open(path).read()).

Conventions (docs/ART_STYLE.md): 1 unit = 1 m, Z up, origin = ground-contact centre, models face +Y
(= Godot -Z after glTF export). Organic forms are metaball groups converted to mesh and voxel-remeshed,
so each garment is one continuous surface (no visible primitive joins).
"""
import bpy
import bmesh
import math
import os
from mathutils import Vector

PROJ = r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm"
EVIDENCE = os.path.join(PROJ, "docs", "logs", "evidence")

# HYB-A A-01 tokens + ART_STYLE.md proposals.
PAL = {
    "navy": "#20517A", "red": "#D9545C", "snow": "#E7F4F8", "shadow_snow": "#AFC7D5", "gold": "#F9C96D",
    "timber": "#A8795A", "spruce": "#173C4E", "teal": "#1B6D68", "skin": "#F2C7A5", "dark_timber": "#6E4B37",
    "stone": "#8C9AA6", "glacier": "#8FD8E8",
    "powder": "#DBE9F5", "blue": "#72CEF5", "mint": "#4ACAAA", "violet": "#BD8DF1", "coral": "#F59471",
    "black": "#2B2F36", "white": "#F7FBFF", "purple": "#7A3FD6",
}


def hex_srgb(h):
    return tuple(int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))


def hex_lin(h):
    return tuple(((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92 for v in hex_srgb(h)) + (1.0,)


def clear_scene():
    for a in list(bpy.data.actions):
        bpy.data.actions.remove(a)
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for coll in (bpy.data.meshes, bpy.data.metaballs, bpy.data.materials, bpy.data.armatures, bpy.data.curves,
                 bpy.data.actions, bpy.data.cameras, bpy.data.lights):
        for d in list(coll):
            if d.users == 0:
                coll.remove(d)


def material(name, hex_color, rough=0.8, metal=0.0, emit=0.0, use_vcol=False):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = hex_lin(hex_color)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if emit > 0:
        bsdf.inputs["Emission Color"].default_value = hex_lin(hex_color)
        bsdf.inputs["Emission Strength"].default_value = emit
    if use_vcol:
        # Vertex colour (baked AO/pattern) multiplies the tint; glTF exports COLOR_0 and Godot reads it.
        attr = next((n for n in nt.nodes if n.type == "VERTEX_COLOR"), None) or nt.nodes.new("ShaderNodeVertexColor")
        mix = next((n for n in nt.nodes if n.type == "MIX"), None) or nt.nodes.new("ShaderNodeMix")
        mix.data_type = "RGBA"
        mix.blend_type = "MULTIPLY"
        mix.inputs["Factor"].default_value = 1.0
        mix.inputs[6].default_value = hex_lin(hex_color)
        nt.links.new(attr.outputs["Color"], mix.inputs[7])
        nt.links.new(mix.outputs[2], bsdf.inputs["Base Color"])
    m.diffuse_color = hex_lin(hex_color)
    return m


def metaball_mesh(name, elements, resolution=0.012, threshold=0.6, remesh=0.008, smooth=6, mat=None):
    """elements: list of dicts {type, co, radius, size(xyz for ellipsoid/capsule), rot(euler deg), neg, stiff}.
    `radius` is the VISIBLE radius of a lone element (influence radius = radius / 0.7 at stiffness 2).
    Returns one continuous, voxel-remeshed, smoothed mesh object."""
    mb = bpy.data.metaballs.new(name + "_mb")
    mb.resolution = resolution
    mb.render_resolution = resolution
    mb.threshold = threshold
    for e in elements:
        el = mb.elements.new(type=e.get("type", "BALL"))
        el.co = Vector(e["co"])
        el.radius = e.get("radius", 0.1) / 0.7
        el.stiffness = e.get("stiff", 2.0)
        el.use_negative = e.get("neg", False)
        if "size" in e:
            el.size_x, el.size_y, el.size_z = e["size"]
        if "rot" in e:
            from mathutils import Euler
            el.rotation = Euler([math.radians(a) for a in e["rot"]]).to_quaternion()
    mbo = bpy.data.objects.new(name + "_mb", mb)
    bpy.context.scene.collection.objects.link(mbo)
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(mbo.evaluated_get(dg))
    bpy.data.objects.remove(mbo, do_unlink=True)
    bpy.data.metaballs.remove(mb)
    me.name = name
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    if remesh:
        me.remesh_voxel_size = remesh
        with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob]):
            bpy.ops.object.voxel_remesh()
    if smooth:
        mod = ob.modifiers.new("smooth", "CORRECTIVE_SMOOTH")
        mod.iterations = smooth
        mod.use_only_smooth = True
        apply_modifiers(ob)
    shade_smooth(ob)
    if mat:
        ob.data.materials.append(mat)
    return ob


def apply_modifiers(ob):
    with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob]):
        for m in list(ob.modifiers):
            bpy.ops.object.modifier_apply(modifier=m.name)


def shade_smooth(ob):
    for p in ob.data.polygons:
        p.use_smooth = True


def decimate(ob, ratio):
    mod = ob.modifiers.new("dec", "DECIMATE")
    mod.ratio = ratio
    apply_modifiers(ob)


def tri_count(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def join(objs, name):
    ctx = {"object": objs[0], "active_object": objs[0], "selected_objects": objs, "selected_editable_objects": objs}
    with bpy.context.temp_override(**ctx):
        bpy.ops.object.join()
    objs[0].name = name
    objs[0].data.name = name
    return objs[0]


def empty(name, co, parent=None, size=0.05):
    e = bpy.data.objects.new(name, None)
    e.empty_display_type = "PLAIN_AXES"
    e.empty_display_size = size
    e.location = Vector(co)
    bpy.context.scene.collection.objects.link(e)
    if parent:
        e.parent = parent
    return e


# ---------- QA renders (B-14 mandatory captures) ----------

def _cam(name="QA_Cam"):
    cam = bpy.data.objects.get(name)
    if cam is None:
        cam = bpy.data.objects.new(name, bpy.data.cameras.new(name))
        bpy.context.scene.collection.objects.link(cam)
    bpy.context.scene.camera = cam
    return cam


def _aim(cam, target, direction, dist, ortho_scale=None):
    d = Vector(direction).normalized()
    cam.location = Vector(target) + d * dist
    cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
    if ortho_scale:
        cam.data.type = "ORTHO"
        cam.data.ortho_scale = ortho_scale
    else:
        cam.data.type = "PERSP"
        cam.data.lens = 85


def render_views(prefix, target, views, dist, ortho_scale=None, mode="clay", res=(640, 640), hide=()):
    """mode: clay (Workbench studio, neutral grey), silhouette (flat black on white), material (EEVEE)."""
    sc = bpy.context.scene
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.resolution_percentage = 100
    sc.render.film_transparent = False
    for o in bpy.data.objects:
        o.hide_render = o.name in hide or o.type in {"EMPTY", "ARMATURE"} or o.name.startswith("QA_") and o.type != "CAMERA"
    if mode in ("clay", "silhouette"):
        try:
            sc.render.engine = "BLENDER_WORKBENCH"
        except TypeError:
            pass
        sh = sc.display.shading
        sh.color_type = "SINGLE"
        sh.show_cavity = mode == "clay"
        sh.show_shadows = False
        sh.show_object_outline = False
        if mode == "clay":
            sh.light = "STUDIO"
            sh.single_color = (0.72, 0.72, 0.72)
            sh.background_type = "VIEWPORT"
            sh.background_color = (0.92, 0.93, 0.94)
            sh.cavity_type = "BOTH"
        else:
            sh.light = "FLAT"
            sh.single_color = (0, 0, 0)
            sh.background_type = "VIEWPORT"
            sh.background_color = (1, 1, 1)
        sc.display.render_aa = "16"
    else:
        try:
            sc.render.engine = "BLENDER_EEVEE"
        except TypeError:
            sc.render.engine = "BLENDER_EEVEE_NEXT"
    cam = _cam()
    out = []
    for vname, vdir in views:
        _aim(cam, target, vdir, dist, ortho_scale)
        path = os.path.join(EVIDENCE, f"{prefix}_{vname}.png")
        sc.render.filepath = path
        bpy.ops.render.render(write_still=True)
        out.append(path)
    return out


TURN = [("front", (0, 1, 0.12)), ("right", (1, 0, 0.12)), ("back", (0, -1, 0.12)), ("left", (-1, 0, 0.12)),
        ("three_quarter", (0.75, 0.9, 0.35))]
# Game camera: Godot camera looks down 60 deg from +Z; the model's front (+Y Blender) faces the camera when idle.
GAMECAM = (0.0, 0.5, 0.866)


def export_glb(objs, path, animations=False):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_yup=True,
                              export_apply=True, export_animations=animations, export_vertex_color="ACTIVE",
                              export_all_vertex_colors=False, export_extras=False,
                              export_animation_mode="ACTIONS", export_force_sampling=True)


def section_points(ob, plane_co, plane_no, max_r=1.0, spacing=0.012):
    """Points where `ob`'s surface crosses a plane (within max_r of plane_co), thinned to `spacing`:
    lets trims/bands follow the real garment cross-section instead of an idealised ring."""
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    res = bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=plane_co,
                                 plane_no=plane_no, dist=1e-5)
    pts = [ob.matrix_world @ v.co for v in res["geom_cut"] if isinstance(v, bmesh.types.BMVert)]
    bm.free()
    pts = [p for p in pts if (p - Vector(plane_co)).length <= max_r]
    out = []
    for p in pts:
        if all((p - q).length >= spacing for q in out):
            out.append(p)
    return out


def band_elements(ob, plane_co, plane_no, r, push=0.0, max_r=1.0, spacing=0.012, stiff=2.0):
    """Metaball band hugging `ob` at a plane section, pushed `push` m outward from the section centroid."""
    pts = section_points(ob, Vector(plane_co), Vector(plane_no), max_r, spacing)
    if not pts:
        return []
    c = sum(pts, Vector()) / len(pts)
    return [{"co": tuple(p + (p - c).normalized() * push), "radius": r, "stiff": stiff} for p in pts]


def tile_sheet(paths, out_path, cols):
    """Tiles equally sized PNGs into one sheet (row-major, first path top-left) and deletes the tiles."""
    import numpy as np
    imgs = [bpy.data.images.load(p) for p in paths]
    w, h = imgs[0].size
    rows = math.ceil(len(imgs) / cols)
    sheet = np.ones((rows * h, cols * w, 4), dtype=np.float32)
    for i, im in enumerate(imgs):
        px = np.array(im.pixels[:], dtype=np.float32).reshape(h, w, 4)
        r, c = divmod(i, cols)
        y0 = (rows - 1 - r) * h  # Blender pixel rows start at the bottom
        sheet[y0:y0 + h, c * w:(c + 1) * w] = px
    out = bpy.data.images.new("sheet", cols * w, rows * h, alpha=True)
    out.pixels = sheet.ravel()
    out.filepath_raw = out_path
    out.file_format = "PNG"
    out.save()
    for im in imgs + [out]:
        bpy.data.images.remove(im)
    for p in paths:
        os.remove(p)
    return out_path
