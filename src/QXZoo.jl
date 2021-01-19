"""
    QXZoo.jl - implementation of circuit generator for 
    different quantum algorithms.
"""
module QXZoo

include("gates/gate_ops.jl")
include("gates/default_gates.jl")
include("gates/gate_map.jl")
include("circuits/circuit.jl")
include("circuits/composite_gates.jl")
include("translators/Translator.jl")
include("translators/Transpiler.jl")
include("algorithms/Algorithms.jl")

# Initialise default gates into cache
GateMap.init_cache()

end 
