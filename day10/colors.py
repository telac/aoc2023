# courtesy of https://stackoverflow.com/questions/59669715/fastest-way-to-find-the-rgb-pixel-color-count-of-image
from PIL import Image
import numpy as np

# Open Paddington and make sure he is RGB - not palette
im = Image.open('ps_bitmap_7px_pnt.png').convert('RGB')

# Make into Numpy array
na = np.array(im)

# Arrange all pixels into a tall column of 3 RGB values and find unique rows (colours)
colours, counts = np.unique(na.reshape(-1,3), axis=0, return_counts=1)

print(colours)
print(counts)

for x in sorted(counts.tolist()):
    print(x/(16*16))