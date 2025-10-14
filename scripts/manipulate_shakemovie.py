#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Filename: manipulate_shakemovie.py
Author: Emanuele Casarotti
Contact: emanuele.casarotti@ingv.it
License: Apache-2.0
"""

import argparse

import meshio
import numpy as np

parser = argparse.ArgumentParser(description="manipulate specfem3d xdmf moviedata")
parser.add_argument("--file", type=str, nargs="+", help="xdmf moviedata file")
parser.add_argument(
    "--outfile",
    type=str,
    default="aggregated_shakemovie_full.xdmf",
    help="xdmf aggregate output file",
)
args = parser.parse_args()

out_file = args.outfile

print(args.file)

readers = [meshio.xdmf.TimeSeriesReader(str(f)) for f in args.file]


points0, cells0 = readers[0].read_points_cells()
npoints = points0.shape[0]
nsteps = readers[0].num_steps

for r in readers[1:]:
    p, c = r.read_points_cells()
    if p.shape[0] != npoints:
        raise ValueError("number of points different")
    if len(c) != len(cells0) or any(
        cb.type != cells0[i].type or cb.data.shape != cells0[i].data.shape
        for i, cb in enumerate(c)
    ):
        raise ValueError("Cell topology different")
    if r.num_steps != nsteps:
        raise ValueError("number of timestep different")

with meshio.xdmf.TimeSeriesWriter(out_file) as writer:
    writer.write_points_cells(points0, cells0)

    for k in range(nsteps):
        t0, pd, _ = readers[0].read_data(k)
        names = set(pd.keys())

        aggregate_pdata = {}
        out_pdata = {}
        for name in names:
            out_pdata[name] = []
            out_pdata[name].append(np.asarray(pd[name]))

        for r in readers[1:]:

            t, pd, _ = r.read_data(k)
            for name in names:
                out_pdata[name].append(np.asarray(pd[name]))

        for name in names:
            stack_arr = np.stack(out_pdata[name], axis=0)
            mean_arr = np.mean(stack_arr, axis=0)
            max_arr = np.max(stack_arr, axis=0)
            aggregate_pdata[f"{name}_mean"] = mean_arr
            aggregate_pdata[f"{name}_max"] = max_arr

        writer.write_data(t0, point_data=aggregate_pdata)
