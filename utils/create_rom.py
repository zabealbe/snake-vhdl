import os
import math
import string
import argparse

import numpy as np

from tqdm import tqdm
from PIL import Image

parser = argparse.ArgumentParser(description="Create rom from image.")
parser.add_argument("path", metavar="PATH", type=str, nargs=1)
parser.add_argument("image", metavar="IMAGE", type=str, nargs=1)

args = parser.parse_args()
path = args.path[0]
name = os.path.splitext(os.path.basename(args.path[0]))[0]
image = args.image[0]


palette = []

sprite_width = 8
sprite_height = 8
pixel_width = 12

for i in range(4096):
    r = ((i >> 8) & 0x0F) * 16
    g = ((i >> 4) & 0x0F) * 16
    b = ((i >> 0) & 0x0F) * 16
    palette.append((r, g, b))

palette = np.array(palette)

im = Image.open(image)
width, height = im.size

pixels = im.load()


def closest(color):
    color = np.array(color)
    distances = np.sqrt(np.sum((palette - color) ** 2, axis=1))
    return np.where(distances == np.amin(distances))[0][0]


with open(os.path.join(os.path.dirname(__file__), "rom.template.vhd"), "r") as f:
    template = string.Template(f.read())

index_space = int(height / sprite_width)
addr_width = index_space * width

rom = [0 for _ in range(index_space)]

for sprite_index in tqdm(range(index_space)):
        sprite = []
        for x in range(0, sprite_width):
            row = []
            for y in range(0, sprite_width):
                r, g, b, _ = pixels[x, sprite_index*sprite_height + y]
                row.append(closest((r, g, b)))
            sprite.append("\n\t\t(" + ", ".join([f'"{index:0{pixel_width}b}"' for index in row]) + ")")
        sprite.reverse()
        sprite = "\n\t(" + ", ".join(sprite) + "\n\t)"
        rom[sprite_index] = f'{sprite}'

im.close()

configuration = {
    "name": name,
    "data_width": pixel_width,
    "tile_count": index_space,
    "tile_width": sprite_width,
    "tile_height": sprite_width,
    "rom": ",".join(rom),
}

with open(path, "w+") as f:
    f.write(template.substitute(configuration))
