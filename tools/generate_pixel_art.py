#!/usr/bin/env python3
"""Generate cohesive 16/32px pixel art for Alchemist's Path."""

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    import subprocess
    subprocess.check_call(["pip3", "install", "pillow", "-q"])
    from PIL import Image, ImageDraw

OUT = Path(__file__).parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# Fantasy alchemy palette
PAL = {
    "bg_dark": (20, 16, 32),
    "bg_mid": (40, 32, 64),
    "bg_light": (72, 56, 96),
    "gold": (255, 209, 102),
    "gold_dark": (201, 162, 39),
    "teal": (78, 205, 196),
    "teal_dark": (45, 130, 125),
    "coral": (232, 93, 74),
    "coral_dark": (180, 55, 45),
    "blue": (139, 157, 195),
    "blue_dark": (80, 100, 140),
    "purple": (155, 114, 203),
    "white": (240, 235, 255),
    "shadow": (12, 10, 20),
    "moon": (200, 210, 255),
    "green": (106, 190, 120),
}


def px(draw, x, y, c, s=1):
    draw.rectangle([x * s, y * s, (x + 1) * s - 1, (y + 1) * s - 1], fill=c)


def save(img: Image.Image, name: str):
    img.save(OUT / name)
    print(f"  wrote {name}")


def make_icon(size=32):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size // 16
    # Flask shape
    for y in range(4, 14):
        for x in range(6, 10):
            px(d, x, y, PAL["teal"], s)
    for y in range(2, 5):
        for x in range(7, 9):
            px(d, x, y, PAL["gold"], s)
    # Bubble
    px(d, 8, 8, PAL["coral"], s)
    px(d, 7, 9, PAL["gold"], s)
    px(d, 9, 9, PAL["purple"], s)
    return img


def make_spell(name, colors, pattern_fn, size=32):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size // 16
    # Frame
    for x in range(16):
        for y in range(16):
            if x == 0 or y == 0 or x == 15 or y == 15:
                px(d, x, y, PAL["gold_dark"], s)
            elif x == 1 or y == 1 or x == 14 or y == 14:
                px(d, x, y, PAL["bg_light"], s)
    pattern_fn(d, s, colors)
    save(img, f"{name}.png")
    return img


def spell_water(d, s, c):
    for x in range(5, 11):
        px(d, x, 4, c["main"], s)
    for x in range(4, 12):
        px(d, x, 5, c["main"], s)
    for x in range(3, 13):
        for y in range(6, 9):
            px(d, x, y, c["main"], s)
    for x in range(4, 12):
        for y in range(9, 12):
            px(d, x, y, c["dark"], s)
    px(d, 7, 7, PAL["white"], s)


def spell_fire(d, s, c):
    for y in range(10, 14):
        for x in range(6, 10):
            px(d, x, y, c["dark"], s)
    px(d, 7, 3, c["main"], s)
    px(d, 6, 4, c["main"], s)
    px(d, 8, 4, c["main"], s)
    for x in range(5, 11):
        px(d, x, 5, c["main"], s)
    for x in range(4, 12):
        px(d, x, 6, c["main"], s)
    for x in range(5, 11):
        px(d, x, 7, PAL["gold"], s)
    px(d, 7, 8, PAL["gold"], s)


def spell_bloom(d, s, c):
    px(d, 7, 3, c["main"], s)
    px(d, 6, 4, c["main"], s)
    px(d, 8, 4, c["main"], s)
    px(d, 5, 5, c["main"], s)
    px(d, 9, 5, c["main"], s)
    px(d, 7, 5, PAL["gold"], s)
    for y in range(10, 14):
        px(d, 7, y, PAL["green"], s)
    px(d, 6, 11, PAL["green"], s)
    px(d, 8, 11, PAL["green"], s)


def spell_sun(d, s, c):
    px(d, 7, 7, c["main"], s)
    for dx, dy in [(0, -3), (0, 3), (-3, 0), (3, 0), (-2, -2), (2, -2), (-2, 2), (2, 2)]:
        px(d, 7 + dx, 7 + dy, c["main"], s)
    for x in range(5, 11):
        for y in range(5, 11):
            if 5 <= x <= 10 and 5 <= y <= 10:
                px(d, x, y, c["dark"], s)
    px(d, 7, 7, c["main"], s)


def spell_moon(d, s, c):
    for y in range(4, 12):
        for x in range(4, 12):
            if (x - 7) ** 2 + (y - 8) ** 2 <= 16:
                px(d, x, y, c["main"], s)
    for y in range(4, 12):
        for x in range(7, 12):
            if (x - 8) ** 2 + (y - 8) ** 2 <= 12:
                px(d, x, y, PAL["bg_mid"], s)


