from .vec3 cimport Vec3

cpdef write_ppm(bytes filename,
                pixels,
                int width,
                int height,
                depth=*)
