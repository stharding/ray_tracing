from libc.math cimport pi, tan
from random import random

cdef Vec3 random_in_unit_disk():
    cdef Vec3 p
    while True:
        p = 2 * Vec3(random(), random(), 0) - Vec3(1, 1, 0)
        if p.dot(p) < 1:
            break
    return p

cdef class Camera:
    def __init__(self,
                 Vec3  look_from,
                 Vec3  look_at,
                 Vec3  vup,
                 float vfov,
                 float aspect_ratio,
                 float aperture,
                 float focus_dist):

        cdef float theta = vfov * pi / 180
        cdef float half_height = tan(theta / 2)
        cdef float half_width = aspect_ratio * half_height

        self.lens_radius = aperture / 2
        self.w = (<Vec3>(look_from - look_at)).unit_vector()
        self.u = vup.cross(self.w).unit_vector()
        self.v = self.w.cross(self.u)
        self.origin = look_from
        self.lower_left_corner = (
            self.origin - half_width * focus_dist * self.u -
            half_height * focus_dist * self.v - focus_dist * self.w
        )
        self.horizontal = 2 * half_width * focus_dist * self.u
        self.vertical = 2 * half_height * focus_dist * self.v

    cdef Ray get_ray(self, float s, float t):
        cdef Vec3 rd = self.lens_radius * random_in_unit_disk()
        cdef Vec3 offset = self.u * rd.x + self.v * rd.y
        return Ray(
            self.origin + offset, (
                self.lower_left_corner +
                s * self.horizontal +
                t * self.vertical - self.origin - offset
            )
        )
