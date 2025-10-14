#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Filename: mpi_moviedata2vtk.py
Author: Emanuele Casarotti
Contact: emanuele.casarotti@ingv.it
License: Apache-2.0
"""

import argparse
import gc
import os
from timeit import default_timer as timer

import meshio
import numpy
from mpi4py import MPI
from scipy.interpolate import griddata

os.environ["OPENBLAS_NUM_THREADS"] = "1"

comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()
print(rank, size)


def read_moviedata(
    f, step=250, endian=">f", xmin=None, xmax=None, ymin=None, ymax=None
):
    data = numpy.fromfile(f, dtype=numpy.float32)
    field = 6
    np = int(len(data) / field)
    data.shape = (6, np)
    x = data[0][1:-1]
    y = data[1][1:-1]
    p = (x, y)
    z = data[2][1:-1]
    vx = data[3][1:-1]
    vy = data[4][1:-1]
    vz = data[5][1:-1]
    if xmin is None:
        xmin = min(x)
    if ymin is None:
        ymin = min(y)
    if xmax is None:
        xmax = max(x)
    if ymax is None:
        ymax = max(y)
    xs = numpy.arange(xmin, xmax + step / 2.0, step)
    ys = numpy.arange(ymin, ymax + step / 2.0, step)
    X, Y = numpy.meshgrid(xs, ys)
    vxs = griddata(p, vx, (X, Y), fill_value=0, method="cubic")
    vys = griddata(p, vy, (X, Y), fill_value=0, method="cubic")
    vzs = griddata(p, vz, (X, Y), fill_value=0, method="cubic")
    zs = griddata(p, z, (X, Y), fill_value=0, method="linear")
    pgv = numpy.maximum(numpy.abs(vxs), numpy.abs(vys))
    pgv = numpy.maximum(pgv, numpy.abs(vzs))
    pgv.shape = vxs.shape
    gc.collect()
    return X, Y, zs, vxs, vys, vzs, pgv


def create_vtk_meshio(f, step=250, topo=None, ymax=None):
    X, Y, zs, vxs, vys, vzs, pgv = read_moviedata(f, step=step, endian=False, ymax=ymax)
    points = numpy.column_stack([X.ravel(), Y.ravel(), zs.ravel()])
    ids = numpy.arange(len(points))
    ids.shape = X.shape
    cells = [
        (
            "quad",
            numpy.column_stack(
                [
                    ids[:-1, :-1].ravel(),
                    ids[:-1, 1:].ravel(),
                    ids[1:, 1:].ravel(),
                    ids[1:, :-1].ravel(),
                ]
            ),
        )
    ]
    mesh = meshio.Mesh(
        points,
        cells,
        point_data={
            "vx": vxs.ravel(),
            "vy": vys.ravel(),
            "vz": vzs.ravel(),
            "pgv": pgv.ravel(),
        },
    )
    return mesh


def flatten_concatenation(matrix):
    flat_list = []
    for row in matrix:
        flat_list += row
        return flat_list


parser = argparse.ArgumentParser(description="converting specfem3d moviedata")
parser.add_argument("--dt", type=float, default=0, help="interpolation timestep")
parser.add_argument("--dx", type=float, default=5000, help="interpolation step")
parser.add_argument(
    "--file", type=str, default="moviedata??????", help="moviedata file"
)
args = parser.parse_args()
dt = args.dt
dx = args.dx
fs = args.file

if rank == 0:

    print("timestep", dt, " horizontal step", dx)
    import glob

    filenames = glob.glob(fs)
    filenames.sort()
    chunks = [[] for _ in range(size)]
    for i, chunk in enumerate(filenames):
        chunks[i % size].append(chunk)

    print(chunks)
else:
    chunks = None


chunks = comm.scatter(chunks, root=0)

for i, f in enumerate(chunks):
    start = timer()

    if os.path.exists(f + ".vtu"):
        print("with meshio:", rank, "File " + f + ".vtu exists")
    else:
        print("File does not exist")
        result = create_vtk_meshio(f, step=dx)
        chunks[i] = {f}
        print("with meshio:", rank, f, timer() - start, max(result.point_data["pgv"]))
        result.write(f + ".vtu")

chunks = comm.gather(chunks, root=0)

if rank == 0:
    with meshio.xdmf.TimeSeriesWriter("shakemovie_vz.xdmf") as writer:
        filenames = glob.glob("moviedata*.vtu")
        filenames.sort()

        mesh = meshio.read(filenames[0])

        points = mesh.points
        cells = mesh.cells
        writer.write_points_cells(points, cells)
        if dt != 0:
            t = int(filenames[0].split("moviedata")[-1].split(".")[0]) * dt
        else:
            t = 0
        writer.write_data(t, point_data={"vz": mesh.point_data["vz"]})
        for it, f in enumerate(filenames[1:]):
            if dt != 0:
                t = int(f.split("moviedata")[-1].split(".")[0]) * dt
            else:
                t = it + 1
            mesh = meshio.read(f)
            writer.write_data(t, point_data={"vz": mesh.point_data["vz"]})

    with meshio.xdmf.TimeSeriesWriter("shakemovie_full.xdmf") as writer:
        filenames = glob.glob("moviedata*.vtu")
        filenames.sort()

        mesh = meshio.read(filenames[0])

        points = mesh.points
        cells = mesh.cells
        writer.write_points_cells(points, cells)
        if dt != 0:
            t = int(filenames[0].split("moviedata")[-1].split(".")[0]) * dt
        else:
            t = 0
        writer.write_data(t, point_data=mesh.point_data)
        for it, f in enumerate(filenames[1:]):
            if dt != 0:
                t = int(f.split("moviedata")[-1].split(".")[0]) * dt
            else:
                t = it + 1
            mesh = meshio.read(f)
            writer.write_data(t, point_data=mesh.point_data)

    with meshio.xdmf.TimeSeriesWriter("shakemovie_pgv.xdmf") as writer:
        filenames = glob.glob("moviedata*.vtu")
        filenames.sort()

        mesh = meshio.read(filenames[0])

        points = mesh.points
        cells = mesh.cells
        writer.write_points_cells(points, cells)
        if dt != 0:
            t = int(filenames[0].split("moviedata")[-1].split(".")[0]) * dt
        else:
            t = 0
        writer.write_data(t, point_data={"vz": mesh.point_data["pgv"]})
        for it, f in enumerate(filenames[1:]):
            if dt != 0:
                t = int(f.split("moviedata")[-1].split(".")[0]) * dt
            else:
                t = it + 1
            mesh = meshio.read(f)
            writer.write_data(t, point_data={"vz": mesh.point_data["pgv"]})
