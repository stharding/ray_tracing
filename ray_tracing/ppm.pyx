cpdef write_ppm(bytes filename,
                pixels,
                int width,
                int height,
                depth=255):

    cdef Vec3 p
    with open(filename, 'wb') as f:
        ppm_text = '''P3
{width} {height}
{depth}
{rows}
        '''.format(
                width=width,
                height=height,
                depth=depth,
                rows='\n'.join(['{} {} {}'.format(
                    <int>p.x, <int>p.y, <int>p.z
                ) for p in pixels]
            )).encode()
        f.write(ppm_text)


def make_hello(int width, int height):
    write_ppm(
        filename=b'hello.ppm',
        pixels=[
            Vec3(int(255.99 * i / height),
                 int(255.99 * j / width),
                 int(255.99 * 0.2))
            for i in range(height)
            for j in range(width - 1, -1, -1)
        ],
        width=width,
        height=height
    )
