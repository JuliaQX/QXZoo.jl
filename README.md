# QXZoo

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaQX.github.io/QXZoo.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaQX.github.io/QXZoo.jl/dev)
[![Build Status](https://github.com/JuliaQX/QXZoo.jl/workflows/CI/badge.svg)](https://github.com/JuliaQX/QXZoo.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaQX/QXZoo.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaQX/QXZoo.jl)


Circuit composition and translation package for QuantEx project.
Creates a backend-agnostic algorithm and circuit composition framework,
which can subsequently be used to generate quantum algorithm representations
for running on a variety of different backends.

Integrates with QXTools.jl to perform full end-to-end demonstrations
of quantum circuit simulation as part of the QuantEx project. It was developed 
as part of the QuantEx project, one of the individual software projects of WP8 
of PRACE 6IP.

## Installation

The prototype comes in the form of a Julia package which is targeted to versions
of Julia from v1.5 on. Binaries and source for this can be downloaded from
[https://julialang.org/](https://julialang.org/).

Once installed, from the Julia REPL prompt navigate to the QXZoo.jl folder
and activate the environment, instantiate it and then build QXZoo.jl.
This should install dependencies specified in the `Project.toml` and
`Manifest.toml` files as well as carry out any package specific build tasks
detailed in `deps/build.jl`. To use a custom python environment see the section
below on using different python environments.

```
]activate .
]instantiate
]build QXZoo
```

## Running the unittests

Unittests can be run from the QXZoo root folder with

```
julia --project=. tests/runtests.jl
```

## Building the documentation

This package uses Documenter.jl to generate html documentation from the sources.
To build the documentation, run the make.jl script from the docs folder.

```
cd docs && julia make.jl
```

The documentation will be placed in the build folder and can be hosted locally
by starting a local http server with

```
cd build && python3 -m http.server
```
