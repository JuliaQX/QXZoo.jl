"""
    QuantZoo.jl - implementation of circuit generator for 
    different quantum algorithms.
"""
module QuantZoo

include("gates/GateOps.jl")
include("gates/DefaultGates.jl")
include("gates/GateMap.jl")
include("translators/Translator.jl")

end 
