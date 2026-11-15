"""Blender CLI: prepare lumoize's attributed village without editing the FBX.

blender --background --factory-startup --python art_src/tools/prepare_menu_village.py
Original model and license: see art_src/environment/christmas_village/README.md.
"""
import bpy
import json
from pathlib import Path
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art_src/environment/christmas_village/christmas_low_poly_scene.fbx'
OUT = ROOT / 'assets/models/menu'
DERIVED = ROOT / 'art_src/prepared/christmas_village.blend'


def animated_ancestor(obj):
    while obj:
        if obj.animation_data and obj.animation_data.action:
            return True
        obj = obj.parent
    return False


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=str(SOURCE))
    scene = bpy.context.scene
    scene.frame_set(2)
    meshes = [o for o in scene.objects if o.type == 'MESH']
    tree = bpy.data.objects['Main_Chrimah_Tree']
    tree_bounds = [tree.matrix_world @ Vector(v) for v in tree.bound_box]
    center = Vector(((min(v.x for v in tree_bounds) + max(v.x for v in tree_bounds)) / 2,
                     (min(v.y for v in tree_bounds) + max(v.y for v in tree_bounds)) / 2,
                     min(v.z for v in tree_bounds)))
    # Meshes have offset pivots. Use geometry, not the source object's origin.
    transform = Matrix.Scale(100.0, 4) @ Matrix.Translation(-center)
    normalization = bpy.data.objects.new('VillageOrigin', None)
    scene.collection.objects.link(normalization)
    for obj in list(scene.objects):
        if obj != normalization and obj.parent is None:
            world = obj.matrix_world.copy()
            obj.parent = normalization
            obj.matrix_world = world
    normalization.matrix_world = transform
    bpy.context.view_layer.update()
    # FBX includes a one-frame Ground action; it is static, not ambient motion.
    for obj in meshes:
        if obj.animation_data and obj.animation_data.action:
            action = obj.animation_data.action
            if action.frame_range[1] <= action.frame_range[0]:
                obj.animation_data_clear()
    # Solid-color material palette: matte snow/timber, modest warm emissive bulbs.
    for material in bpy.data.materials:
        if not material.use_nodes:
            continue
        bsdf = next((n for n in material.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None)
        if not bsdf:
            continue
        bsdf.inputs['Roughness'].default_value = 0.82
        bsdf.inputs['Metallic'].default_value = 0.1 if 'Metal' in material.name or material.name == 'Brass' else 0.0
        if any(s in material.name for s in ('Bulb_', 'Window_Light', 'Star_Glowey')):
            bsdf.inputs['Emission Color'].default_value = bsdf.inputs['Base Color'].default_value
            bsdf.inputs['Emission Strength'].default_value = 0.65
    # The source's almost-white cyan washes into snow in the game renderer.
    # Tint only the rink, not the house glass sharing its original phong2 material.
    ice = bpy.data.objects.get('Ice_Sheet')
    if ice and ice.data.materials:
        rink_material = ice.data.materials[0].copy()
        rink_material.name = 'RinkIce'
        ice.data.materials[0] = rink_material
        bsdf = next(n for n in rink_material.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
        bsdf.inputs['Base Color'].default_value = (0.22, 0.55, 0.70, 1.0)
        bsdf.inputs['Roughness'].default_value = 0.55
        bsdf.inputs['Metallic'].default_value = 0.22
    # Collapse only static geometry by material; source smoke/lights keep their hierarchy/actions.
    static = [o for o in meshes if not animated_ancestor(o)]
    vertices, faces, indices, smooth_flags = [], [], [], []
    materials = list(bpy.data.materials)
    material_index = {m: i for i, m in enumerate(materials)}
    for obj in static:
        offset = len(vertices)
        vertices.extend(tuple(obj.matrix_world @ v.co) for v in obj.data.vertices)
        for poly in obj.data.polygons:
            face = tuple(offset + i for i in poly.vertices)
            if obj.matrix_world.determinant() < 0:
                face = tuple(reversed(face))
            faces.append(face)
            mat = obj.data.materials[poly.material_index] if obj.data.materials else None
            indices.append(material_index.get(mat, 0))
            smooth_flags.append(poly.use_smooth)
    mesh = bpy.data.meshes.new('VillageStaticGeometry')
    mesh.from_pydata(vertices, [], faces)
    for mat in materials:
        mesh.materials.append(mat)
    for poly, index, smooth in zip(mesh.polygons, indices, smooth_flags):
        poly.material_index = index
        poly.use_smooth = smooth
    static_obj = bpy.data.objects.new('VillageStatic', mesh)
    scene.collection.objects.link(static_obj)
    for obj in static:
        # Keep parent transforms for animated descendants. Reparenting straight to the
        # normalization root would reinterpret their source animation's local keys.
        if obj.children:
            name = obj.name
            obj.name = name + '_batched'
            anchor = bpy.data.objects.new(name, None)
            scene.collection.objects.link(anchor)
            anchor.parent = obj.parent
            anchor.matrix_parent_inverse = obj.matrix_parent_inverse.copy()
            anchor.matrix_basis = obj.matrix_basis.copy()
            for child in list(obj.children):
                child.parent = anchor
        bpy.data.objects.remove(obj, do_unlink=True)
    # Export the original object animation as one concurrent timeline.
    scene.frame_start = 2
    scene.frame_end = 490
    scene.render.fps = 24
    scene.frame_set(2)
    OUT.mkdir(parents=True, exist_ok=True)
    DERIVED.parent.mkdir(parents=True, exist_ok=True)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(DERIVED))
    bpy.ops.export_scene.gltf(filepath=str(OUT / 'christmas_village.glb'), export_format='GLB',
                              export_yup=True, export_animations=True, export_animation_mode='SCENE',
                              export_anim_scene_split_object=False,
                              export_frame_range=True, export_force_sampling=True,
                              export_cameras=False, export_lights=False)
    report = {'source': str(SOURCE.relative_to(ROOT)), 'source_meshes': len(meshes),
              'batched_static_meshes': len(static), 'runtime_meshes': len([o for o in scene.objects if o.type == 'MESH']),
              'frames': [2, 490], 'fps': 24, 'tree_center_source': list(center), 'scale': 100,
              'author': 'lumoize', 'license': 'CC BY 4.0'}
    (OUT / 'preparation_report.json').write_text(json.dumps(report, indent=2))
    print('MENU_PREPARATION', json.dumps(report))


if __name__ == '__main__':
    main()
