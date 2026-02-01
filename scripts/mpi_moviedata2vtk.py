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
import glob
import os
from timeit import default_timer as timer


os.environ["OPENBLAS_NUM_THREADS"] = "1"


import meshio
import numpy
from mpi4py import MPI
from scipy.interpolate import griddata


comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()
print(rank, size)

if size < 2:
    raise ValueError("At least 2 MPI processes are needed")


TERMINATION_MSG = -1

def read_moviedata(
    f, step=250, xmin=None, xmax=None, ymin=None, ymax=None
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
    X, Y, zs, vxs, vys, vzs, pgv = read_moviedata(f, step=step, ymax=ymax)
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


parser = argparse.ArgumentParser(description="converting specfem3d moviedata")
parser.add_argument("--dt", type=float, default=0, help="interpolation timestep")
parser.add_argument("--dx", type=float, default=5000, help="interpolation step")
parser.add_argument("--ntstep", type=int, default=30, help="ntstep between frames")
parser.add_argument(
    "--file", type=str, default="moviedata??????", help="moviedata file"
)
args = parser.parse_args()
dt = args.dt
dx = args.dx
ntstep = args.ntstep
fs = args.file

if rank == 0:
    print("timestep", dt, " horizontal step", dx)
    termination_msgs = 0
    with (
        meshio.xdmf.TimeSeriesWriter("shakemovie_full.xdmf") as full_writer,
        meshio.xdmf.TimeSeriesWriter("shakemovie_pgv.xdmf") as pgv_writer,
        meshio.xdmf.TimeSeriesWriter("shakemovie_vz.xdmf") as vz_writer
    ):
        while termination_msgs < (size - 1):
            if (idx := comm.recv(source=MPI.ANY_SOURCE)) != TERMINATION_MSG:
                file_name = f"moviedata{idx:06}.vtu"
                print(f"Received {file_name}")
                mesh = meshio.read(file_name)
                if not full_writer.has_mesh:
                    full_writer.write_points_cells(mesh.points, mesh.cells)
                    pgv_writer.write_points_cells(mesh.points, mesh.cells)
                    vz_writer.write_points_cells(mesh.points, mesh.cells)
                t = idx * dt if dt != 0 else idx
                full_writer.write_data(t, point_data=mesh.point_data)
                pgv_writer.write_data(t, point_data={"pgv": mesh.point_data["pgv"]})
                vz_writer.write_data(t, point_data={"vz": mesh.point_data["vz"]})
            else:
                termination_msgs += 1
                print(f"Received {termination_msgs}/{size - 1} termination messages")
else:
    print(f"Rank {rank} started")
    for f in glob.iglob(fs):
        idx = int(f.split("moviedata")[-1].split(".")[0])
        if rank == (((idx // ntstep) % (size - 1)) + 1):
            start = timer()
            if os.path.exists(f + ".vtu"):
                print("with meshio:", rank, f"File {f}.vtu exists")
            else:
                print("with meshio:", rank, f"File {f}.vtu does not exist")
                result = create_vtk_meshio(f, step=dx)
                print("with meshio:", rank, f, timer() - start, max(result.point_data["pgv"]))
                result.write(f + ".vtu")
            comm.send(idx, dest=0)
    comm.send(TERMINATION_MSG, dest=0)
print(f"Rank {rank} terminated")
