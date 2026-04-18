"""
KayKit → Flame sprite sheet renderer
=====================================
Run headless from Terminal:

  /Applications/Blender.app/Contents/MacOS/Blender \
      --background --python render_sprites.py

Output: sprites_out/<name>/frame_00.png … frame_07.png
        sprites_out/<name>/sheet.png  (8×128 horizontal strip)

Adjust FRAME_COUNT, RENDER_SIZE, and the CHARACTERS list below as needed.
"""

import bpy
import os
import sys
import math

# ── Configuration ─────────────────────────────────────────────────

BASE = "/Users/rahul.shah/Documents/Antigravity/Mini Tower Defense"

ANIM_SKEL = BASE + "/KayKit_Skeletons_1.1_FREE/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb"
ANIM_SKEL_GEN = BASE + "/KayKit_Skeletons_1.1_FREE/Animations/gltf/Rig_Medium/Rig_Medium_General.glb"
ANIM_ADV  = BASE + "/KayKit_Adventurers_2.0_FREE/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb"
ANIM_ADV_GEN = BASE + "/KayKit_Adventurers_2.0_FREE/Animations/gltf/Rig_Medium/Rig_Medium_General.glb"

CHARACTERS = [
    # (mesh_glb,                                                   out_name,        anim_glb,     target_action)
    (BASE + "/KayKit_Skeletons_1.1_FREE/characters/gltf/Skeleton_Minion.glb",  "enemy_scout",   ANIM_SKEL,     "Walk"),
    (BASE + "/KayKit_Skeletons_1.1_FREE/characters/gltf/Skeleton_Rogue.glb",   "enemy_swarm",   ANIM_SKEL,     "Walk"),
    (BASE + "/KayKit_Skeletons_1.1_FREE/characters/gltf/Skeleton_Warrior.glb", "enemy_tank",    ANIM_SKEL,     "Walk"),
    (BASE + "/KayKit_Adventurers_2.0_FREE/Characters/gltf/Ranger.glb",         "tower_dart",    ANIM_ADV_GEN,  "Idle"),
    (BASE + "/KayKit_Adventurers_2.0_FREE/Characters/gltf/Barbarian.glb",      "tower_cannon",  ANIM_ADV_GEN,  "Idle"),
    (BASE + "/KayKit_Adventurers_2.0_FREE/Characters/gltf/Mage.glb",           "tower_frost",   ANIM_ADV_GEN,  "Idle"),
    (BASE + "/KayKit_Adventurers_2.0_FREE/Characters/gltf/Knight.glb",         "tower_booster", ANIM_ADV_GEN,  "Idle"),
]

FRAME_COUNT  = 8    # how many frames to sample from the action
RENDER_SIZE  = 128  # px — each frame is square at this resolution
ORTHO_SCALE  = 2.6  # world-unit width of the orthographic view (tune per character)
OUT_DIR      = BASE + "/sprites_out"

# Camera elevation in degrees (45 = good face/body balance)
CAM_ELEVATION_DEG = 45


# ── Helpers ───────────────────────────────────────────────────────

def log(msg):
    print(msg, flush=True)


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.meshes):    bpy.data.meshes.remove(block)
    for block in list(bpy.data.armatures): bpy.data.armatures.remove(block)
    for block in list(bpy.data.actions):   bpy.data.actions.remove(block)
    for block in list(bpy.data.materials): bpy.data.materials.remove(block)
    for block in list(bpy.data.images):    bpy.data.images.remove(block)


def import_glb(path):
    """Import a GLB and return the list of newly added objects."""
    before = set(bpy.data.objects[:])
    bpy.ops.import_scene.gltf(filepath=path)
    return list(set(bpy.data.objects[:]) - before)


def find_armature(objects):
    for obj in objects:
        if obj.type == 'ARMATURE':
            return obj
    return None


def find_action(target_name):
    """Find an action by case-insensitive prefix match."""
    target = target_name.lower()
    # Exact match first
    for action in bpy.data.actions:
        if action.name.lower() == target:
            return action
    # Prefix match
    for action in bpy.data.actions:
        if action.name.lower().startswith(target):
            return action
    # Substring match
    for action in bpy.data.actions:
        if target in action.name.lower():
            return action
    return None


def setup_camera():
    # Target point at character mid-body height (~0.9 units up from ground)
    bpy.ops.object.empty_add(location=(0.0, 0.0, 0.9))
    target = bpy.context.object
    target.name = "CamTarget"

    bpy.ops.object.camera_add()
    cam = bpy.context.object
    cam.data.type = 'ORTHO'
    cam.data.ortho_scale = ORTHO_SCALE

    elev = math.radians(CAM_ELEVATION_DEG)
    dist = 8.0
    cam.location = (0.0, -dist * math.cos(elev), dist * math.sin(elev))

    # Let Blender aim the camera at the target — avoids manual rotation math
    constraint = cam.constraints.new('TRACK_TO')
    constraint.target = target
    constraint.track_axis = 'TRACK_NEGATIVE_Z'
    constraint.up_axis = 'UP_Y'

    bpy.context.scene.camera = cam


