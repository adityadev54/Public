#!/usr/bin/env python3
"""Turn the controlled green ImageGen background into a soft RGBA cutout."""

import sys
from PIL import Image


def main(source: str, destination: str) -> None:
    image = Image.open(source).convert("RGBA")
    output = []

    for red, green, blue, _ in image.getdata():
        other = max(red, blue)
        dominance = green - other

        # The key is deliberately far outside the subject palette. The two
        # ramps retain antialiased hair, fabric, hand, notebook, and pen edges.
        key_strength = min(
            max((dominance - 24.0) / 92.0, 0.0),
            max((green - 105.0) / 120.0, 0.0),
        )
        alpha = round(255.0 * (1.0 - min(key_strength, 1.0)))

        if alpha < 255:
            # Remove the green fringe left in partially transparent pixels.
            green = min(green, round(other * 1.04 + 2.0))

        output.append((red, green, blue, alpha))

    image.putdata(output)
    image.save(destination, optimize=True)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: chroma-to-alpha.py input.png output.png")
    main(sys.argv[1], sys.argv[2])
