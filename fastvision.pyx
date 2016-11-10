"""This is the Cython file!"""

from cython cimport view
from libc.stdlib cimport malloc
from libc.string cimport memcpy


# -------------------------------------------------------------------------------------------------
# python -c "import FastVision as s; from PIL import Image; s.openImage(Image.open('test.png'))"
import numpy as np
cimport numpy as np  # for np.ndarray!
# from libcpp.string cimport string
# from libc.string cimport memcpy

# cdef extern from "opencv2/core/core.hpp":
#     cdef int CV_WINDOW_AUTOSIZE
#     cdef int CV_8UC3, CV_8UC4

# cdef extern from "opencv2/core/core.hpp" namespace "cv":
#     cdef cppclass Mat:
#         Mat() except +
#         void create(int, int, int)
#         void* data

# cdef extern from "opencv2/highgui/highgui.hpp" namespace "cv":
#     void namedWindow(const string, int flag)
#     void imshow(const string, Mat)
#     int  waitKey(int delay)

# cdef void ary2cvMat(np.ndarray ary, Mat& out):
#     assert(ary.ndim==3 and ary.shape[2]==3, "ASSERT::3channel RGB only!!")
#     ary = np.dstack((ary[..., 2], ary[..., 1], ary[..., 0]))  # RGB -> BGR

#     cdef np.ndarray[np.uint8_t, ndim=3, mode = 'c'] np_buff = np.ascontiguousarray(ary, dtype=np.uint8)
#     cdef unsigned int* im_buff = <unsigned int*> np_buff.data
#     cdef int r = ary.shape[0]
#     cdef int c = ary.shape[1]
#     out.create(r, c, CV_8UC3)
#     memcpy(out.data, im_buff, r*c*3)


# cdef showMat(Mat m):
#     namedWindow("WIN", CV_WINDOW_AUTOSIZE)
#     imshow("WIN", m)
#     waitKey(0)

# def openImage(pil_img):
#     cdef Mat m
#     ary2cvMat(np.array(pil_img), m)
#     showMat(m)


# -------------------------------------------------------------------------------------------------
cdef extern from "FastVision.h" namespace "shapes":  # This is why we need the header file!
    cdef cppclass FastVision:
        FastVision()
        FastVision(int, int, int, int)
        int x, y, width, height
        char* get_screen()
        void ximg_meta()

# -------------------------------------------------------------------------------------------------
cdef extern from "Python.h":
    ctypedef struct PyObject
    object PyMemoryView_FromBuffer(Py_buffer *view)
    int PyBuffer_FillInfo(Py_buffer *view, PyObject *obj, void *buf, Py_ssize_t len, int readonly, int infoflags)
    enum:
        PyBUF_FULL_RO



# ---------------------
cdef class PyFastVision:
    """THIS is where we define the Python API!!! So it doesn't matter how crappy the C++ API is!

    This is an example of a type of Cython class called an **extension type**. They're more
    restricted than their Python counterparts, but they're faster and more memory-efficient!
    They use a C struct to store their fields and methods instead of a Python dict! This means:
    1) they can store arbitrary C types in their fields without requiring a Python wrapper, and
    2) they can access fields and methods directly at the C level without going through a Python
    dict lookup!
    """

    cdef FastVision *thisptr      # Hold a C++ instance which we're wrapping! Lala

    # You can only expose simple C types, such as ints, floats, and strings, for Python access
    # You can also expose Python-valued attributes
    # I *think* these are instance variables, and not class variables!
    # Without the **public** keyword, these variables will not be visible from outside the class!
    # Attributes of an extension type are stored directly in the object’s C struct!
    # By default, extension type attributes are only accessible by direct access, not from Python code.
    # To make them accessible from Python code, you need to declare them as public!
    cdef public int x, y, width, height
    # Now x, y, width, and height can be accessed from Python code!

    def __cinit__(self, int x, int y, int width, int height):
        self.thisptr = new FastVision(x, y, width, height)

    def __init__(self, x, y, width, height):
        self.x, self.y = x, y
        self.width, self.height = width, height
        # self.a = self.thisptr.getArea()

    def __dealloc__(self):
        del self.thisptr

    def get_screen(self):
        cdef char* ximg = self.thisptr.get_screen()

        cdef const void *cstr = ximg
        cdef size_t l = self.width*self.height*4
        cdef Py_buffer buf_info
        cdef char[:] cy_arr
        cdef int read_only = 0
        PyBuffer_FillInfo(&buf_info, NULL, <void*>cstr, l, read_only, PyBUF_FULL_RO)
        cy_arr = PyMemoryView_FromBuffer(&buf_info)

        return np.asarray(cy_arr)

        # cdef view.array view_arr = view.array(shape=(1080*1920*4,), itemsize=sizeof(char), format='u8')
        # view_arr[:] = cy_arr
        # view_arr.data = self.thisptr.get()
        # cdef unsigned char [:] carr_view = ximg

        # cdef np.ndarray[unsigned char, ndim=3, mode='c'] np_arr = np.empty((1080, 1920, 4), np.uint8)
        # return np_arr
        # return view_arr

    def ximg_meta(self):
        self.thisptr.ximg_meta()

    # def area(self):
    #     return self.thisptr.getArea()

    # def move(self, dx, dy):
    #     self.thisptr.move(dx, dy)
