module GateMap

using Base
using LinearAlgebra
using StaticArrays
import QXZoo.GateOps
import QXZoo.DefaultGates

# =========================================================================== #
#                       Gate caching and retrieval
# =========================================================================== #

"""Module gate cache

Since many different circuits may use the same gates, keeping a module-global 
cache makes sense to avoid recreating them. Each subcircuit can have a subset of 
the global cache's gates."""
gates = Dict{Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, Function}()

# TODO
# const gates = let .... end

function init_cache() #gates::Dict{Union{<:GateOps.AGateSymbol, Function}, Function})
    push!(gates, DefaultGates.GateSymbols.p00 => p00)
    push!(gates, DefaultGates.GateSymbols.p10 => p10)
    push!(gates, DefaultGates.GateSymbols.p01 => p01)
    push!(gates, DefaultGates.GateSymbols.p11 => p11)
    push!(gates, DefaultGates.GateSymbols.I => I)
    push!(gates, DefaultGates.GateSymbols.H => h)
    push!(gates, DefaultGates.GateSymbols.x => x)
    push!(gates, DefaultGates.GateSymbols.y => y)
    push!(gates, DefaultGates.GateSymbols.z => z)
    push!(gates, DefaultGates.GateSymbols.c_x => c_x)
    push!(gates, DefaultGates.GateSymbols.c_y => c_y)
    push!(gates, DefaultGates.GateSymbols.c_z => c_z)
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
julia> QXZoo.Translator.LinAlg.cache_gate!(QXZoo.GateOps.GateSymbol(:mygate), mygate() = [ 1 1; 1 1])
```
"""
function cache_gate!(key::Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, mat_func::Function)
    if ~haskey(gates, key)
        gates[key] = mat_func
    end
    return ;
end

# =========================================================================== #
#                       Projection operators
# =========================================================================== #
function p00()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [1.0+0.0im 0.0; 0.0 0.0]
end
function p01()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 1.0+0.0im; 0.0 0.0]
end
function p10()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 0.0; 1.0+0.0im 0.0]
end
function p11()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 0.0; 0.0 1.0+0.0im]
end

# =========================================================================== #
#                       Pauli operators
# =========================================================================== #
function x()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 1.0+0.0im; 1.0+0.0im 0.0]
end

function y()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 -1.0im; 1.0im 0.0]
end

function z()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [1.0+0.0im 0.0; 0.0 -1.0+0.0im]
end
# =========================================================================== #
#                       Additional operators
# =========================================================================== #
function h()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return SMatrix{2,2}([1.0+0.0im 1.0+0.0im; 1.0+0.0im -1.0+0.0im].*(1/sqrt(2)))
end

function I()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return SMatrix{2,2}(LinearAlgebra.I(2))
end

# =========================================================================== #
#                       Rotation operators
# =========================================================================== #
function r_x(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*x()*θ/2)
end

function r_y(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*y()*θ/2)
end

function r_z(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*z()*θ/2)
end

function r_phase(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return [1 0; 0 exp(1im*θ)]
end

# =========================================================================== #
#                       Controlled Pauli operators
# =========================================================================== #
function c_x()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), x())
end

function c_y()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), y())
end

function c_z()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), z())
end

# =========================================================================== #
"""
Allow access directly using a gate-call for ease-of-use
"""
function Base.getindex(gc::Dict{GateOps.AGateSymbol, Matrix{<:Number}}, gs::GateOps.AGateCall)
    return gc[gs.gate_label]
end

function clear_cache()
    empty!(gates)
end

end