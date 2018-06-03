cdef class Vec3:
    cdef public float x, y, z
    cpdef Vec3 dot(self, other)
    cpdef Vec3 cross(self, other)
    cpdef Vec3 unit_vector(self)
    cpdef make_unit_vector(self)
    cpdef float squared_length(self)
    cpdef length(self)
