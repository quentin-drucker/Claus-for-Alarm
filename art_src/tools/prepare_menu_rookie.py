"""Menu-only static bake of the selected AccuRIG Rookie. Source and gameplay model stay intact."""
from pathlib import Path
import math
import tempfile
import bpy
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(ROOT / 'art_src/models/snowball_rookie/snowball_rookie_rigged.fbx'))
bpy.context.scene.frame_set(0)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
for o in bpy.context.scene.objects:
    o.animation_data_clear()
bpy.ops.object.select_all(action='DESELECT')
for o in meshes:
    o.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
bpy.ops.object.convert(target='MESH')
bpy.ops.object.join()
ob = bpy.context.object
ob.data.transform(ob.matrix_world)
ob.parent = None
ob.matrix_world = Matrix.Identity(4)
verts = [v.co for v in ob.data.vertices]
lo = Vector(tuple(min(v[i] for v in verts) for i in range(3)))
hi = Vector(tuple(max(v[i] for v in verts) for i in range(3)))
center = Vector(((lo.x+hi.x)/2, (lo.y+hi.y)/2, lo.z))
ob.data.transform(Matrix.Scale(2.4/(hi.z-lo.z),4) @ Matrix.Rotation(math.pi,4,'Z') @ Matrix.Translation(-center))
ob.name = 'RemodeledRookieMenu'
for o in list(bpy.context.scene.objects):
    if o != ob:
        bpy.data.objects.remove(o, do_unlink=True)
for mat in ob.data.materials:
    for n in mat.node_tree.nodes:
        if n.type == 'BSDF_PRINCIPLED':
            n.inputs['Roughness'].default_value = .8
            n.inputs['Metallic'].default_value = 0
            for socket in ['Roughness','Metallic']:
                for link in list(n.inputs[socket].links):
                    mat.node_tree.links.remove(link)
tmp = Path(tempfile.mkdtemp(prefix='menu-rookie-maps-'))
for img in bpy.data.images:
    if img.size[0] > 0:
        img.scale(min(img.size[0],1024),min(img.size[1],1024))
        img.filepath_raw = str(tmp / (img.name+'.png'))
        img.file_format = 'PNG'
        img.save()
        if img.packed_file:
            img.unpack(method='REMOVE')
        img.pack()
bpy.context.preferences.filepaths.save_version=0
out=ROOT/'assets/models/menu/rookie_showcase.glb'
out.parent.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art_src/prepared/rookie_menu.blend'))
bpy.ops.export_scene.gltf(filepath=str(out),export_format='GLB',export_animations=False,export_image_format='AUTO',export_yup=True)
print('MENU_ROOKIE',out)
