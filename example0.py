from fastvision import PyFastVision
import time

width, height = 1920>>1, 1080

screen = PyFastVision(0, 0, width, height)
screen.ximg_meta()

N_RUNS = 1<<6
print('Performing {} runs!\n'.format(N_RUNS))

for i in range(N_RUNS):

    clock = time.perf_counter()

    img = screen.get_screen()  # This is where stuff happens!

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
