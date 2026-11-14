"""Nearest-neighbour crop + upscale of a PNG (no dependencies), for judging game-camera readability at true pixel
size. Usage: python zoom_crop.py in.png out.png x y w h scale"""
import struct
import sys
import zlib


def read_png(path):
    d = open(path, "rb").read()
    i, idat = 8, b""
    while i < len(d):
        n = struct.unpack(">I", d[i:i + 4])[0]
        t, c = d[i + 4:i + 8], d[i + 8:i + 8 + n]
        if t == b"IHDR":
            w, h, _, ct = struct.unpack(">IIBB", c[:10])
        elif t == b"IDAT":
            idat += c
        i += 12 + n
    raw, bpp = zlib.decompress(idat), {2: 3, 6: 4}[ct]
    stride, rows, prev, o = w * bpp, [], bytearray(w * bpp), 0
    for _ in range(h):
        f, line = raw[o], bytearray(raw[o + 1:o + 1 + stride])
        o += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b, c = prev[x], (prev[x - bpp] if x >= bpp else 0)
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(bytes(line[k:k + 3]) for k in range(0, stride, bpp))
        rows[-1] = list(rows[-1])
        prev = line
    return rows


def write_png(path, rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\0" + b"".join(r) for r in rows)
    chunk = lambda t, c: struct.pack(">I", len(c)) + t + c + struct.pack(">I", zlib.crc32(t + c) & 0xffffffff)
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                           + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


if __name__ == "__main__":
    src, dst, x, y, w, h, s = sys.argv[1], sys.argv[2], *map(int, sys.argv[3:8])
    px = read_png(src)
    out = [[px[y + j // s][x + i // s] for i in range(w * s)] for j in range(h * s)]
    write_png(dst, out)
