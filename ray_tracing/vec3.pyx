cdef class Vec3:
    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __add__(Vec3 self, Vec3 other):
        return Vec3(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z,
        )

    def __sub__(Vec3 self, Vec3 other):
        return Vec3(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z,
        )

    # implementing the inplace versions may
    # help performance ...
    def __mul__(first, second):
        if isinstance(first, Vec3) and isinstance(second, Vec3):
            return Vec3(
                first.x * second.x,
                first.y * second.y,
                first.z * second.z,
            )

        if isinstance(first, Vec3):
            return Vec3(
                first.x * second,
                first.y * second,
                first.z * second,
            )

        if isinstance(second, Vec3):
            return Vec3(
                first * second.x,
                first * second.y,
                first * second.z,
            )

    def __truediv__(first, second):
        if isinstance(first, Vec3) and isinstance(second, Vec3):
            return Vec3(
                first.x / second.x,
                first.y / second.y,
                first.z / second.z,
            )

        if isinstance(first, Vec3):
            return Vec3(
                first.x / second,
                first.y / second,
                first.z / second,
            )

        if isinstance(second, Vec3):
            return Vec3(
                first / second.x,
                first / second.y,
                first / second.z,
            )

    def __div__(first, second):
        return Vec3.__truediv__(first, second)

    def __neg__(self):
        return -1 * self

    def __matmul__(first, second):
        return Vec3.dot(first, second)

    cdef float dot(self, Vec3 other) nogil:
        return self.x * other.x + self.y * other.y + self.z * other.z

    cdef Vec3 cross(self, Vec3 other):
        return Vec3(
            self.y * other.z - self.z * other.y,
            -(self.x * other.z - self.z * other.x),
            self.x * other.y - self.y * other.x,
        )

    cdef Vec3 unit_vector(self):
        return self / self.length()

    cdef void make_unit_vector(self) nogil:
        cdef float k = 1 / self.length()
        self.x *= k
        self.y *= k
        self.z *= k

    cdef float length(self) nogil:
        return self.squared_length() ** 0.5

    cdef float squared_length(self) nogil:
        return self.x ** 2 + self.y ** 2 + self.z ** 2

    def __eq__(self, other):
        if not isinstance(other, Vec3):
            return False
        return (
            (self.x == other.x) and
            (self.y == other.y) and
            (self.z == other.z)
        )

    def __ne__(self, other):
        return not self == other

    def __repr__(self):
        return (
            self.__class__.__name__ +
            '({}, {}, {})'.format(self.x, self.y, self.z)
        )

    cdef void update_from(self, Vec3 other) nogil:
        self.x = other.x
        self.y = other.y
        self.z = other.z
