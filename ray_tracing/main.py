import multiprocessing

from multiprocessing import Queue
from time import time

from .ray import render as ray_render
from .ray import post_process
from .ppm import write_ppm

def render(width, height, rays=100, jobs=1, rseed=None):
    out_q = Queue()
    if rseed is None:
        rseed = int(time())

    def render_some(rays, queue):
        pixels = ray_render(width, height, rays, rseed)
        print 'putting pixels in the queue'
        queue.put(pixels)
        print 'DONE ...'


    procs = []
    for j in range(jobs):
        proc = multiprocessing.Process(
            target=render_some,
            args=(rays/jobs, out_q)
        )
        proc.start()
        procs.append(proc)

    all_pixels = []

    for i in range(len(procs)):
        print 'got some pixels'
        all_pixels.append(out_q.get())
        print 'got some pixels ... done'

    print 'waiting for the procs to finish', procs
    for p in procs:
        print p
        p.join()


    print 'processing the pixels'
    pixels = post_process(all_pixels)

    write_ppm(
        filename=b'background.ppm',
        pixels=pixels,
        width=width,
        height=height,
    )

