# Seismic wavefield simulation - CWL implementation

This repository contains a [Common Workflow Language](https://commonwl.org) (CWL) implementation of a seismic wavefield simulation workflow based on the [SPECFEM3D](https://specfem3d.readthedocs.io/en/latest/) software package.

## Description

The main SPECFEM3D workflow is described in the [specfem3d.cwl](./specfem3d.cwl) file. It accepts four input parameters:

- The `meshdir` folder, which stores a pre-generated mesh for the region under consideration;
- The `cmtsolution` file, which is the earthquake source parameter file;
- The `stations` file, which contains the coordinates of the receivers;
- The `parfile` file, which is the configuration file for the simulation process.

The workflow comprises three sequential steps:

- **Mesh decomposition**: given an input mesh stored in the `meshdir` folder and a number of target processes configured in the `parfile` input, the `xdecompose_mesh` partitions the mesh to allow for parallel processing;
- **Database generation**: after the decomposition step, the `xgenerate_databases` command creates all the missing information needed by the SEM parallel solver;
- **Wavefield simulation**: finally, the `xspecfem3D` command executes the wavefield simulation.

The first step is always sequential, while the other two rely on MPI for parallel/distributed execution whenever the number of processes exceeds one.

This workflow can also run multiple simulations on the same mesh in parallel. The [main.cwl](./main.cwl) file accepts an array of input simulation files (i.e., `cmtsolutions`, `parfiles`, and `stations` files) and runs an entire simulation process for each configuration. The [config.yml](./config.yml) file shows an example of input parameters for the workflow.

## Usage

Running this workflow requires a [CWL runner](https://www.commonwl.org/implementations/). For example, the CWL reference implementation, called [cwltool](https://github.com/common-workflow-language/cwltool), can be installed as follows:

```bash
python3 -m venv venv
source venv/bin/activate
pip install cwlref-runner
```

Note that this workflow does not build the SPECFEM3D suite from scratch. Instead, it expects that all SPECFEM3D-related commands are available in the user's `$PATH`. Please follow the [official documentation](https://specfem3d.readthedocs.io/en/latest/02_getting_started/) to build and configure SPECFEM3D in your target execution environment.

Once all software and data dependencies are installed, the workflow can be launched using the following command:

```bash
cwl-runner main.cwl config.yml
```

## Acknowledgment

This work has been partially supported by the [EUPEX](https://eupex.eu/) project, "European Pilot for Exascale," which has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No. 101033975.

This work partially builds on a previous CWL implementation of SPECFEM3D workflow realised in the context of the [DARE](http://project-dare.eu/) project, "Delivering Agile Research Excellence on European e-Infrastructures," which has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No. 777413.