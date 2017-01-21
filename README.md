[![Build Status](https://travis-ci.org/adcroft/workspace.svg?branch=master)](https://travis-ci.org/adcroft/workspace)

# workspace

**This Makefile is not part of MOM6, it is not supported, I do not recommend that anyone use it, and I will not respond to pleas for help regards this Makefile.** --The Managment.

This repository provides a "Makefile" that does pretty much everything I need to be able to regards MOM6 (install, build, test).

# Usage

## To obtain Makefile:
```bash
git clone git@github.com:adcroft/workspace.git workspace
```

## Installation

To clone code and tools (from within the `workspace` directory):
```bash
make clone
```

## Compilation

To compile all executables (from within the `workspace` directory):
```bash
make gnu
make intel
make pgi
```

To compile a specific executable (from within the `workspace` directory): 
```bash
make MOM6-examples/build/gnu/ocean_only/repro/MOM6
```

## Running (on batch nodes)
From within the `workspace` directory. To run all experiments with gnu, intel or pgi executables:

```bash
make gnu -j
make intel -j
make pgi -j
```

To run sub-sets of experiments:

```bash
make COMPILER=gnu solo -j
make COMPILER=gnu solo ale -j
make COMPILER=gnu sis sis2 -j
make COMPILER=gnu am2_sis am2_sis2 -j
```

To run a single experiment:
```bash
make MOM6-examples/ocean_only/global_ALE/z/ocean.stats.intel
```

Check status of experiments (from within `MOM6-examples`):
```bash
git status
```

# Working on the GFDL workstations

Obtain the Makefile:
```bash
git clone git@github.com:adcroft-gfdl/workspace.git workspace
```

Clone source code:
```bash
make CVS='cvs -d /home/fms/cvs' SITE=linux clone
```

Compile:
```bash
make SITE=linux FC=mpif77 CC=mpicc LD=mpif77 MPIRUN=mpirun MOM6-examples/build/intel/ocean_only/repro/MOM6
```

Run (requires the sourcing an "env"):
```bash
source MOM6-examples/build/intel/env
make MPIRUN=mpirun MOM6-examples/ocean_only/CVmix_SCM_tests/wind_only/EPBL/ocean.stats.intel
```

Compile and run in one step:
```bash
source MOM6-examples/build/intel/env
make SITE=linux FC=mpif77 CC=mpicc LD=mpif77 MPIRUN=mpirun MOM6-examples/ocean_only/CVmix_SCM_tests/wind_only/EPBL/ocean.stats.intel
```

Compile with openMP:
make BUILD_DIR=MOM6-examples/build-OPENMP MAKEMODE="OPENMP=1 NETCDF=3" MOM6-examples/build-OPENMP/intel/ice_ocean_SIS2/repro/MOM6
