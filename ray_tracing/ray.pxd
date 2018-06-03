from libc.float cimport FLT_MAX

from .vec3 cimport Vec3
from .ppm cimport write_ppm
from .shape cimport Shape, Sphere, HitList, HitRecord

cdef class Ray:
    cdef public Vec3 A
    cdef public Vec3 B
    cpdef Vec3 origin(self)
    cpdef Vec3 direction(self)
    cpdef Vec3 point_at_parameter(self, float t)


cpdef Vec3 color(Ray r, Shape shape)
cpdef render(int width, int height)