def make_molecule(name, body_color, bond_color, ring=False, size=48):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size // 16
    cx, cy = 8, 8
    if ring:
        for angle_i in range(6):
            import math
            a = angle_i * math.pi / 3
            x = int(cx + 4 * math.cos(a))
            y = int(cy + 4 * math.sin(a))
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    if dx * dx + dy * dy <= 2:
                        px(d, x + dx - cx + cx, y + dy - cy + cy, body_color, s)
        px(d, cx, cy, bond_color, s)
    else:
        for x in range(4, 12):
            px(d, x, cy, bond_color, s)
        px(d, 5, cy, body_color, s)
        px(d, 8, cy, body_color, s)
        px(d, 11, cy, body_color, s)
        # double bond hint
        if name == "molecule_alkene":
            px(d, 7, cy - 1, PAL["coral"], s)
            px(d, 8, cy - 1, PAL["coral"], s)
        if name == "molecule_alcohol":
            px(d, 11, cy - 1, PAL["teal"], s)
            px(d, 11, cy - 2, PAL["white"], s)
        if name == "molecule_ketone":
            px(d, 8, cy - 1, PAL["gold"], s)
            px(d, 8, cy + 1, PAL["gold"], s)
    save(img, f"{name}.png")


def make_panel(w, h, name):
    img = Image.new("RGBA", (w, h), PAL["bg_dark"])
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], outline=PAL["gold_dark"], width=2)
    d.rectangle([3, 3, w - 4, h - 4], outline=PAL["bg_light"], width=1)
    # Corner gems
    for cx, cy in [(6, 6), (w - 7, 6), (6, h - 7), (w - 7, h - 7)]:
        d.rectangle([cx - 2, cy - 2, cx + 2, cy + 2], fill=PAL["purple"])
    save(img, name)


def make_background(w=320, h=180):
    img = Image.new("RGBA", (w, h), PAL["bg_dark"])
    d = ImageDraw.Draw(img)
    import random
    random.seed(42)
    for _ in range(80):
        x, y = random.randint(0, w - 1), random.randint(0, h - 1)
        c = random.choice([PAL["bg_mid"], PAL["bg_light"], PAL["purple"]])
        d.point((x, y), fill=c)
    # Workbench
    for x in range(0, w):
        for y in range(h - 40, h - 20):
            d.point((x, y), fill=PAL["gold_dark"] if (x // 8 + y) % 2 else PAL["gold"])
    for y in range(h - 20, h):
        for x in range(0, w):
            d.point((x, y), fill=PAL["bg_mid"])
    save(img, "bg_workshop.png")


def make_star(filled=True, size=16):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size // 8
    c = PAL["gold"] if filled else PAL["bg_light"]
    pts = [(4, 0), (5, 3), (8, 3), (5, 5), (6, 8), (4, 6), (2, 8), (3, 5), (0, 3), (3, 3)]
    for x, y in pts:
        px(d, x, y, c, s)
    save(img, "star_filled.png" if filled else "star_empty.png")


def make_arrow(size=32):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size // 16
    for x in range(4, 12):
        px(d, x, 7, PAL["gold"], s)
    for i in range(4):
        px(d, 10 + i, 5 + i, PAL["gold"], s)
        px(d, 10 + i, 9 - i, PAL["gold"], s)
    save(img, "arrow_right.png")


def main():
    print("Generating pixel art...")
    make_icon(128).save(OUT / "icon.png")
    print("  wrote icon.png")

    make_spell("spell_water", {"main": PAL["teal"], "dark": PAL["teal_dark"]}, spell_water)
    make_spell("spell_fire", {"main": PAL["coral"], "dark": PAL["coral_dark"]}, spell_fire)
    make_spell("spell_bloom", {"main": PAL["green"], "dark": PAL["teal_dark"]}, spell_bloom)
    make_spell("spell_sun", {"main": PAL["gold"], "dark": PAL["gold_dark"]}, spell_sun)
    make_spell("spell_moon", {"main": PAL["moon"], "dark": PAL["blue"]}, spell_moon)

    make_molecule("molecule_alkene", PAL["coral"], PAL["blue"])
    make_molecule("molecule_alkane", PAL["blue"], PAL["blue_dark"])
    make_molecule("molecule_alcohol", PAL["teal"], PAL["blue"])
    make_molecule("molecule_ketone", PAL["gold"], PAL["blue"], ring=False)

    make_panel(256, 128, "panel_small.png")
    make_panel(640, 360, "panel_large.png")
    make_background()
    make_star(True)
    make_star(False)
    make_arrow()
    print("Done!")


if __name__ == "__main__":
    main()
