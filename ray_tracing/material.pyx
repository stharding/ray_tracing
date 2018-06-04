from random import random


cdef Vec3 reflect(Vec3 v, Vec3 n):
    return v - 2 * v.dot(n) * n

cdef class Material:
    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered):

        raise NotImplemented()
        return False

cdef class Lambertian(Material):
    def __init__(self, Vec3 albedo):
        self.albedo = albedo

    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered):

        cdef Vec3 target = rec.p + rec.normal + Ray.random_in_unit_sphere()
        scattered.update_from(Ray(rec.p, target - rec.p))
        attenuation.update_from(self.albedo)
        return True


cdef class Metal(Material):
    def __init__(self, Vec3 albedo, float fuzz=1):
        self.albedo = albedo
        if fuzz < 1 and fuzz > 0:
            self.fuzz = fuzz
        else:
            self.fuzz = 1

    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered):

        cdef Vec3 reflected = reflect(r_in.direction(), rec.normal)
        scattered.update_from(Ray(rec.p, reflected + self.fuzz * Ray.random_in_unit_sphere()))
        attenuation.update_from(self.albedo)
        return scattered.direction().dot(rec.normal) > 0
