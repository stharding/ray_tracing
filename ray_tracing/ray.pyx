from libc.math cimport pi, cos, sqrt

from random import random

cdef class Ray:
    def __init__(self, Vec3 origin=None, Vec3 direction=None):
        self.origin = origin or Vec3()
        self.direction = direction or Vec3()

    cpdef Vec3 point_at_parameter(self, float t):
        return self.origin + t * self.direction

    cpdef update_from(self, Ray other):
        self.origin = other.origin
        self.direction = other.direction

    def __repr__(self):
        return (
            self.__class__.__name__ +
            '(' + repr(self.origin) + ', ' + repr(self.direction) + ')'
        )

    @staticmethod
    cdef Vec3 random_in_unit_sphere():
        cdef Vec3 p = Vec3()
        cdef float sq_len = 1
        while sq_len >= 1:
            p = 2 * Vec3(random(), random(), random()) - Vec3(1, 1, 1)
            sq_len = p.squared_length()

        return p


cpdef float hit_sphere(Vec3 center, float radius, Ray r):
    cdef Vec3 oc = r.origin - center
    cdef float a = r.direction.dot(r.direction)
    cdef float b = 2 * oc.dot(r.direction)
    cdef float c = oc.dot(oc) - radius ** 2
    cdef float discriminant = b ** 2 - 4 * a * c
    if discriminant < 0:
        return -1
    return (-b - sqrt(discriminant)) / (2 * a)


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
    else:
        unit_direction = r.direction.unit_vector()
        t = 0.5 * (unit_direction.y + 1)
        return (1 - t) * Vec3(1, 1, 1) + t * Vec3(0.5, 0.7, 1)


cpdef HitList random_scene():
    cdef int n = 500
    cdef HitList hit_list = HitList()
    hit_list.shapes.append(Sphere(
        center=Vec3(0, -1000, 0),
        radius=1000,
        material=Lambertian(Vec3(0.5, 0.5, 0.5))
    ))
    cdef int a, b
    cdef float choose_mat
    cdef Vec3 center
    for a in range(-11, 11):
        for b in range(-11, 11):
            choose_mat = random()
            center = Vec3(
                a + 0.9 * random(),
                0.2,
                b + 0.9 * random()
            )
            # add a diffuse sphere
            if choose_mat < 0.8:
                hit_list.shapes.append(
                    Sphere(
                        center=center,
                        radius=0.2,
                        material=Lambertian(Vec3(
                            random() * random(),
                            random() * random(),
                            random() * random(),
                        ))
                    )
                )
            # add a metal sphere
            elif choose_mat < 0.95:
                hit_list.shapes.append(
                    Sphere(
                        center=center,
                        radius=0.2,
                        material=Metal(Vec3(
                            0.5 * (1 + random()),
                            0.5 * (1 + random()),
                            0.5 * (1 + random()),
                        ), 0.5 * random()),
                    )
                )
            # add a glass spere
            else:
                hit_list.shapes.append(
                    Sphere(
                        center=center,
                        radius=0.2,
                        material=Dielectric(1.5)
                    )
                )
    hit_list.shapes += [
        Sphere(
            center=Vec3(0, 1, 0),
            radius=1,
            material=Dielectric(1.5)
        ),
        Sphere(
            center=Vec3(-4, 1, 0),
            radius=1,
            material=Lambertian(Vec3(0.4, 0.2, 0.1))
        ),
        Sphere(
            center=Vec3(4, 1, 0),
            radius=1,
            material=Metal(Vec3(0.7, 0.6, 0.5), 0)
        )
    ]
    return hit_list

cpdef render(int width=200, int height=100, int samples=100, hitlist=None):
    cdef float u, v
    cdef Ray r
    cdef Vec3 lower_left = Vec3(-2, -1, -1)
    cdef Vec3 horizontal = Vec3(x=4)
    cdef Vec3 vertical = Vec3(y=2)
    cdef Vec3 origin = Vec3()
    cdef Vec3 clr
    cdef float radius = cos(pi / 4)

    cdef HitList hit_list
    if hitlist is None:
        hit_list = random_scene()
    else:
        hit_list = hitlist

    cdef Vec3 look_from = Vec3(13, 2, 3)
    cdef Vec3 look_at = Vec3(0, 0, 0)
    cdef float focus_dist = 10
    cdef Camera camera = Camera(
        look_from=look_from,
        look_at=look_at,
        vup=Vec3(0, 1, 0),
        vfov=20,
        aspect_ratio=width / float(height),
        aperture=0.1,
        focus_dist=focus_dist
    )

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
                255.99 * sqrt(clr.x),
                255.99 * sqrt(clr.y),
                255.99 * sqrt(clr.z),
            ))
        print '{:.2f}% complete'.format(100 * (height - j) / float(height))

    return pixels

cpdef post_process(parallel_pixels):
    cdef Vec3 pixel
    cdef int num_lists = len(parallel_pixels)
    out = []
    for group in zip(*parallel_pixels):
        pixel = reduce(Vec3.__add__, group) / num_lists
        out.append(pixel)
    return out
