module GateMap


using Base
using QuantZoo.GateOps
using QuantZoo.DefaultGates

# =========================================================================== #
#                       Gate caching and retrieval
# =========================================================================== #

"""Module gate cache

Since many different circuits may use the same gates, keeping a module-global 
cache makes sense to avoid recreating them. Each subcircuit can have a subset of 
the global cache's gates."""
gate_cache = Dict{GateOps.AGateSymbol, Matrix{<:Number}}()

function init_cache()
    push!(gate_cache, DefaultGates.GateSymbols.x => ([0 1; 1 0].+0im))
    push!(gate_cache, DefaultGates.GateSymbols.y => ([0 -1im; 1im 0]))
    push!(gate_cache, DefaultGates.GateSymbols.z => ([1 0; 0 -1].+0im))
    push!(gate_cache, DefaultGates.GateSymbols.H => ((1/sqrt(2)).*[1 1; 1 -1].+0im))
    return gate_cache
end

"""
Allow access directly using a gate-call for ease-of-use
"""
function Base.getindex(gc::Dict{GateOps.AGateSymbol, Matrix{<:Number}}, gs::GateOps.AGateCall)
    return gc[gs.gate_label]
end

"""
    add_to_cache(label::GateOps.AGateSymbol, mat::Matrix{<:Number})

Adds a mapping between symbol=>mat for fast retrieval of gates in circuit generation.

# Examples
```julia-repl
julia> Circuit.add_to_cache(GateOps.GateLabel(:x), [0 1;1 0].+0im)
```
"""
function add_to_cache(symbol::GateOps.AGateSymbol, mat::Matrix{<:Number})
    if ~haskey(gate_cache, symbol)
        gate_cache[symbol] = mat
    end
    return ;
end

function clear_cache()
    empty!(d1)
end

end