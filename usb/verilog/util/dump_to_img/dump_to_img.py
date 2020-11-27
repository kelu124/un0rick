'''
Script to generate PNG image from frame dumps generated in simulation.
Main purpose to visualize VGA frames.

python3 dump_to_img.py 640 480 example.mem
'''

import sys
import os
import numpy as np
from PIL import Image


def gen_frame(width, height, path):
    col_w = width // 8
    with open(path, 'w') as f:
        for h in range(height):
            for w in range(width):
                r = 255 if (w // col_w) & 0x1 else 0
                g = 255 if (w // col_w) & 0x2 else 0
                b = 255 if (w // col_w) & 0x4 else 0
                f.write("%02x%02x%02x\n" % (r, g, b))

def open_frame(width, height, path):
    frame = np.empty((height, width, 3), dtype='uint8')
    with open(path, "r") as f:
        for h in range(height):
            for w in range(width):
                pixel = int(f.readline(), base=16)
                frame[h][w][0] = (pixel & 0xFF0000) >> 16 # R
                frame[h][w][1] = (pixel & 0x00FF00) >> 8  # G
                frame[h][w][2] = (pixel & 0x0000FF) >> 0  # B
    return frame

def save_bmp(path, frame):
    im = Image.fromarray(frame)
    im.save(path)

if __name__ == "__main__":
    width = int(sys.argv[1])
    height = int(sys.argv[2])
    frame_path = sys.argv[3]
    bmp_path = os.path.splitext(frame_path)[0] + ".bmp"

    save_bmp(bmp_path, open_frame(width, height, frame_path))
