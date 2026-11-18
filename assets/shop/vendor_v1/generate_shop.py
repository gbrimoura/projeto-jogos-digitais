"""Draw native shop sprites using Pillow and the Factory v2 palette."""

import argparse
import json
from pathlib import Path

from PIL import Image, ImageColor, ImageDraw

OUT = Path(__file__).resolve().parent
FACTORY = OUT.parents[1] / "environment/factory_v2"
FRAME = (64, 64)
COUNTER = (104, 32)
SIGN = (48, 32)
MERCHANDISE = (24, 24)


def factory_palette():
    with (FACTORY / "palette-fabrica-v2.json").open(encoding="utf-8") as source:
        palette = json.load(source)
    names = {
        "charcoal": ("ink", "coal", "iron", "panel"),
        "warm_steel": ("steel_dark", "steel", "steel_mid", "steel_light", "cream", "ivory"),
        "rust_copper": ("rust_dark", "rust", "copper_dark", "copper", "copper_light", "peach", "patina", "leather"),
        "amber": ("gold", "amber"),
    }
    return {
        name: ImageColor.getrgb(color)
        for group in palette["groups"]
        for name, color in zip(names[group["name"]], group["colors"], strict=True)
    }


class Pixels:
    def __init__(self, size, colors, offset=(0, 0)):
        self.image = Image.new("RGBA", size)
        self.draw = ImageDraw.Draw(self.image)
        self.colors = colors
        self.offset = offset

    def point(self, x, y):
        return x + self.offset[0], y + self.offset[1]

    def box(self, color, x1, y1, x2, y2):
        self.draw.rectangle((self.point(x1, y1), self.point(x2, y2)), fill=self.colors[color])

    def fill(self, color, *points):
        self.draw.polygon([self.point(*point) for point in points], fill=self.colors[color])

    def line(self, color, *points):
        self.draw.line([self.point(*point) for point in points], fill=self.colors[color])

    def mark(self, x, y, rows, colors):
        for dy, row in enumerate(rows):
            for dx, pixel in enumerate(row):
                if pixel != ".":
                    self.draw.point(self.point(x + dx, y + dy), fill=self.colors[colors[pixel]])


