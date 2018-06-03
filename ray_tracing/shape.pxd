from .vec3 cimport Vec3
from .ray cimport Ray

cdef class HitRecord:
    cdef float t
    cdef Vec3 p
    cdef Vec3 normal
    cdef update_from(self, HitRecord other)


cdef class Shape:
    cdef bint hit(self, Ray r, float t_min, float t_max, HitRecord rec)


cdef class Sphere(Shape):
    cdef Vec3 center
    cdef float radius


cdef class HitList(Shape):
    cdef list shapes
