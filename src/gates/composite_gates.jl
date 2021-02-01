module CompositeGates

export xx,yy,zz,swap,iswap

using QXZoo.GateOps
using QXZoo.DefaultGates
using QXZoo.GateMap
using StaticArrays

module GateSymbols
    using QXZoo.GateOps
    
    """Two qubit"""
    swap = GateOps.GateSymbol(:swap)
    iswap = GateOps.GateSymbol(:iswap)

    xx(θ) = GateOps.GateSymbolP(:xx, 0, false, θ)
    yy(θ) = GateOps.GateSymbolP(:yy, 0, false, θ)
    zz(θ) = GateOps.GateSymbolP(:zz, 0, false, θ)

    """Three qubit"""
    c_c_x = GateOps.GateSymbol(:c_c_x)
    c_swap = GateOps.GateSymbol(:c_swap)
end

"""
    xx(q_target1::Int, q_target2::Int, theta::Real)

Generate a XX parametric gate-equivalent circuit, composed of fundamental gate operations (H, CX, Rz)

# Examples
```julia-repl
```
"""
function xx(q_target1::Int, q_target2::Int, θ::Number)
    if ~haskey(GateMap.gates, GateSymbols.xx(θ)) # Build XX matrix if not available
        GateMap.cache_gate!(GateSymbols.xx(θ), (θ)->exp(1im*θ*(kron(GateMap.x(),GateMap.x()))))
    end
    return GateOps.GateCall2(GateSymbols.xx(θ), q_target1, q_target2, nothing)
end

"""
    yy(q_target1::Int, q_target2::Int, theta::Real)

Generate a YY parametric gate, which can be constructed from fundamental 1 & 2 qubit operations

# Examples
```julia-repl
```
"""
function yy(q_target1::Int, q_target2::Int, θ::Number)
    if ~haskey(GateMap.gates, GateSymbols.yy(θ)) # Build YY matrix if not available
        GateMap.cache_gate!(GateSymbols.yy(θ), (θ)->exp(1im*θ*(kron(GateMap.y(),GateMap.y()))))
    end
    return GateOps.GateCall2(GateSymbols.yy(θ), q_target1, q_target2, nothing)
end

"""
    zz(q_target1::Int, q_target2::Int, theta::Real)

Generate a ZZ parametric gate, which can be constructed from fundamental 1 & 2 qubit operations

# Examples
```julia-repl
```
"""
function zz(q_target1::Int, q_target2::Int, θ::Number)
    if ~haskey(GateMap.gates, GateSymbols.zz(θ)) # Build YY matrix if not available
        GateMap.cache_gate!(GateSymbols.zz(θ), (θ)->exp(1im*θ*(kron(GateMap.z(),GateMap.z()))))
    end
    return GateOps.GateCall2(GateSymbols.zz(θ), q_target1, q_target2, nothing)
end

"""
    swap(q_target1::Int, q_target2::Int)

Generate a SWAP gate equivalent circuit, composed of fundamental gate operations (CX)

# Examples
```julia-repl
```
"""
function swap(q_target1::Int, q_target2::Int)
    if ~haskey(GateMap.gates, GateSymbols.swap) # Build SWAP matrix if not available
        GateMap.cache_gate!(GateSymbols.swap, ()->
            @SMatrix ([1 0 0 0; 0 0 1.0+0im 0; 0 1.0+0im 0 0; 0 0 0 1])
        )
    end
    return GateOps.GateCall2(GateSymbols.swap, q_target1, q_target2, nothing)
end

"""
    iswap(q_target1::Int, q_target2::Int)

Generate a iSWAP gate equivalent circuit, generatable using 
`exp(1im*(pi/4)*(kron(GateMap.x(),GateMap.x()) + kron(GateMap.y(),GateMap.y())))`

# Examples
```julia-repl
```
"""
function iswap(q_target1::Int, q_target2::Int)
    if ~haskey(GateMap.gates, GateSymbols.iswap) # Build iSWAP matrix if not available
        GateMap.cache_gate!(GateSymbols.iswap, ()->
            @SMatrix ([1 0 0 0; 0 0 1.0im 0; 0 1.0im 0 0; 0 0 0 1])
        )
    end
    return GateOps.GateCall2(GateSymbols.iswap, q_target1, q_target2, nothing)
end

end