def vendor_pose(colors, pose):
    sprite = Pixels(FRAME, colors, (16, 8))
    box, fill, line = sprite.box, sprite.fill, sprite.line

    # Fixed boots keep feet on absolute row 55.
    fill("ink", (7, 39), (25, 39), (26, 43), (29, 44), (29, 47), (18, 47), (16, 45), (14, 47), (3, 47), (3, 44), (6, 42))
    box("panel", 8, 40, 24, 42)
    fill("steel_dark", (7, 43), (12, 43), (14, 45), (13, 46), (4, 46), (4, 45))
    fill("steel", (20, 43), (25, 43), (28, 45), (28, 46), (19, 46), (18, 45))
    box("gold", 5, 45, 9, 46)
    box("amber", 22, 45, 27, 46)
    line("steel_mid", (21, 43), (24, 43))

    # Rear sleeve, torso and riveted apron.
    fill("ink", (7, 26), (12, 25), (23, 25), (29, 27), (32, 31), (32, 37), (30, 39), (27, 39), (26, 43), (8, 43), (6, 41), (6, 38), (3, 39), (0, 36), (0, 33), (3, 30), (4, 28))
    fill("steel_dark", (7, 27), (23, 26), (28, 28), (27, 36), (25, 41), (9, 42), (7, 39))
    fill("steel_light", (5, 28), (8, 28), (9, 30), (7, 33), (4, 34), (2, 32))
    line("cream", (5, 28), (8, 28), (8, 29))
    fill("steel", (2, 34), (4, 33), (7, 35), (6, 37), (3, 38), (1, 36))
    box("coal", 10, 28, 22, 33)
    box("steel_light", 13, 28, 20, 31)
    box("cream", 14, 28, 20, 29)
    line("steel_mid", (12, 31), (20, 31))
    fill("rust_dark", (9, 27), (12, 27), (13, 33), (21, 33), (21, 27), (24, 27), (24, 33), (26, 37), (25, 42), (9, 42), (8, 38))
    fill("copper", (10, 34), (24, 34), (25, 38), (24, 41), (10, 41), (9, 39))
    line("copper_light", (10, 34), (23, 34), (24, 35))
    box("gold", 10, 32, 11, 33)
    box("amber", 22, 32, 23, 33)
    fill("rust", (13, 36), (22, 36), (22, 38), (20, 40), (15, 40), (13, 38))
    line("peach", (14, 36), (21, 36))
    line("copper_light", (18, 39), (20, 39), (21, 38))

    # The front arm flexes at the shoulder during the blink.
    arm = Pixels(FRAME, colors, (16, 8 + (pose == 2)))
    arm.fill("ink", (25, 27), (29, 27), (32, 30), (32, 34), (34, 36), (33, 39), (30, 40), (27, 38), (26, 35), (23, 33), (23, 29))
    arm.fill("steel_light", (25, 28), (28, 28), (31, 30), (31, 32), (29, 34), (26, 34), (24, 32), (24, 30))
    arm.line("ivory", (25, 29), (26, 28), (28, 28), (30, 30))
    arm.line("steel_mid", (25, 32), (27, 33), (29, 33))
    arm.fill("steel_dark", (29, 34), (31, 34), (33, 36), (32, 38), (30, 39), (28, 37))
    arm.line("steel_mid", (29, 36), (30, 35), (31, 35), (32, 36))
    sprite.image.alpha_composite(arm.image)

    # Antenna, inset lens and brass caps.
    shift_x, shift_y = ((0, 0), (0, -1), (1, 0), (0, 1))[pose]
    head = Pixels(FRAME, colors, (16 + shift_x, 8 + shift_y))
    box, fill, line = head.box, head.fill, head.line
    fill("ink", (13, 11), (12, 7), (9, 5), (9, 3), (11, 1), (18, 1), (18, 0), (23, 0), (24, 2), (23, 4), (18, 4), (18, 3), (13, 3), (12, 4), (15, 6), (16, 10))
    line("copper", (14, 9), (14, 7), (11, 4), (12, 2), (18, 2))
    box("gold", 19, 1, 22, 3)
    line("amber", (20, 1), (22, 1), (22, 2))
    fill("ink", (9, 10), (13, 8), (22, 8), (27, 10), (30, 13), (31, 16), (33, 17), (34, 19), (34, 24), (32, 26), (29, 26), (25, 28), (12, 28), (8, 26), (5, 26), (3, 24), (3, 17), (5, 15), (7, 15), (7, 13))
    fill("steel_mid", (9, 13), (13, 10), (22, 9), (26, 11), (29, 14), (30, 21), (28, 25), (24, 27), (13, 27), (9, 25), (7, 22), (7, 17))
    fill("cream", (13, 11), (22, 10), (26, 12), (28, 15), (29, 21), (27, 24), (23, 26), (15, 26), (12, 24), (10, 21), (10, 16))
    fill("steel_light", (10, 17), (12, 15), (12, 20), (15, 24), (22, 25), (25, 24), (23, 26), (15, 26), (12, 24), (10, 21))
    line("ivory", (14, 12), (17, 11), (22, 11), (25, 13))
    line("steel_dark", (9, 15), (12, 15))
    line("steel", (9, 22), (11, 22))
    box("steel_dark", 4, 17, 7, 24)
    box("gold", 4, 18, 5, 23)
    box("amber", 4, 18, 4, 21)
    box("copper_dark", 31, 18, 32, 24)
    box("gold", 32, 19, 33, 23)
    box("amber", 33, 19, 33, 21)
    fill("ink", (16, 14), (22, 13), (25, 15), (27, 18), (27, 21), (24, 24), (17, 24), (14, 22), (13, 19), (14, 16))
    fill("iron", (17, 15), (22, 14), (25, 16), (26, 19), (25, 22), (23, 23), (18, 23), (15, 21), (15, 17))
    if pose == 2:
        line("gold", (17, 20), (19, 18), (22, 18), (24, 20))
        box("amber", 20, 18, 22, 18)
    else:
        eye = (0, 1, 0, -1)[pose]
        fill("copper_dark", (18 + eye, 17), (22 + eye, 16), (24 + eye, 18), (23 + eye, 21), (21 + eye, 22), (18 + eye, 21))
        box("gold", 19 + eye, 17, 22 + eye, 20)
        box("amber", 20 + eye, 17, 22 + eye, 19)
        box("ivory", 22 + eye, 16, 23 + eye, 17)
    sprite.image.alpha_composite(head.image)
    return sprite.image


def vendor_atlas(colors):
    atlas = Image.new("RGBA", (FRAME[0] * 4, FRAME[1]))
    for pose in range(4):
        atlas.paste(vendor_pose(colors, pose), (FRAME[0] * pose, 0))
    return atlas


