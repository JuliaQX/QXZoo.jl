"""
    QXZoo.jl - implementation of circuit generator for 
    different quantum algorithms.
"""
module QXZoo

using Reexport

include("gates/gate_ops.jl")
include("gates/default_gates.jl")
include("gates/gate_map.jl")
include("gates/composite_gates.jl")

include("circuits/circuit.jl")
include("algorithms/Algorithms.jl")

@reexport using QXZoo.GateMap
@reexport using QXZoo.GateOps
@reexport using QXZoo.DefaultGates
@reexport using QXZoo.CompositeGates
@reexport using QXZoo.Circuit

# Initialise default gates into cache
GateMap.init_cache()

end 
