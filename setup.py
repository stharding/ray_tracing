from platform import system
from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
    name='Ray Tracer',
    ext_modules=cythonize("ray_tracing/*.pyx")
)