def rivet(pixels, x, y, highlight="steel_mid"):
    pixels.fill("coal", (x, y - 1), (x + 1, y), (x + 1, y + 1), (x - 1, y + 1), (x - 1, y))
    pixels.box(highlight, x, y - 1, x, y)


def counter(colors):
    sprite = Pixels(COUNTER, colors)
    box, fill, line = sprite.box, sprite.fill, sprite.line

    # Feet and recessed cabinet fronts.
    fill("ink", (6, 10), (97, 10), (99, 23), (97, 29), (93, 29), (93, 31), (84, 31), (82, 28), (21, 28), (19, 31), (10, 31), (10, 29), (6, 29), (4, 24))
    box("steel_dark", 11, 28, 18, 30)
    box("steel_dark", 85, 28, 92, 30)
    box("panel", 8, 11, 95, 24)
    for x, width in ((12, 23), (39, 26), (69, 23)):
        box("coal", x, 12, x + width - 1, 23)
        box("iron", x + 1, 13, x + width - 2, 22)
        line("steel_dark", (x + 1, 13), (x + width - 2, 13))
        line("panel", (x + 2, 16), (x + width - 3, 16))
        box("coal", x + width // 2 - 2, 14, x + width // 2 + 2, 15)
        box("steel", x + width // 2 - 1, 14, x + width // 2 + 1, 14)
    for x in (9, 36, 66, 93):
        box("steel_dark", x, 11, x + 2, 24)
        line("steel", (x + 2, 11), (x + 2, 23))
        rivet(sprite, x + 1, 13)
        rivet(sprite, x + 1, 21)
    sprite.mark(15, 16, ("r.....", "rr....", ".rr...", "..r...", "..rr..", "...r.."), {"r": "rust"})
    sprite.mark(55, 18, ("...r", "..rr", ".rr.", "rr..", ".r.."), {"r": "rust"})
    sprite.mark(78, 16, (".rr...", "..r...", "..rr..", "...rr.", "...r.."), {"r": "rust"})

    # One copper return pipe runs around the chassis, behind its straps.
    fill("ink", (3, 9), (10, 9), (10, 22), (13, 24), (90, 24), (94, 21), (94, 9), (100, 9), (100, 24), (98, 28), (94, 30), (9, 30), (5, 28), (3, 25))
    fill("copper_dark", (4, 10), (9, 10), (9, 23), (13, 25), (91, 25), (95, 22), (95, 10), (99, 10), (99, 24), (97, 27), (93, 29), (10, 29), (6, 27), (4, 25))
    line("copper", (7, 11), (7, 24), (9, 26), (13, 27), (92, 27), (96, 25), (97, 23), (97, 11))
    line("peach", (7, 15), (7, 23), (9, 25), (12, 26), (92, 26), (95, 24), (96, 22), (96, 14))
    for x in (14, 86):
        box("ink", x, 24, x + 4, 30)
        box("steel_dark", x + 1, 25, x + 3, 29)
        line("steel_mid", (x + 3, 25), (x + 3, 27))
    for x in (3, 94):
        box("ink", x, 20, x + 6, 22)
        box("steel", x + 1, 21, x + 5, 21)

    # A continuous beveled work surface masks the pipe starts.
    fill("ink", (6, 5), (97, 5), (103, 8), (103, 12), (101, 14), (2, 14), (0, 12), (0, 8))
    fill("steel_mid", (7, 6), (97, 6), (101, 8), (101, 10), (2, 10), (2, 8))
    line("steel_light", (8, 6), (96, 6))
    box("steel_dark", 2, 10, 101, 12)
    line("steel", (2, 10), (101, 10))
    line("cream", (4, 8), (100, 8))
    for x in (5, 17, 29, 42, 55, 67, 80, 93, 99):
        rivet(sprite, x, 11)
    for x in (23, 48, 74):
        line("steel", (x, 6), (x - 1, 7))
        line("coal", (x - 1, 10), (x - 1, 13))
    return sprite.image


def gear(pixels, x, y, body, hole):
    pixels.mark(x, y, (
        "...ggg...",
        ".g.ggg.g.",
        ".ggggggg.",
        "ggg...ggg",
        "ggg...ggg",
        "ggg...ggg",
        ".ggggggg.",
        ".g.ggg.g.",
        "...ggg...",
    ), {"g": body})
    pixels.box(hole, x + 3, y + 3, x + 5, y + 5)


def sign(colors):
    sprite = Pixels(SIGN, colors)
    box, fill, line = sprite.box, sprite.fill, sprite.line
    # Bolted bracket, beam and two chain links.
    fill("ink", (1, 1), (2, 0), (6, 0), (7, 1), (7, 4), (43, 4), (45, 6), (45, 9), (43, 11), (12, 11), (7, 17), (7, 21), (1, 21), (0, 20), (0, 2))
    box("panel", 1, 2, 5, 19)
    line("steel", (2, 1), (5, 1), (5, 19))
    fill("steel_dark", (7, 10), (10, 10), (10, 12), (7, 15))
    box("copper_dark", 7, 6, 43, 9)
    line("patina", (7, 6), (42, 6))
    line("copper", (7, 8), (42, 8))
    for y in (4, 17):
        rivet(sprite, 3, y, "steel_light")
    for x in (14, 39):
        box("ink", x, 3, x + 4, 18)
        box("steel_dark", x + 1, 4, x + 3, 10)
        line("steel_light", (x + 1, 4), (x + 3, 4), (x + 3, 5))
        line("patina", (x + 2, 11), (x + 2, 16))
        line("panel", (x + 2, 12), (x + 2, 13))

    # The gear icon and three short enamel marks identify the stall.
    fill("ink", (13, 15), (43, 15), (47, 19), (47, 27), (43, 31), (13, 31), (9, 27), (9, 19))
    fill("steel", (13, 16), (43, 16), (46, 19), (46, 27), (43, 30), (13, 30), (10, 27), (10, 19))
    fill("panel", (14, 17), (42, 17), (45, 20), (45, 26), (42, 29), (14, 29), (11, 26), (11, 20))
    line("steel_light", (13, 17), (14, 16), (42, 16), (45, 19))
    line("steel_dark", (11, 27), (14, 30), (42, 30), (45, 27))
    for x in (14, 42):
        for y in (20, 27):
            rivet(sprite, x, y, "steel_light")
    gear(sprite, 24, 18, "amber", "panel")
    for x in (18, 28, 38):
        line("gold", (x, 28), (x + 2, 28))
    return sprite.image


def merchandise(colors):
    atlas = Image.new("RGBA", (MERCHANDISE[0] * 3, MERCHANDISE[1]))
    for column, draw_item in enumerate((toolbox, cell, parts)):
        sprite = Pixels(MERCHANDISE, colors)
        sprite.fill("ink", (4, 18), (19, 18), (21, 20), (21, 23), (2, 23), (2, 20))
        sprite.fill("steel_mid", (4, 19), (19, 19), (20, 20), (20, 22), (3, 22), (3, 20))
        sprite.box("steel_dark", 4, 21, 19, 22)
        sprite.line("steel_light", (4, 19), (19, 19))
        for x in (10, 14):
            sprite.fill("amber", (x, 21), (x + 1, 21), (x, 22), (x - 1, 22))
        draw_item(sprite)
        atlas.paste(sprite.image, (MERCHANDISE[0] * column, 0))
    return atlas


def toolbox(sprite):
    box, fill, line = sprite.box, sprite.fill, sprite.line
    fill("ink", (8, 8), (9, 6), (16, 6), (17, 8), (17, 11), (20, 11), (22, 13), (22, 17), (20, 19), (3, 19), (2, 17), (2, 12), (4, 10), (8, 10))
    fill("copper", (9, 8), (10, 7), (15, 7), (16, 8), (16, 10), (9, 10))
    box("coal", 10, 9, 15, 10)
    box("copper_dark", 3, 13, 20, 17)
    box("steel_dark", 4, 15, 19, 18)
    box("copper", 4, 11, 19, 13)
    line("peach", (5, 11), (19, 11))
    line("copper_light", (18, 12), (21, 12), (21, 13))
    for x in (6, 17):
        box("cream", x, 12, x + 1, 14)
        box("steel_mid", x, 15, x + 1, 15)
    sprite.mark(10, 14, ("...ii", "..ii.", ".ii..", "ii...", "i...."), {"i": "ivory"})


def cell(sprite):
    box, fill, line = sprite.box, sprite.fill, sprite.line
    fill("ink", (9, 1), (14, 1), (19, 4), (21, 8), (21, 13), (18, 17), (17, 19), (6, 19), (5, 16), (3, 13), (3, 7), (5, 4))
    fill("steel_mid", (9, 2), (14, 2), (18, 4), (20, 8), (20, 13), (17, 16), (16, 18), (7, 18), (6, 16), (4, 13), (4, 7), (6, 4))
    fill("cream", (10, 2), (14, 2), (16, 4), (15, 6), (8, 6), (7, 4))
    fill("steel_light", (16, 5), (18, 5), (20, 8), (20, 10), (17, 10), (16, 8), (15, 7))
    fill("steel_light", (6, 5), (8, 7), (7, 10), (4, 10), (4, 7))
    fill("leather", (5, 12), (8, 12), (10, 15), (8, 17), (5, 15))
    fill("copper", (17, 12), (20, 12), (19, 14), (17, 16), (15, 16), (14, 14))
    fill("ink", (10, 6), (14, 6), (17, 9), (17, 12), (14, 15), (10, 15), (7, 12), (7, 9))
    fill("copper_dark", (10, 7), (14, 7), (16, 9), (16, 12), (14, 14), (10, 14), (8, 12), (8, 9))
    fill("amber", (11, 8), (13, 8), (15, 10), (14, 12), (13, 13), (10, 12), (9, 10))
    line("ivory", (11, 8), (13, 8), (14, 9))
    box("steel", 9, 16, 14, 17)


def parts(sprite):
    box, fill, line = sprite.box, sprite.fill, sprite.line
    fill("ink", (3, 17), (3, 12), (6, 9), (8, 4), (10, 3), (16, 6), (17, 9), (21, 11), (22, 14), (21, 17), (22, 18), (20, 19), (2, 19))
    fill("steel_dark", (9, 5), (11, 5), (14, 6), (15, 7), (13, 13), (8, 13), (6, 11))
    line("cream", (8, 7), (9, 5), (11, 5), (13, 6))
    fill("copper", (15, 9), (19, 10), (21, 12), (20, 14), (15, 15), (13, 13))
    line("peach", (15, 10), (18, 10), (20, 11))
    gear(sprite, 4, 10, "steel_light", "coal")
    line("ivory", (7, 10), (9, 10))
    box("ink", 13, 15, 21, 18)
    for x in (14, 16, 18, 20):
        box("leather", x, 15, x, 17)
        box("cream", x, 15, x, 16)


def preview(colors, assets):
    width, height = 256, 146
    composition = Pixels((width, height), colors)
    composition.box("ink", 0, 0, width - 1, height - 1)
    composition.box("coal", 2, 2, width - 3, 79)
    composition.box("iron", 2, 74, width - 3, 79)
    composition.line("steel_dark", (2, 74), (width - 3, 74))
    for column in range(4):
        x = column * FRAME[0]
        composition.box("coal", x + 2, 82, x + FRAME[0] - 3, height - 3)
        frame = assets["vendor-idle"].crop((x, 0, x + FRAME[0], FRAME[1]))
        composition.image.alpha_composite(frame, (x, 81))

    composition.image.alpha_composite(assets["shop-sign"], (36, 14))
    composition.image.alpha_composite(assets["vendor-idle"].crop((0, 0, *FRAME)), (94, 2))
    composition.image.alpha_composite(assets["shop-counter"], (81, 43))
    atlas = assets["shop-merchandise"]
    for column, x in enumerate((85, 144, 163)):
        left = column * MERCHANDISE[0]
        item = atlas.crop((left, 0, left + MERCHANDISE[0], MERCHANDISE[1]))
        composition.image.alpha_composite(item, (x, 26))
    return composition.image.resize((width * 4, height * 4), Image.Resampling.NEAREST)


def verify(image, colors):
    allowed = {(*rgb, 255) for rgb in colors.values()} | {(0, 0, 0, 0)}
    used = {pixel for _, pixel in image.getcolors(image.width * image.height)}
    invalid = used - allowed
    if invalid:
        raise ValueError(f"Pixels outside Factory v2 palette or binary alpha: {invalid}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--asset", choices=("vendor-idle", "shop-counter", "shop-sign", "shop-merchandise"))
    args = parser.parse_args()
    generators = {
        "vendor-idle": vendor_atlas,
        "shop-counter": counter,
        "shop-sign": sign,
        "shop-merchandise": merchandise,
    }
    assets = {}
    for name, generate in generators.items():
        if args.asset and name != args.asset:
            continue
        colors = factory_palette()
        image = generate(colors)
        verify(image, colors)
        image.save(OUT / f"{name}.png")
        assets[name] = image
    if not args.asset:
        image = preview(colors, assets)
        verify(image, colors)
        image.save(OUT / "shop-preview.png")


if __name__ == "__main__":
    main()
