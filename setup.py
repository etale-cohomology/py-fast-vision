# rm -rf build; rm fastvision.cpp; rm fastvision.cpython*.so; py setup.py build_ext --inplace && py example0.py
# rm -rf build; rm fastvision.cpp; rm fastvision.cpython*.so
# py setup.py build_ext --inplace && py example0.py

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

from Cython.Build import cythonize


# -------------------------------------------------------------------------------------------------
# Remove useless compiler flags!
import distutils.sysconfig
useless_flags = ['-Wstrict-prototypes', '-O3', '-DNDEBUG', '-Wall', '-Wsign-compare', '-fwrapv']
config_vars = distutils.sysconfig.get_config_vars()
for key, value in config_vars.items():
    if isinstance(value, str):
        for flag in useless_flags:
            value = value.replace(flag, '')
        config_vars[key] = value


# -------------------------------------------------------------------------------------------------
flags = ['-Ofast', '-funroll-loops', '-march=native', '-mfpmath=both', '-m64']
# flags = ['-Ofast', '-funroll-loops', '-march=native', '-mfpmath=both', '-m64', '-mavx2']
module = cythonize(Extension(name='fastvision',
                             sources=['fastvision.pyx', 'FastVision.cpp'],
                             language='c++',  # Make Pyrex/Cython create C++ source!
                             include_dirs=['/usr/local/include'],
                             library_dirs=['/usr/local/lib'],
                             libraries=['X11', 'Xext'],  # 'opencv_core', 'opencv_highgui', 'opencv_imgproc'
                             runtime_library_dirs=[],
                             extra_compile_args=flags,
                             extra_link_args=[]))

setup(ext_modules=module, cmdclass={'build_ext': build_ext})
