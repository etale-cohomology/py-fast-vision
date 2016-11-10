# PyFastVision

__PyFastVision__ contains the Python bindings for __FastVision__. Bindings are implemented using Cython.


## How to build

You'll need a C++ compiler and the Python headers. The Python OpenCV bindings are needed if you want to visualize the pixel data as an image in real time.

Afterwards, open up a terminal and type:

```
python3 setup.py build_ext --inplace
```

To run the test, type:

```
python3 example0.py
```

PyFastVision has been tested on Ubuntu 14.04 LTS with G++ 6 and Python 3.


## Example

After building the bindings by running

```
python3 setup.py build_ext --inplace
```

you can try the following example:

```python

from fastvision import PyFastVision
import time

width, height = 1920>>1, 1080

screen = PyFastVision(0, 0, width, height)
screen.ximg_meta()

N_RUNS = 1<<6
print('Performing {} runs!\n'.format(N_RUNS))

for i in range(N_RUNS):

    clock = time.perf_counter()

    img = screen.get_screen()   # This is where stuff happens!

    fps = 1 / (time.perf_counter()-clock)
    print('fps {:4.0f}  spf {:.4f}'.format(fps, 1/fps))

print('{} runs COMPLETE!'.format(N_RUNS))

img = img.reshape(height, width, 4)
print(img.shape, img.dtype)

try:
    from cv2 import imshow, waitKey
    print('Showing screenshot!')
    imshow('img', img)
    waitKey(0)  # Wait until any user key press!
except ImportError as e:
    print('Couldn\'t display screen: Python OpenCV is not available!',
          e, sep='\n')
```
