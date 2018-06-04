cdef class Camera:
    def __init__(self,
                lower_left_corner=None,
                horizontal=None,
                vertical=None,
                origin=None):

        self.lower_left_corner = lower_left_corner or Vec3(-2, -1, -1)
        self.horizontal = horizontal or Vec3(x=4)
        self.vertical = vertical or Vec3(y=2)
        self.origin = origin or Vec3()

    cdef Ray get_ray(self, float u, float v):
        return Ray(
            self.origin, (
                self.lower_left_corner +
                u * self.horizontal +
                v * self.vertical - self.origin
            )
        )
