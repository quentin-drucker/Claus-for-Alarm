"""Snowball shell + special marker band (P15-T04). One shared shell mesh (packed crust, wavy rolled seam,
vertex-colour AO) tinted per layer in Godot; one shared marker band (seated on the shell, 6 ice studs) with
material variants for Black / White / Purple / Camo. Origin = ball centre (it rolls about it). Run in Blender."""
import random
exec(open(r"C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm\art_src\tools\cc_art.py").read())

clear_scene()
R = 0.38  # visible radius; the Godot outline (grow ~0.02) brings it to the 0.4 m contact radius
random.seed(7)


def seam_dist(p):
    """Signed angular distance (rad) from direction p to the rolled-layer spiral (1.25 turns pole to pole,
    around the X axis = the rolling axis): the edge where the last wrap of packed snow overlaps the ball."""
    lon = math.atan2(p.z, p.y)  # angle around the rolling axis
    lat = math.asin(max(-1.0, min(1.0, p.x)))
    best = 9.0
    for turn in range(-2, 3):
        target = (lon + 2 * math.pi * turn) / (2 * math.pi * 1.25) * 1.2 - 0.1
        if abs(target) < 1.25:
            d = lat - target
            best = d if abs(d) < abs(best) else best
    return best


LUMPS = [Vector((random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1))).normalized() for _ in range(14)]


def shell_mesh(name, subdiv):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=1.0)
    for v in bm.verts:
        d = v.co.normalized()
        r = 1.0
        # packed-snow lumps: broad soft bumps, never a perfect sphere
        r += sum(0.035 * math.exp(-((d - l).length / 0.45) ** 2) for l in LUMPS)
        # flattened "pressed" facets where the ball was packed by hand
        r -= 0.03 * max(0.0, d.dot(Vector((0.3, 0.2, 0.93)).normalized()) - 0.85) / 0.15
        # rolled layer: a raised lip on one side of the spiral edge, a soft crease on the other
        sd = seam_dist(d)
        r += 0.03 / (1 + math.exp(-sd / 0.02)) - 0.03 * math.exp(-(sd / 0.05) ** 2)
        v.co = d * r * R
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    shade_smooth(ob)
    return ob


def bake_ao(ob):
    """Vertex-colour AO: seam groove + crust dirt, so one tint per layer still shows sculpted form in Godot."""
    me = ob.data
    attr = me.color_attributes.new("Col", "BYTE_COLOR", "POINT")
    me.color_attributes.active_color = attr
    for i, v in enumerate(me.vertices):
        d = v.co.normalized()
        groove = math.exp(-(seam_dist(d) / 0.045) ** 2)
        crust = (v.co.length / R - 1.0)  # lumps lighter, dents darker
        g = max(0.0, min(1.0, 0.86 + crust * 2.5 - 0.3 * groove))
        attr.data[i].color = (g, g, g, 1.0)


tint = "powder"
shell_hi = shell_mesh("snowball_shell_hi", 6)
bake_ao(shell_hi)
shell = shell_mesh("snowball_shell", 5)  # 5120 tris -> ~1.4k for 100+ on screen
decimate(shell, 0.28)
bake_ao(shell)
shell_mat = material("M_packed_ice_enemy", PAL[tint], 0.75, use_vcol=True)
for o in (shell_hi, shell):
    o.data.materials.append(shell_mat)

# ---- marker band: a broad seated ring hugging the shell around its rolling plane + 6 short ice spikes ----
band_el = []
for k in range(40):
    a = 2 * math.pi * k / 40
    d = Vector((0.0, math.cos(a), math.sin(a)))
    band_el.append({"type": "ELLIPSOID", "co": tuple(d * R * 0.97), "radius": 0.05, "size": (2.4, 1.0, 1.0)})
for k in range(6):
    a = 2 * math.pi * (k + 0.5) / 6
    d = Vector((0.0, math.cos(a), math.sin(a)))
    band_el += [{"co": tuple(d * R * (1.06 + 0.07 * t)), "radius": 0.05 * (1 - 0.7 * t)} for t in (0, 0.35, 0.7, 1.0)]
marker = metaball_mesh("snowball_marker", band_el, resolution=0.007, remesh=0.007, smooth=4)
# Shell interior hidden: drop faces inside the shell so the band reads as seated, not a floating hoop.
bm = bmesh.new()
bm.from_mesh(marker.data)
bmesh.ops.delete(bm, geom=[f for f in bm.faces if all(v.co.length < R * 0.93 for v in f.verts)], context="FACES")
bm.to_mesh(marker.data)
bm.free()
decimate(marker, min(1.0, 1500 / tri_count(marker)))
VARIANTS = {"black": material("M_marker_black", PAL["black"], 0.3), "white": material("M_marker_white", PAL["white"], 0.4),
            "purple": material("M_marker_purple", PAL["purple"], 0.35, emit=0.6),
            "camo": material("M_marker_camo", "#B8C9C4", 0.9)}
marker.data.materials.append(VARIANTS["purple"])
print("shell tris", tri_count(shell), "marker tris", tri_count(marker))

os.makedirs(os.path.join(PROJ, "art_src", "enemies"), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(PROJ, "art_src", "enemies", "snowball_shells.blend"))
export_glb([shell], os.path.join(PROJ, "assets", "models", "snowball_shell.glb"))
export_glb([marker], os.path.join(PROJ, "assets", "models", "snowball_marker.glb"))
print("exported snowball_shell.glb + snowball_marker.glb")
