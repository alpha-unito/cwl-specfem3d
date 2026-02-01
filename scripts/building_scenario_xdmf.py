#!/usr/bin/env python3

import meshio
import numpy as np
import argparse
import os
import csv

DEBUG = False

parser = argparse.ArgumentParser(description="manipulate specfem3d xdmf moviedata")
parser.add_argument("--file", type=str, nargs="+", help="xdmf moviedata file")
parser.add_argument("--outfile", type=str, default="aggregated_full.xdmf")
parser.add_argument("--scenario", type=str, default=None, help="CSV with columns: tarr,W (optional)")
parser.add_argument("--dt", type=float, required=True, help="from Par_file")
parser.add_argument("--seed", type=int, default=None)
args = parser.parse_args()

files = args.file
if not files:
    raise RuntimeError("No files matched pattern")

# --- read scenario or generate random weights ---
rows = []
if args.scenario is not None and os.path.exists(args.scenario):
    with open(args.scenario, "r", newline="") as f:
        r = csv.DictReader(f)
        for row in r:
            rows.append((float(row["tarr"]), float(row["W"])))
else:
    rng = np.random.default_rng(args.seed)
    for _ in files:
        rows.append((0.0, float(rng.random())))

if len(rows) != len(files):
    raise RuntimeError(f"Scenario rows ({len(rows)}) != number of files ({len(files)})")

tarrs = np.array([t for t, _ in rows], float)
Ws    = np.array([w for _, w in rows], float)
shifts = ((tarrs + 1e-12) / args.dt).astype(int)  # sj=int(tarr/DT) for tarr>=0

print("files:", files)
print("weights:", Ws)
print("tarr:", tarrs)
print("shifts:", shifts)

#readers = [meshio.xdmf.TimeSeriesReader(str(f)) for f in files]
with meshio.xdmf.TimeSeriesReader(str(files[0])) as r:
    print(r.filename)
    points0, cells0 = r.read_points_cells()
    npoints = points0.shape[0]
    nsteps = r.num_steps
    _, pd0, _ = r.read_data(0)
    names = list(pd0.keys())
    print(names)
    for k in range(nsteps):
        try:
            t, pd, _ = r.read_data(k)
        except Exception as e:
            print(f"ReadError on file={files[0]} k={k} (nsteps={nsteps})")
    
    out = {}
    for name in names:
        a0 = np.asarray(pd0[name])
        out[name] = np.zeros((nsteps,) + a0.shape, dtype=float)
        
    for k in range(nsteps):
        if k + shifts[0] >= nsteps:
            continue  # truncation: don't write beyond nsteps-1
        _, pd, _ = r.read_data(k)
        for name in names:
            out[name][k + shifts[0]] += Ws[0] * np.asarray(pd[name])

# accumulate: for each file j, add into shifted timestep k+s
for s, w, f in zip(shifts[1:], Ws[1:], files[1:]):
    with meshio.xdmf.TimeSeriesReader(str(f)) as r:
        print(r.filename)
                
        for k in range(nsteps):
            if k + s >= nsteps:
                continue  # truncation: don't write beyond nsteps-1
            try:
                _, pd, _ = r.read_data(k)  
            except Exception as e:
                print(f"ReadError: file={f} k={k} err={repr(e)}")
            for name in names:
                out[name][k + s] += w * np.asarray(pd[name])

# write once per timestep with all variables
with meshio.xdmf.TimeSeriesWriter(args.outfile) as writer:
    writer.write_points_cells(points0, cells0)
    for k in range(nsteps):
        point_data_k = {name: out[name][k] for name in names}
        writer.write_data(k * args.dt, point_data=point_data_k)

