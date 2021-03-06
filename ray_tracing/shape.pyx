from libc.math cimport sqrt
cdef class HitRecord:

    def __cinit__(self):
        self.material = Material()
    cdef update_from(self, HitRecord other):
        self.t = other.t
        self.p = other.p
        self.normal = other.normal
        self.normal = other.normal
        self.material = other.material


cdef class Shape:
    cdef bint hit(self, Ray r, float t_min, float t_max, HitRecord rec):
        raise NotImplementedError()
        return False

cdef class Sphere(Shape):
    def __init__(self, Vec3 center, float radius, Material material=None):
        self.center = center
        self.radius = radius
        self.material = material or Lambertian(Vec3())

    cdef bint hit(self, Ray r, float t_min, float t_max, HitRecord rec):
        cdef Vec3 oc = r.origin - self.center
        cdef float a = r.direction.dot(r.direction)
        cdef float b = oc.dot(r.direction)
        cdef float c = oc.dot(oc) - self.radius**2
        cdef float discriminant = b**2 - a * c

        if discriminant < 0:
            return False

        cdef float temp = (-b - sqrt(discriminant)) / a
        if temp < t_max and temp > t_min:
            rec.t = temp
            rec.p = r.point_at_parameter(rec.t)
            rec.normal = (rec.p - self.center) / self.radius
            rec.material = self.material
            return True
        return False

cdef class HitList(Shape):
    def __init__(self, shapes=None):
        self.shapes = shapes or []

    cdef bint hit(self, Ray r, float t_min, float t_max, HitRecord rec):
        cdef Shape shape
        cdef HitRecord temp_rec = HitRecord()
        cdef bint hit_anything = False
        cdef float closest_so_far = t_max
        for shape in self.shapes:
            if shape.hit(r, t_min, closest_so_far, temp_rec):
                hit_anything = True
                closest_so_far = temp_rec.t
                rec.update_from(temp_rec)

        return hit_anything
