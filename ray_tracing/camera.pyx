from libc.math cimport pi, tan

cdef class Camera:
    def __init__(self,
                 Vec3 look_from,
                 Vec3 look_at,
                 Vec3 vup,
                 float vfov,
                 float aspect_ratio):

        cdef Vec3 u, v, w
        cdef float theta = vfov * pi / 180
        cdef float half_height = tan(theta / 2)
        cdef float half_width = aspect_ratio * half_height

        w = (look_from - look_at).unit_vector()
        u = vup.cross(w).unit_vector()
        v = w.cross(u)

        self.origin = look_from
        self.lower_left_corner = self.origin - half_width * u - half_height * v - w
        self.horizontal = 2 * half_width * u
        self.vertical = 2 * half_height * v

    cdef Ray get_ray(self, float u, float v):
        return Ray(
            self.origin, (
                self.lower_left_corner +
                u * self.horizontal +
                v * self.vertical - self.origin
            )
        )
