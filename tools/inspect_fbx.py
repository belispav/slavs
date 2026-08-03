"""
VOLYA - report what is actually inside an FBX, before uploading it anywhere.

Mixamo's auto-rigger is fussy in ways that are invisible until it refuses the
file, and the reasons are all measurable up front: too many polygons, more than
one mesh, or a file bloated by embedded textures. Reading the file is cheaper
than a failed upload and a guess.

    python tools/inspect_fbx.py model.fbx [other.fbx ...]

Parses the binary FBX container directly. No Blender, no FBX SDK.
"""

import os
import struct
import sys
import zlib


HEADER = b"Kaydara FBX Binary  \x00"

# Property type codes that carry arrays, and the struct format of one element.
ARRAY_TYPES = {b"f": "f", b"d": "d", b"l": "q", b"i": "i", b"b": "b"}
SCALAR_TYPES = {b"Y": ("h", 2), b"C": ("?", 1), b"I": ("i", 4),
                b"F": ("f", 4), b"D": ("d", 8), b"L": ("q", 8)}


class Reader:
    def __init__(self, data):
        self.data = data
        self.pos = 0

    def u8(self):
        value = self.data[self.pos]
        self.pos += 1
        return value

    def u32(self):
        value = struct.unpack_from("<I", self.data, self.pos)[0]
        self.pos += 4
        return value

    def u64(self):
        value = struct.unpack_from("<Q", self.data, self.pos)[0]
        self.pos += 8
        return value

    def raw(self, count):
        value = self.data[self.pos:self.pos + count]
        self.pos += count
        return value


def read_property(reader):
    """Returns (type_code, value_or_length). Arrays return their length only -
    the contents are never needed here and can be tens of megabytes."""
    code = reader.raw(1)

    if code in SCALAR_TYPES:
        fmt, size = SCALAR_TYPES[code]
        value = struct.unpack_from("<" + fmt, reader.data, reader.pos)[0]
        reader.pos += size
        return code, value

    if code in ARRAY_TYPES:
        length = reader.u32()
        encoding = reader.u32()
        compressed = reader.u32()
        reader.pos += compressed
        return code, length

    if code in (b"S", b"R"):
        length = reader.u32()
        return code, reader.raw(length)

    raise ValueError("neznamy typ vlastnosti: %r" % code)


def read_node(reader, wide):
    """One node record. Returns None at the null record that ends a list."""
    end = reader.u64() if wide else reader.u32()
    count = reader.u64() if wide else reader.u32()
    reader.u64() if wide else reader.u32()          # property list length
    name_length = reader.u8()

    if end == 0:
        return None

    name = reader.raw(name_length)
    properties = [read_property(reader) for _ in range(count)]

    children = []
    while reader.pos < end:
        child = read_node(reader, wide)
        if child is None:
            break
        children.append(child)
    reader.pos = end
    return {"name": name, "properties": properties, "children": children}


def walk(node, found):
    name = node["name"]
    props = node["properties"]

    if name == b"Vertices" and props:
        found["vertices"].append(props[0][1] // 3)
    elif name == b"PolygonVertexIndex" and props:
        found["indices"].append(props[0][1])
    elif name == b"Geometry":
        found["geometries"] += 1
    elif name == b"Model" and len(props) >= 3:
        kind = props[2][1]
        if kind == b"Mesh":
            found["mesh_models"] += 1
    elif name == b"Content" and props:
        code, value = props[0]
        found["embedded"] += value if isinstance(value, int) else len(value)
    elif name == b"Deformer":
        found["deformers"] += 1
    elif name == b"LayerElementUV":
        found["uv_layers"] += 1
    elif name in (b"Texture", b"Video"):
        found["textures"] += 1

    for child in node["children"]:
        walk(child, found)


def inspect(path):
    with open(path, "rb") as handle:
        data = handle.read()

    if not data.startswith(HEADER):
        print("  nie je to binarny FBX (mozno textovy - otvor a uloz cez Blender)")
        return

    version = struct.unpack_from("<I", data, 23)[0]
    reader = Reader(data)
    reader.pos = 27
    wide = version >= 7500

    found = {"vertices": [], "indices": [], "geometries": 0,
             "mesh_models": 0, "embedded": 0, "deformers": 0,
             "uv_layers": 0, "textures": 0}
    while reader.pos < len(data) - 160:
        node = read_node(reader, wide)
        if node is None:
            break
        walk(node, found)

    vertices = sum(found["vertices"])
    # In an FBX index list the last index of each polygon is stored negative,
    # so counting the negatives counts the polygons without decoding anything.
    polygons = sum(found["indices"])   # upper bound: index entries
    print("  verzia FBX        %d" % version)
    print("  vrcholov          %s" % f"{vertices:,}".replace(",", " "))
    print("  indexov polygonov %s" % f"{polygons:,}".replace(",", " "))
    print("  sieti (Geometry)  %d" % found["geometries"])
    print("  mesh objektov     %d" % found["mesh_models"])
    print("  kostier/skinov    %d" % found["deformers"])
    print("  UV mapy           %d" % found["uv_layers"])
    print("  textury           %d" % found["textures"])
    print("  vlozene textury   %.1f MB" % (found["embedded"] / 1e6))
    print("  velkost suboru    %.1f MB" % (os.path.getsize(path) / 1e6))

    notes = []
    if found["uv_layers"] == 0:
        notes.append("BEZ UV MAPY - na tento model sa nedaju polozit farby. "
                     "Texturu nema kam premietnut a ostane sedy.")
    if found["mesh_models"] > 1 or found["geometries"] > 1:
        notes.append("VIAC SIETI - Mixamo chce jednu. V Blenderi oznac vsetko "
                     "a stlac Ctrl+J.")
    if vertices > 100000:
        notes.append("Velmi vela vrcholov. Ak Mixamo odmietne upload, "
                     "zredukuj to modifikatorom Decimate.")
    if found["embedded"] > 50e6:
        notes.append("Textury zaberaju vacsinu suboru. Na upload ich mozno "
                     "vyhodit - nas render si farby aj tak zmensuje.")
    if not notes:
        notes.append("Ziadny zjavny problem pre auto-rigger.")
    for note in notes:
        print("  -> %s" % note)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__.strip())
    for path in sys.argv[1:]:
        print()
        print("== %s" % os.path.basename(path))
        try:
            inspect(path)
        except Exception as exc:
            print("  necitatelne: %s" % exc)
    print()


if __name__ == "__main__":
    main()
