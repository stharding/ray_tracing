from libc.float cimport FLT_MAX

from .vec3 cimport Vec3
from .ppm cimport write_ppm
from .shape cimport Shape, Sphere, HitList, HitRecord
from .camera cimport Camera
from .material cimport Lambertian, Metal, Dielectric


cdef class Ray:
    cdef public Vec3 origin
    cdef public Vec3 direction
    cpdef Vec3 point_at_parameter(self, float t)
    cpdef update_from(self, Ray other)

    @staticmethod
    cdef Vec3 random_in_unit_sphere()


cpdef Vec3 color(Ray r, Shape shape, int depth)
cpdef render(int width=*, int height=*, int samples=*, rseed=*)
