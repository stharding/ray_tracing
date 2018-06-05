cdef class Vec3:
    cdef public float x, y, z
    cdef float dot(self, Vec3 other) nogil
    cdef Vec3 cross(self, Vec3 other)
    cdef Vec3 unit_vector(self)
    cdef void make_unit_vector(self) nogil
    cdef float squared_length(self) nogil
    cdef float length(self) nogil
    cdef void update_from(self, Vec3 other) nogil
