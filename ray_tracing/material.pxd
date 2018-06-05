from libc.math cimport sqrt

from .vec3 cimport Vec3
from .shape cimport HitRecord
from .ray cimport Ray

cdef class Material:
    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered)


cdef class Lambertian(Material):
    cdef Vec3 albedo


cdef class Metal(Material):
    cdef Vec3 albedo
    cdef float fuzz


cdef class Dielectric(Material):
    cdef Vec3 albedo
    cdef float refraction_index
