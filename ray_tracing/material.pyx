from random import random


cdef Vec3 reflect(Vec3 v, Vec3 n):
    return v - 2 * v.dot(n) * n

cdef bint refract(Vec3 v, Vec3 n, float ni_over_nt, Vec3 refracted):
    cdef Vec3 uv = v.unit_vector()
    cdef float dt = uv.dot(n)
    cdef discriminant = 1 - ni_over_nt * ni_over_nt * (1 - dt*dt)
    if discriminant > 0:
        refracted.update_from(ni_over_nt * (uv - n * dt) - n * sqrt(discriminant))
        return True
    return False

cdef float schlick(float cosine, float refraction_index):
    cdef float r0 = (1 - refraction_index) / (1 + refraction_index)
    r0 = r0 * r0
    return r0 + (1 - r0) * (1 - cosine)**5

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
        if fuzz <= 1 and fuzz >= 0:
            self.fuzz = fuzz
        else:
            self.fuzz = 1

    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered):

        cdef Vec3 reflected = reflect(r_in.direction, rec.normal)
        if self.fuzz == 0:
            scattered.update_from(Ray(rec.p, reflected))
        else:
            scattered.update_from(Ray(rec.p, reflected + self.fuzz * Ray.random_in_unit_sphere()))
        attenuation.update_from(self.albedo)
        return scattered.direction.dot(rec.normal) > 0

cdef class Dielectric(Material):
    def __init__(self, float refraction_index):
        self.refraction_index = refraction_index

    cdef bint scatter(self,
                      Ray r_in,
                      HitRecord rec,
                      Vec3 attenuation,
                      Ray scattered):

        cdef Vec3 outward_normal
        cdef Vec3 reflected = reflect(r_in.direction, rec.normal)
        cdef float ni_over_nt
        attenuation.update_from(Vec3(1, 1, 1))
        cdef Vec3 refracted = Vec3()
        cdef float reflect_prob
        cdef float cosine

        if r_in.direction.dot(rec.normal) > 0:
            outward_normal = -rec.normal
            ni_over_nt = self.refraction_index
            cosine = self.refraction_index * r_in.direction.dot(
                rec.normal) / r_in.direction.length()
        else:
            outward_normal = rec.normal
            ni_over_nt = 1 / self.refraction_index
            cosine = -r_in.direction.dot(rec.normal) / r_in.direction.length()

        if refract(r_in.direction, outward_normal, ni_over_nt, refracted):
            reflect_prob = schlick(cosine, self.refraction_index)
        else:
            reflect_prob = 1

        if random() < reflect_prob:
            scattered.update_from(Ray(rec.p, reflected))
        else:
            scattered.update_from(Ray(rec.p, refracted))

        return True

