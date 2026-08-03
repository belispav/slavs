"""
VOLYA - pull the colour texture out of a GLB.

Meshy hands back a rigless GLB that carries the texture, and Mixamo hands back
a rigged FBX that does not. Both are the same mesh with the same UV layout, so
the texture from one can simply be put on the other - which is cheaper than
paying to generate the character again just to get a textured FBX.

    python tools/extract_glb_texture.py model.glb

Writes <name>_basecolor.png next to it, and reports the other maps it found
without extracting them: at 96 pixels the normal and roughness maps have
nothing to contribute.
"""

import json
import os
import struct
import sys

CHUNK_JSON = 0x4E4F534A
CHUNK_BIN = 0x004E4942

# The one map that matters here. A normal map adds surface relief and a
# roughness map adds specular variation; neither survives a 96 pixel sprite
# with three bands of flat colour.
WANTED = ("base_color", "basecolor", "diffuse", "albedo")


def read_glb(path):
    with open(path, "rb") as handle:
        data = handle.read()
    magic, version, length = struct.unpack_from("<III", data, 0)
    if magic != 0x46546C67:
        raise RuntimeError("nie je to GLB subor")

    gltf = None
    binary = b""
    offset = 12
    while offset < length:
        chunk_length, chunk_type = struct.unpack_from("<II", data, offset)
        start = offset + 8
        if chunk_type == CHUNK_JSON:
            gltf = json.loads(data[start:start + chunk_length])
        elif chunk_type == CHUNK_BIN:
            binary = data[start:start + chunk_length]
        offset = start + chunk_length
    if gltf is None:
        raise RuntimeError("v GLB nie je JSON cast")
    return gltf, binary


def image_bytes(gltf, binary, image):
    """An embedded image lives in the binary chunk, addressed by a buffer view."""
    index = image.get("bufferView")
    if index is None:
        raise RuntimeError("obrazok nie je vlozeny v subore")
    view = gltf["bufferViews"][index]
    start = view.get("byteOffset", 0)
    return binary[start:start + view["byteLength"]]


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())
    path = sys.argv[1]
    gltf, binary = read_glb(path)

    images = gltf.get("images", [])
    if not images:
        sys.exit("VOLYA: GLB neobsahuje ziadnu texturu.")

    chosen = None
    for index, image in enumerate(images):
        name = (image.get("name") or "").lower()
        mark = " "
        if chosen is None and any(w in name for w in WANTED):
            chosen = (index, image)
            mark = ">"
        print("VOLYA: %s obrazok %d  %-22s %s"
              % (mark, index, image.get("name") or "?",
                 image.get("mimeType") or ""))
    if chosen is None:
        chosen = (0, images[0])
        print("VOLYA: nazov farebnej mapy som nerozpoznal, beriem prvu")

    index, image = chosen
    payload = image_bytes(gltf, binary, image)
    extension = ".jpg" if "jpeg" in (image.get("mimeType") or "") else ".png"
    out = os.path.splitext(path)[0] + "_basecolor" + extension
    with open(out, "wb") as handle:
        handle.write(payload)
    print("VOLYA: ulozene %s (%.1f MB)" % (out, len(payload) / 1e6))
    print("VOLYA: pouzi to pri renderi:  --texture \"%s\"" % out)


if __name__ == "__main__":
    main()
