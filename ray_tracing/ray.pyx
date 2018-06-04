from random import random

cdef class Ray:
    def __init__(self, Vec3 a=None, Vec3 b=None):
        self.A = a or Vec3()
        self.B = b or Vec3()

    cpdef Vec3 origin(self):
        return self.A

    cpdef Vec3 direction(self):
        return self.B

    cpdef Vec3 point_at_parameter(self, float t):
        return self.A + t * self.B

    def __repr__(self):
        return (
            self.__class__.__name__ +
            '(' + repr(self.A) + ', ' + repr(self.B) + ')'
        )

cpdef float hit_sphere(Vec3 center, float radius, Ray r):
    cdef Vec3 oc = r.origin() - center
    cdef float a = r.direction().dot(r.direction())
    cdef float b = 2 * oc.dot(r.direction())
    cdef float c = oc.dot(oc) - radius ** 2
    cdef float discriminant = b ** 2 - 4 * a * c
    if discriminant < 0:
        return -1
    return (-b - discriminant**0.5) / (2 * a)


cdef random_in_unit_sphere():
    cdef Vec3 p = Vec3()
    cdef sq_len = 1
    while sq_len >= 1:
        p = 2 * Vec3(random(), random(), random()) - Vec3(1, 1, 1)
        sq_len = p.squared_length()

    return p


cpdef Vec3 color(Ray r, Shape shape):
    cdef HitRecord rec = HitRecord()
    cdef Vec3 unit_direction, target
    cdef float t

    if shape.hit(r, 0.001, FLT_MAX, rec):
        target = rec.p + rec.normal + random_in_unit_sphere()
        return 0.5 * color(Ray(rec.p, target - rec.p), shape)
    else:
        unit_direction = r.direction().unit_vector()
        t = 0.5 * (unit_direction.y + 1)
        return (1 - t) * Vec3(1, 1, 1) + t * Vec3(0.5, 0.7, 1)


cpdef render(int width=200, int height=100, int samples=100):
    cdef float u, v
    cdef Ray r
    cdef Vec3 lower_left = Vec3(-2, -1, -1)
    cdef Vec3 horizontal = Vec3(x=4)
    cdef Vec3 vertical = Vec3(y=2)
    cdef Vec3 origin = Vec3()
    cdef Vec3 clr

    cdef HitList hit_list = HitList(shapes=[
        Sphere(center=Vec3(0, 0, -1), radius=0.5),
        Sphere(center=Vec3(0, -100.5, -1), radius=100),
    ])
    cdef Camera camera = Camera()

    pixels = []
    for j in range(height - 1, -1, -1):
        for i in range(width):
            clr = Vec3()
            for _ in range(samples):
                u = (i + random()) / width
                v = (j + random()) / height

                r = camera.get_ray(u, v)
                clr += color(r, hit_list)
            clr /= samples
            pixels.append(Vec3(
                255.99 * clr.x**0.5,
                255.99 * clr.y**0.5,
                255.99 * clr.z**0.5,
            ))

    write_ppm(
        filename=b'background.ppm',
        pixels=pixels,
        width=width,
        height=height,
    )
