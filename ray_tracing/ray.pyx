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

    cpdef update_from(self, Ray other):
        self.A = other.A
        self.B = other.B

    def __repr__(self):
        return (
            self.__class__.__name__ +
            '(' + repr(self.A) + ', ' + repr(self.B) + ')'
        )

    @staticmethod
    cdef Vec3 random_in_unit_sphere():
        cdef Vec3 p = Vec3()
        cdef sq_len = 1
        while sq_len >= 1:
            p = 2 * Vec3(random(), random(), random()) - Vec3(1, 1, 1)
            sq_len = p.squared_length()

        return p


cpdef float hit_sphere(Vec3 center, float radius, Ray r):
    cdef Vec3 oc = r.origin() - center
    cdef float a = r.direction().dot(r.direction())
    cdef float b = 2 * oc.dot(r.direction())
    cdef float c = oc.dot(oc) - radius ** 2
    cdef float discriminant = b ** 2 - 4 * a * c
    if discriminant < 0:
        return -1
    return (-b - discriminant**0.5) / (2 * a)




cpdef Vec3 color(Ray r, Shape shape, int depth):
    cdef HitRecord rec = HitRecord()
    cdef Vec3 unit_direction, target, attenuation
    cdef float t
    cdef Ray scattered = Ray()

    if shape.hit(r, 0.001, FLT_MAX, rec):
        attenuation = Vec3()
        if depth < 50 and rec.material.scatter(r, rec, attenuation, scattered):
            return attenuation * color(scattered, shape, depth + 1)
        else:
            return Vec3()
        # target = rec.p + rec.normal + Ray.random_in_unit_sphere()
        # return 0.5 * color(Ray(rec.p, target - rec.p), shape, depth + 1)
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
        Sphere(
            center=Vec3(0, 0, -1),
            radius=0.5,
            material=Lambertian(Vec3(0.8, 0.3, 0.3))
        ),
        Sphere(
            center=Vec3(0, -100.5, -1),
            radius=100,
            material=Lambertian(Vec3(0.8, 0.8))
        ),
        Sphere(
            center=Vec3(1, 0, -1),
            radius=0.5,
            material=Metal(Vec3(0.8, 0.8, 0.8), 0.3)
        ),
        Sphere(
            center=Vec3(-1, 0, -1),
            radius=0.5,
            material=Metal(Vec3(0.8, 0.8, 0.8), 1)
        ),
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
                clr += color(r, hit_list, 0)
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
