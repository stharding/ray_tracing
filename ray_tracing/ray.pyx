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

cpdef bint hit_sphere(Vec3 center, float radius, Ray r):
    cdef Vec3 oc = r.origin() - center
    cdef float a = r.direction().dot(r.direction())
    cdef float b = 2 * oc.dot(r.direction())
    cdef float c = oc.dot(oc) - radius ** 2
    cdef float discriminant = b ** 2 - 4 * a * c
    return discriminant > 0


cpdef Vec3 color(Ray r):
    if hit_sphere(Vec3(0, 0, -1), 0.5, r):
        return Vec3(1, 0, 0)
    cdef Vec3 unit_direction = r.direction().unit_vector()
    cdef float t = 0.5 * (unit_direction.y + 1)
    return (1 - t) * Vec3(1, 1, 1) + t * Vec3(0.5, 0.7, 1)

cpdef write_background(int width, int height):
    cdef float u, v
    cdef Ray r
    cdef Vec3 lower_left = Vec3(-2, -1, -1)
    cdef Vec3 horizontal = Vec3(x=4)
    cdef Vec3 vertical = Vec3(y=2)
    cdef Vec3 origin = Vec3()
    cdef Vec3 clr

    pixels = []
    for j in range(height - 1, -1, -1):
        for i in range(width):
            u = float(i) / width
            v = float(j) / height

            r = Ray(origin, lower_left + u * horizontal + v * vertical)
            clr = color(r)
            pixels.append(Vec3(
                255.99 * clr.x,
                255.99 * clr.y,
                255.99 * clr.z,
            ))

    write_ppm(
        filename=b'background.ppm',
        pixels=pixels,
        width=width,
        height=height,
    )
