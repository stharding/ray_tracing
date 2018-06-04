from .vec3 cimport Vec3
from .ray cimport Ray

cdef class Camera:
    cdef Vec3 origin
    cdef Vec3 lower_left_corner
    cdef Vec3 horizontal
    cdef Vec3 vertical
    cdef Ray get_ray(self, float u, float v)
