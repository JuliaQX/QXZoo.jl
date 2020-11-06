module LinAlg

using Base
using LinearAlgebra
import QuantZoo.GateOps
import QuantZoo.DefaultGates

# =========================================================================== #
#                       Gate caching and retrieval
# =========================================================================== #

"""Module gate cache

Since many different circuits may use the same gates, keeping a module-global 
cache makes sense to avoid recreating them. Each subcircuit can have a subset of 
the global cache's gates."""
gates = Dict{Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, Function}()

function init_cache!() #gates::Dict{Union{<:GateOps.AGateSymbol, Function}, Function})
    push!(gates, DefaultGates.GateSymbols.p00 => p00)
    push!(gates, DefaultGates.GateSymbols.p10 => p10)
    push!(gates, DefaultGates.GateSymbols.p01 => p01)
    push!(gates, DefaultGates.GateSymbols.p11 => p11)
    push!(gates, DefaultGates.GateSymbols.I => I)
    push!(gates, DefaultGates.GateSymbols.H => h)
    push!(gates, DefaultGates.GateSymbols.x => x)
    push!(gates, DefaultGates.GateSymbols.y => y)
    push!(gates, DefaultGates.GateSymbols.z => z)
    push!(gates, DefaultGates.GateSymbols.H => h)
    push!(gates, DefaultGates.GateSymbols.r_x => r_x)
    push!(gates, DefaultGates.GateSymbols.r_y => r_y)
    push!(gates, DefaultGates.GateSymbols.r_z => r_z)
    push!(gates, DefaultGates.GateSymbols.r_phase => r_phase)
    return ;
end

"""
    cache_gate!(label::GateOps.AGateSymbol, mat::Matrix{<:Number})

Adds a mapping between label=>mat for fast retrieval of gates in circuit generation.

# Examples
```julia-repl
julia> QuantZoo.Translator.LinAlg.cache_gate!(QuantZoo.GateOps.GateSymbol(:mygate), mygate() = [ 1 1; 1 1])
```
"""
function cache_gate!(key::Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, mat_func::Function)
    if ~haskey(gate_cache, key)
        gate_cache[key] = mat_func
    end
    return ;
end

# =========================================================================== #
#                       Projection operators
# =========================================================================== #
function p00()::Matrix{<:Number}
    return [1 0; 0 0].+0im
end
function p01()::Matrix{<:Number}
    return [0 1; 0 0].+0im
end
function p10()::Matrix{<:Number}
    return [0 0; 1 0].+0im
end
function p11()::Matrix{<:Number}
    return [0 0; 0 1].+0im
end
# =========================================================================== #
#                       Pauli operators
# =========================================================================== #
function x()::Matrix{<:Number}
    return [0 1; 1 0].+0im
end

function y()::Matrix{<:Number}
    return [0 -1im; 1im 0]
end

function z()::Matrix{<:Number}
    return [1 0; 0 -1].+0im
end
# =========================================================================== #
#                       Additional operators
# =========================================================================== #
function h()::Matrix{<:Number}
    return (1/sqrt(2)).*[1 1; 1 -1].+0im
end

function I()::Matrix{<:Number}
    return LinearAlgebra.I(2)
end

# =========================================================================== #
#                       Rotation operators
# =========================================================================== #
function r_x(θ::Number)::Matrix{<:Number}
    return exp(-1im*x()*θ/2)
end

function r_y(θ::Number)::Matrix{<:Number}
    return exp(-1im*y()*θ/2)
end

function r_z(θ::Number)::Matrix{<:Number}
    return exp(-1im*z()*θ/2)
end

function r_phase(θ::Number)::Matrix{<:Number}
    return [1 0; 0 exp(1im*θ)]
end

# =========================================================================== #
end