def setup_lighting():
    elev = math.radians(50)
    # Key: front-left, slightly above
    bpy.ops.object.light_add(type='SUN', location=(3, -4, 5))
    bpy.context.object.data.energy = 4.0
    bpy.context.object.rotation_euler = (elev, 0, math.radians(30))

    # Fill: right side, softer
    bpy.ops.object.light_add(type='SUN', location=(-3, -2, 3))
    bpy.context.object.data.energy = 1.5

    # Rim: back-top for separation
    bpy.ops.object.light_add(type='SUN', location=(0, 4, 4))
    bpy.context.object.data.energy = 0.8


def configure_render(out_path):
    scene = bpy.context.scene
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 64           # fast but clean for sprites

    scene.render.resolution_x = RENDER_SIZE
    scene.render.resolution_y = RENDER_SIZE
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    scene.render.film_transparent = True  # transparent background

    scene.render.filepath = out_path


def stitch_sheet(frame_paths, out_path):
    """
    Stitch individual frame PNGs into a horizontal sprite sheet
    using Blender's built-in image API (no external deps needed).
    """
    imgs = [bpy.data.images.load(p) for p in frame_paths]
    W = H = RENDER_SIZE
    n = len(imgs)

    # Read all pixels (flat RGBA float list per image)
    all_pixels = []
    for img in imgs:
        pixels = list(img.pixels)  # RGBA floats, row-major bottom-up
        all_pixels.append(pixels)

    # Create output image: n*W wide, H tall
    sheet = bpy.data.images.new("sheet", width=n * W, height=H, alpha=True, float_buffer=False)
    out_pixels = [0.0] * (n * W * H * 4)

    for fi, pixels in enumerate(all_pixels):
        for row in range(H):
            for col in range(W):
                src = (row * W + col) * 4
                # destination column offset in the wide image
                dst = (row * n * W + fi * W + col) * 4
                out_pixels[dst:dst+4] = pixels[src:src+4]

    sheet.pixels = out_pixels
    sheet.filepath_raw = out_path
    sheet.file_format = 'PNG'
    sheet.save()
    log(f"  Sheet saved → {out_path}")


# ── Main render loop ──────────────────────────────────────────────

def render_character(mesh_glb, name, anim_glb, target_action):
    log(f"\n{'='*50}")
    log(f"  Character : {name}")
    log(f"  Mesh      : {os.path.basename(mesh_glb)}")
    log(f"  Animation : {os.path.basename(anim_glb)} → '{target_action}'")

    out_dir = os.path.join(OUT_DIR, name)
    os.makedirs(out_dir, exist_ok=True)

    clear_scene()

    # Import character mesh (static T-pose + armature)
    char_objects = import_glb(mesh_glb)
    char_arm = find_armature(char_objects)
    if not char_arm:
        log(f"  ERROR: No armature found in {mesh_glb} — skipping.")
        return

    # Import animation pack (armature + baked actions, no mesh)
    import_glb(anim_glb)

    # Find the desired action
    action = find_action(target_action)
    if action is None:
        available = [a.name for a in bpy.data.actions]
        log(f"  WARNING: Action '{target_action}' not found.")
        log(f"  Available actions: {available}")
        if available:
            action = bpy.data.actions[0]
            log(f"  Falling back to: {action.name}")
        else:
            log("  ERROR: No actions loaded — skipping character.")
            return

    log(f"  Using action  : {action.name}")

    # Bind action to character armature
    char_arm.animation_data_create()
    char_arm.animation_data.action = action

    frame_start = int(action.frame_range[0])
    frame_end   = int(action.frame_range[1])
    log(f"  Frame range   : {frame_start} – {frame_end}")

    # Scene setup (done once per character after scene is clear)
    setup_camera()
    setup_lighting()

    # Render FRAME_COUNT evenly-spaced frames
    frame_paths = []
    for i in range(FRAME_COUNT):
        t = i / max(FRAME_COUNT - 1, 1)
        frame_num = round(frame_start + t * (frame_end - frame_start))
        bpy.context.scene.frame_set(frame_num)

        out_path = os.path.join(out_dir, f"frame_{i:02d}.png")
        configure_render(out_path)
        bpy.ops.render.render(write_still=True)
        frame_paths.append(out_path)
        log(f"  [{i+1}/{FRAME_COUNT}] timeline={frame_num} → {os.path.basename(out_path)}")

    # Stitch into sprite sheet
    sheet_path = os.path.join(out_dir, "sheet.png")
    stitch_sheet(frame_paths, sheet_path)


def main():
    log("\n" + "="*50)
    log("  KayKit → Flame Sprite Renderer")
    log("  Output: " + OUT_DIR)
    log("="*50)

    for args in CHARACTERS:
        render_character(*args)

    log("\n" + "="*50)
    log("  ALL RENDERS COMPLETE")
    log("="*50)


main()
