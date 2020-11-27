'''
Generate some VGA related artifacts:
  - sprites
  - BRAM initial values
'''

import os
import glob
import json
import numpy as np
import random
from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw


def gen_acq_env(env_len):
    ''' Generate acquisition envelope and gain values'''
    # Open data json
    with open('32_lines.json') as f:
        raw_acq_data = json.load(f)
        gain = raw_acq_data['gain']
        acq = [w & 0x3FF for w in raw_acq_data['0']]
    # Expand gain values
    gain_exp = [gain[x // (env_len // 32)] for x in range(env_len)]

    # Calculate envelope
    acq_env = []
    prep_acq = [w - 512 for w in acq]
    env_chunk_w = len(prep_acq) // env_len
    chunk_max = 0
    for i, sample in enumerate(prep_acq):
        if ((i + 1) % 32) == 0:
            acq_env += [chunk_max]
            chunk_max = 0
        if sample > chunk_max:
            chunk_max = sample
    
    return acq_env, gain_exp, acq

def gen_env_bmp(acq_env, width=512, height=256):
    '''Generate envelope bitmap'''
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for w in range(width):
        for h in range(height):
            if ((height - h - 1) <= acq_env[w] // 2):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/g_env.bmp')

def gen_gain_bmp(gain, width=512, height=256):
    '''Generate gain bitmap'''
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for w in range(width):
        for h in range(height):
            if ((height - h - 1) <= gain[w] // 4):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/g_gain.bmp')

def gen_env_axis_bmp(width=512, height=5):
    '''Generate envelope X axis bitmap'''
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for h in range(height):
        for w in range(width):
            if (h == 0):
                frame[h][w] = [0xFF, 0xFF, 0x00]
            elif ((w - 2) % 100 == 0):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/g_env_x_axis.bmp')

def gen_topturn_bmp(topturn, num, width=256, height=128):
    '''Generate topturn bitmap'''   
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for w in range(width):
        for h in range(height):
            if ((height - h - 1) < topturn[w] * height // 2):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/g_topturn%d.bmp' % num)

def gen_topturn_axis_bmp(width=256, height=5):
    '''Generate topturn X axis bitmap'''
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for h in range(height):
        for w in range(width):
            if (h == 0):
                frame[h][w] = [0xFF, 0xFF, 0x00]
            elif ((w - 2) % 50 == 0):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/g_topturn_x_axis.bmp')

def text_to_pixels(text, font_path='/usr/share/fonts/liberation/LiberationMono-Regular.ttf', font_size=12):
    '''Based on https://stackoverflow.com/a/27753869/190597 (jsheperd)'''
    font = ImageFont.truetype(font_path, font_size) 
    w, h = font.getsize(text)  
    h *= 2
    image = Image.new('L', (w, h), 1)  
    draw = ImageDraw.Draw(image)
    draw.text((0, 0), text, font=font) 
    arr = np.asarray(image)
    arr = np.where(arr, 0, 1)
    arr = arr[(arr != 0).any(axis=1)]
    return arr

def pixels_to_bmp(text, prefix='t_'):
    text_px = text_to_pixels(text)
    print(text, text_px.shape)
    height = text_px.shape[0]
    width = text_px.shape[1]
    frame = np.zeros((height, width, 3), dtype=np.uint8)
    for w in range(width):
        for h in range(height):
            if (text_px[h][w]):
                frame[h][w] = [0xFF, 0xFF, 0x00]
    im = Image.fromarray(frame)
    im.save('img/%s%s.bmp' % (prefix, text.replace(" ", "_")))

def gen_labels_bmp():
    labels = ["INITDEL = 0x",
              "PONW    = 0x",
              "POFFW   = 0x",
              "INTERW  = 0x",
              "TOPTURN1",
              "TOPTURN2",
              "TOPTURN3",
              "0",
              "50",
              "100",
              "150",
              "200",
              "250",
              "DACGAIN",
              "ACQUISITION",
              "INFORMATION"]
    for l in labels:
        pixels_to_bmp(l)

def gen_hex_ch_bmp():
    hex_ch = "0123456789ABCDEF"
    for c in hex_ch:
        pixels_to_bmp(c, "h_")

def rle_encoder(vector, width=16):
    ''' RLE binary encoder
    
    Format:
      - 15 bit - word type: raw bits (0) or length-encoded (1)
      if 15 bit = 0 (raw bits): 14 ... 0 bits is original data bits
      else if length-encoded (1):
      - 14 bit - repeated bit
      - 13 ... 0 bits - number of repeats (0 - 1 repeat, 1 - 2 repeats, etc)
    '''
    type_pos = width - 1
    repeated_bit_pos = width - 2
    raw_max = width - 1
    raw_mask = ((2 ** width) - 1) >> 1
    len_max = 2 ** (width - 2)
    len_mask = len_max - 1

    # Encode bit by bit
    encoded = []
    type_len = 0 # Word type: raw bits or length-encoded
    repeated_bit = 0 # Repeated bit for length-encoded
    bit_cnt = 0
    bit_hist = 0
    for b in vector:
        bit_hist = (bit_hist >> 1) | (b << repeated_bit_pos)
        bit_cnt += 1

        if (not type_len):
            if (bit_cnt == raw_max):

                if ((bit_hist == raw_mask) or (bit_hist == 0)): # all ones or all zeros
                    repeated_bit = bit_hist & 0x1
                    type_len = 1
                else:
                    encoded += [bit_hist & raw_mask]
                    bit_cnt = 0
        else:
            if (bit_cnt == len_max):
                encoded += [(type_len << type_pos) | (repeated_bit << repeated_bit_pos) | ((bit_cnt - 1) & len_mask)]
                type_len = 0
                bit_cnt = 0
            elif (b != repeated_bit):
                encoded += [(type_len << type_pos) | (repeated_bit << repeated_bit_pos) | ((bit_cnt - 2) & len_mask)]
                type_len = 0
                bit_cnt = 1
    else:
        if (not type_len):
            bit_hist = bit_hist >> (width - bit_cnt)
            encoded += [bit_hist & raw_mask]
        else:
            encoded += [(type_len << type_pos) | (repeated_bit << repeated_bit_pos) | ((bit_cnt - 1) & len_mask)]
    
    return np.array(encoded, dtype='uint%d' % width)

def rle_decoder(vector, width=16):
    ''' RLE binary decoder'''
    type_pos = width - 1
    repeated_bit_pos = width - 2
    raw_max = width - 1
    len_max = 2 ** (width - 2)
    len_mask = len_max - 1

    # Decode word by word
    decoded = []
    for w in vector:
        type_len = (w >> type_pos) & 0x1

        if (type_len == 0):
            decoded += [(w >> i) & 0x1 for i in range(raw_max)]
        else:
            repeated_bit = (w >> repeated_bit_pos) & 0x1
            repeats = 1 + (w & len_mask)
            decoded += [repeated_bit for _ in range(repeats)]
    
    return np.array(decoded, dtype='uint8')

def get_static_pixels():
    layout_orig = np.array(Image.open('layout_dynamic.bmp'))
    print(layout_orig.shape)

    static_mask = np.array([0xFF, 0xFF, 0x00] * 600 * 800).reshape(600, 800, 3)
    dynamic_mask = np.array([0xFF, 0x00, 0x00] * 600 * 800).reshape(600, 800, 3)

    static_vector = (layout_orig == static_mask).all(axis=2).view('uint8').flatten()
    dynamic_vector = (layout_orig == dynamic_mask).all(axis=2).view('uint8').flatten() * 2
    # 0 - black (background),  1 - yellow (static), 2 - red (dynamic)
    layout_vector = static_vector + dynamic_vector

    # remove all dynamic pixels
    static_pixels = layout_vector[layout_vector < 2]
    return static_pixels

def get_hex_ch_pixels():
    hex_ch = "0123456789ABCDEF"
    hex_ch_pixels = np.array([], dtype='uint8')
    for c in hex_ch:
        ch_px = text_to_pixels(c)
        if ch_px.shape[1] != 8: 
            ch_px = np.append(np.zeros((8, 8 - ch_px.shape[1]), 'uint8'), ch_px, axis=1)
        ch_px_compressed = np.zeros(8, 'uint8')
        for i in range(8):
            ch_px_compressed[i] = int("%d%d%d%d%d%d%d%d" % tuple(reversed(ch_px[i])), base=2)
        hex_ch_pixels = np.append(hex_ch_pixels, ch_px_compressed)
    return hex_ch_pixels

def gen_mem_24(data, name):
    print(name, data.shape[0], "24-bit words")
    with open('mem/%s.mem' % name, 'w') as f:
        for w in data:
            f.write("%05x\n" % w)

def gen_mem_16(data, name):
    print(name, data.shape[0], "16-bit words")
    with open('mem/%s.mem' % name, 'w') as f:
        for w in data:
            f.write("%04x\n" % w)

def gen_mem_12(data, name):
    print(name, data.shape[0], "12-bit words")
    with open('mem/%s.mem' % name, 'w') as f:
        for w in data:
            f.write("%03x\n" % w)

def gen_mem_8(data, name):
    print(name, data.shape[0], "8-bit words")
    with open('mem/%s.mem' % name, 'w') as f:
        for w in data:
            f.write("%02x\n" % w)

def gen_mem_1(data, name):
    print(name, data.shape[0], "1-bit words")
    with open('mem/%s.mem' % name, 'w') as f:
        for w in data:
            f.write("%01d\n" % w)

def gen_acq_plot_data(env, gain, topturn1, topturn2, topturn3):
    topturn_merged = [(topturn3[i] << 2) | (topturn2[i] << 1) | (topturn1[i] << 0) for i in range(len(topturn1))]
    topturn_expanded = [topturn_merged[i//2] for i in range(len(topturn_merged)*2)]
    return [(topturn_expanded[i] << 16) | (gain[i]//4 << 8) | (env[i]//2 << 0) for i in range(len(env))]

def get_dynamic_areas():
    layout = np.array(Image.open('layout_dynamic.bmp'))
    width = layout.shape[1]
    height = layout.shape[0]
    dynamic_mask = np.array([0xFF, 0x00, 0x00] * height * width).reshape(height, width, 3)
    layout_dynamic = np.pad((layout == dynamic_mask).all(axis=2).view('uint8'), 1, mode='constant')
    left_up_corner = np.array([0, 0, 0, 1]).reshape(2, 2)
    right_up_corner = np.array([0, 0, 1, 0]).reshape(2, 2)
    left_down_corner = np.array([0, 1, 0, 0]).reshape(2, 2)
    right_down_corner = np.array([1, 0, 0, 0]).reshape(2, 2)
    rects = []
    for y in range(height):
        for x in range(width):
            window = layout_dynamic[y-1:y+1, x-1:x+1]
            if np.array_equal(left_up_corner, window):
                corner = [y - 1, x - 1]
                #print("Left up corner at (%d, %d)" % (corner[0], corner[1]))
                rects += [[corner, [0, 0], [0, 0], [0, 0]]]
            elif np.array_equal(right_up_corner, window):
                corner = [y - 1, x - 2]
                #print("Right up corner at (%d, %d)" % (corner[0], corner[1]))
                rect_n = [r[0][0] for r in rects].index(y - 1)
                rects[rect_n][1] = corner
            elif np.array_equal(left_down_corner, window):
                corner = [y - 2, x - 1]
                #print("Left down corner at (%d, %d)" % (corner[0], corner[1]))
                rect_n = [r[0][1] if r[2] == [0, 0] else 0 for r in rects].index(x - 1)
                rects[rect_n][2] = corner
            elif np.array_equal(right_down_corner, window):
                corner = [y - 2, x - 2]
                #print("Right down corner at (%d, %d)" % (corner[0], corner[1]))
                rect_n = [r[2][0] for r in rects].index(y - 2)
                rects[rect_n][3] = corner
    for i, rect in enumerate(rects):
        print("Area %d:" % i)
        print("  origin     :", rect[0])
        print("  width      :", rect[1][1] - rect[0][1] + 1)
        print("  height     :", rect[2][0] - rect[0][0] + 1)
        print("  left up    :", rect[0])
        print("  right up   :", rect[1])
        print("  left down  :", rect[2])
        print("  righr down :", rect[3])


if __name__ == "__main__":
    # Remove previous generation artifacts
    img_files = glob.glob('./img/*')
    for f in img_files:
        os.remove(f)

    # Generate bitmaps
    acq_env, gain, acq = gen_acq_env(512)
    topturn1 = [0]*25 + [1]*20 + [0]*48 + [1]*40 + [0]*10 + [1]*50 + [0]*15 + [1]*15 + [0]*33
    topturn2 = [0 if b else 1 for b in topturn1]
    topturn3 = topturn1[0:len(topturn1)//2] + topturn2[len(topturn2)//2:len(topturn2)]
    gen_env_bmp(acq_env)
    gen_gain_bmp(gain)
    gen_env_axis_bmp()
    gen_topturn_bmp(topturn1, 1)
    gen_topturn_bmp(topturn2, 2)
    gen_topturn_bmp(topturn3, 3)
    gen_topturn_axis_bmp()
    gen_labels_bmp()
    gen_hex_ch_bmp()

    # Generate static pixels mem file
    static_pixels = get_static_pixels()
    gen_mem_1(static_pixels, 'static_pixels_raw')
    compressed_static_pixels = rle_encoder(static_pixels)
    gen_mem_16(compressed_static_pixels, 'static_pixels')

    # Generate hexadimical characters mem file
    hex_ch_pixels = get_hex_ch_pixels()
    gen_mem_8(hex_ch_pixels, 'hex_ch')

    # Generate acqusition data for plot demonstration
    acq_plot = gen_acq_plot_data(acq_env, gain, topturn1, topturn2, topturn3)
    gen_mem_24(np.array(acq_plot), 'acq_plot_demo')

    # Generate acqusition data for plot demonstration
    gen_mem_12(np.array(acq), 'acq_raw')

    # Print coordinates of all dynamic areas on layout
    get_dynamic_areas()

