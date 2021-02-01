module GateMap
# =========================================================================== #
#                           Imported modules
# =========================================================================== #

using Base
using LinearAlgebra
using StaticArrays
import QXZoo.GateOps
import QXZoo.DefaultGates

# =========================================================================== #
#                           Exported functions
# =========================================================================== #

export create_gate_1q, create_gate_2q

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

"""
    init_cache()

Initialise the cache for default gates used in circuit generation. Modules generating
gates not stored here should cache them for use by other circuits.

"""
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
    
    push!(gates, DefaultGates.GateSymbols.c_r_x => c_r_x)
    push!(gates, DefaultGates.GateSymbols.c_r_y => c_r_y)
    push!(gates, DefaultGates.GateSymbols.c_r_z => c_r_z)
    push!(gates, DefaultGates.GateSymbols.c_r_phase => c_r_phase)

    push!(gates, DefaultGates.GateSymbols.s => s )
    push!(gates, DefaultGates.GateSymbols.t => t )
    return ;
end

# =========================================================================== #
#                       Custom gate storage: 1 qubit
# =========================================================================== #

"""
    create_gate_1q(gate_label::String, gen_func::Function)

Creates a new user-defined gate, caches the generating function, and returns the
GateOps.GateSymbol key for use in a circuit.

# Examples
```julia-repl

```
"""
function create_gate_1q(gate_label::String, gen_func::Function)
    mat2x2 = nothing
    if applicable(gen_func, pi/2)
        mat2x2 = gen_func(pi/2)
        println("Parametric gate verified with arg=pi/2: $mat2x2")
    else
        mat2x2 = gen_func()
        println("Static gate verified: $mat2x2")
    end
    if size(mat2x2) != (2,2)
        error("Please ensure generated matrix is 2x2")
    end
    gs = GateOps.GateSymbol(Symbol(gate_label))
    cache_gate!(gs, gen_func)
    return gs
end


"""
    create_gate_1q(gate_label::String, mat::SArray{Tuple{2,2},Complex{Float64},2,4})

Creates a new user-defined gate, caches the generating matrix, and returns the
GateOps.GateSymbol key for use in a circuit.

# Examples
```julia-repl

```
"""
function create_gate_1q(gate_label::String, mat::SArray{Tuple{2,2},Complex{Float64},2,4})
    return create_gate_1q(gate_label, ()->mat)
end

"""
    create_gate_1q(gate_label::String, mat::Array{Complex{Float64},2})

Creates a new user-defined gate, caches the generating matrix, and returns the
GateOps.GateSymbol key for use in a circuit. Matrix is converted to 2x2 StaticArrays
SMatrix internally.

# Examples
```julia-repl

```
"""
function create_gate_1q(gate_label::String, mat::Array{<:Number,2})
    return create_gate_1q(gate_label, SArray{Tuple{2,2},Complex{Float64},2,4}(mat))
end

# =========================================================================== #
#                       Custom gate storage: 2 qubit
# =========================================================================== #

"""
    create_gate_2q(gate_label::String, gen_func::Function)

Creates a new user-defined gate, caches the generating function, and returns the
GateOps.GateSymbol key for use in a circuit.

# Examples
```julia-repl

```
"""
function create_gate_2q(gate_label::String, gen_func::Function)
    mat4x4 = nothing
    if applicable(gen_func, pi/2)
        mat4x4 = gen_func(pi/2)
        println("Parametric gate verified with arg=pi/2: $mat4x4")
    else
        mat4x4 = gen_func()
        println("Static gate verified: $mat4x4")
    end
    if size(mat4x4) != (4,4)
        error("Please ensure generated matrix is 4x4")
    end
    gs = GateOps.GateSymbol(Symbol(gate_label)) 
    cache_gate!(gs, gen_func)
    return gs
end


"""
    create_gate_2q(gate_label::String, mat::SArray{Tuple{2,2},Complex{Float64},2,4})

Creates a new user-defined gate, caches the generating matrix, and returns the
GateOps.GateSymbol key for use in a circuit.

# Examples
```julia-repl

```
"""
function create_gate_2q(gate_label::String, mat::SArray{Tuple{4,4},Complex{Float64},2,16})
    return create_gate_2q(gate_label, ()->mat)
end
"""
    create_gate_2q(gate_label::String, mat::Array{Complex{Float64},2})

Creates a new user-defined gate, caches the generating matrix, and returns the
GateOps.GateSymbol key for use in a circuit. Matrix is converted to 2x2 StaticArrays
SMatrix internally.

# Examples
```julia-repl

```
"""
function create_gate_2q(gate_label::String, mat::Array{<:Number,2})
    return create_gate_2q(gate_label, SArray{Tuple{4,4},Complex{Float64},2,16}(mat))
end


# =========================================================================== #


"""
    cache_gate!(label::GateOps.AGateSymbol, mat::Matrix{<:Number})

Adds a mapping between label=>mat for fast retrieval of gates in circuit generation.

# Examples
```julia-repl
julia> QXZoo.GateMap.cache_gate!(QXZoo.GateOps.GateSymbol(:mygate), ()->[ 1 0; 0 1])
```
"""
function cache_gate!(key::Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, mat_func::Function)
    if ~haskey(gates, key)
        gates[key] = mat_func
    end
    return ;
end

"""
    replace_gate!(label::GateOps.AGateSymbol, mat::Matrix{<:Number})

Replaces existing gate mapping as defined with cache_gate! otherwise performs no-op.

# Examples
```julia-repl
julia> QXZoo.GateMap.replace_gate!(QXZoo.GateOps.GateSymbol(:mygate), ()->[ 1 0; 0 -1])
```
"""
function replace_gate!(key::Union{GateOps.GateSymbol, GateOps.GateSymbolP, Function}, mat_func::Function)
    if haskey(gates, key)
        gates[key] = mat_func
    end
    return ;
end

# =========================================================================== #
#                       Projection operators
# =========================================================================== #
"""
    p00()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the |0><0| projector gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.p00()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```
"""
function p00()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [1.0+0.0im 0.0; 0.0 0.0]
end

"""
    p01()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the |0><1| projector gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.p01()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.0+0.0im  1.0+0.0im
 0.0+0.0im  0.0+0.0im
```
"""
function p01()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 1.0+0.0im; 0.0 0.0]
end

"""
    p10()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the |1><0| projector gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.p10()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.0+0.0im  0.0+0.0im
 1.0+0.0im  0.0+0.0im
```
"""
function p10()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 0.0; 1.0+0.0im 0.0]
end

"""
    p11()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the |1><1| projector gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.p11()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im
```
"""
function p11()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 0.0; 0.0 1.0+0.0im]
end

# =========================================================================== #
#                       Pauli operators
# =========================================================================== #
"""
    x()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the Pauli-X gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.x()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.0+0.0im  1.0+0.0im
 1.0+0.0im  0.0+0.0im
```
"""
function x()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 1.0+0.0im; 1.0+0.0im 0.0]
end

"""
    y()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the Pauli-Y gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.y()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.0+0.0im  -0.0-1.0im
 0.0+1.0im   0.0+0.0im
```
"""
function y()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [0.0 -1.0im; 1.0im 0.0]
end

"""
    z()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the Pauli-Z gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.z()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im   0.0+0.0im
 0.0+0.0im  -1.0+0.0im
```
"""
function z()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return @SMatrix [1.0+0.0im 0.0; 0.0 -1.0+0.0im]
end

# =========================================================================== #
#                       Additional operators
# =========================================================================== #

"""
    h()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the Hadamard gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.h()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.707107+0.0im   0.707107+0.0im
 0.707107+0.0im  -0.707107+0.0im
```
"""
function h()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return SMatrix{2,2}([1.0+0.0im 1.0+0.0im; 1.0+0.0im -1.0+0.0im].*(1/sqrt(2)))
end

"""
    I()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the 2x2 identity gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.I()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im
```
"""
function I()::Diagonal{Complex{Float64},SArray{Tuple{2},Complex{Float64},1,2}}
    return StaticArrays.SDiagonal(1.0+0im,1.0+0im)
end

"""
    s()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the S gate (sqrt(Z)).

# Examples
```julia-repl
julia> QXZoo.GateMap.s()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+1.0im
```
"""
function s()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return sqrt(z())
end

"""
    t()::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the T gate (sqrt(S)).

# Examples
```julia-repl
julia> QXZoo.GateMap.t()
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im       0.0+0.0im
 0.0+0.0im  0.707107+0.707107im
```
"""
function t()::SArray{Tuple{2,2},Complex{Float64},2,4}
    return sqrt(s())
end

# =========================================================================== #
#                       Rotation operators
# =========================================================================== #
"""
    r_x(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the parametric r_x gate: exp(-0.5im*θ*x())

# Examples
```julia-repl
julia> QXZoo.GateMap.r_x(pi/3)
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.866025+0.0im       0.0-0.5im
      0.0-0.5im  0.866025+0.0im
```
"""
function r_x(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*x()*θ/2)
end
"""
    r_y(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the parametric r_y gate: exp(-0.5im*θ*y())

# Examples
```julia-repl
julia> QXZoo.GateMap.r_y(pi/6)
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.965926+0.0im  -0.258819+0.0im
 0.258819+0.0im   0.965926+0.0im
```
"""
function r_y(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*y()*θ/2)
end
"""
    r_z(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the parametric r_z gate: exp(-0.5im*θ*z())

# Examples
```julia-repl
julia> QXZoo.GateMap.r_z(pi/2)
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 0.707107-0.707107im       0.0+0.0im
      0.0+0.0im       0.707107+0.707107im
```
"""
function r_z(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return exp(-1im*z()*θ/2)
end
"""
    r_phase(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}

Function which generates the parametric phase shifting gate [1 0; 0 exp(1im*θ)].
Note, this is not the Phase gate.

# Examples
```julia-repl
julia> QXZoo.GateMap.r_phase(pi/4)
2×2 StaticArrays.SArray{Tuple{2,2},Complex{Float64},2,4} with indices SOneTo(2)×SOneTo(2):
 1.0+0.0im       0.0+0.0im
 0.0+0.0im  0.707107+0.707107im
```
"""
function r_phase(θ::Number)::SArray{Tuple{2,2},Complex{Float64},2,4}
    return [1 0; 0 exp(1im*θ)]
end

# =========================================================================== #
#                       Controlled Pauli operators
# =========================================================================== #
"""
    c_x()::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled Pauli-X gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_x()
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  1.0+0.0im
 0.0+0.0im  0.0+0.0im  1.0+0.0im  0.0+0.0im
```
"""
function c_x()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), x())
end

"""
    c_y()::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled Pauli-X gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_y()
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  0.0-1.0im
 0.0+0.0im  0.0+0.0im  0.0+1.0im  0.0+0.0im
```
"""
function c_y()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), y())
end

"""
    c_z()::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled Pauli-X gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_z()
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im  0.0+0.0im   0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im   0.0+0.0im
 0.0+0.0im  0.0+0.0im  1.0+0.0im   0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  -1.0+0.0im
```
"""
function c_z()::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), z())
end

# =========================================================================== #
#                       Controlled rotation operators
# =========================================================================== #
"""
    c_r_x(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled parametric r_x gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_r_x(pi/3)
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im       0.0+0.0im       0.0+0.0im
 0.0+0.0im  1.0+0.0im       0.0+0.0im       0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.866025+0.0im       0.0-0.5im
 0.0+0.0im  0.0+0.0im       0.0-0.5im  0.866025+0.0im
```
"""
function c_r_x(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), r_x(θ)) 
end

"""
    c_r_y(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled parametric r_y gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_r_y(pi/4)
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im       0.0+0.0im        0.0+0.0im
 0.0+0.0im  1.0+0.0im       0.0+0.0im        0.0+0.0im
 0.0+0.0im  0.0+0.0im   0.92388+0.0im  -0.382683+0.0im
 0.0+0.0im  0.0+0.0im  0.382683+0.0im    0.92388+0.0im
```
"""
function c_r_y(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), r_y(θ)) 
end
"""
    c_r_z(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled parametric r_y gate as a block diagonal 4x4 matrix.

# Examples
```julia-repl
julia> QXZoo.GateMap.c_r_z(pi/6)
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im       0.0+0.0im            0.0+0.0im
 0.0+0.0im  1.0+0.0im       0.0+0.0im            0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.965926-0.258819im       0.0+0.0im
 0.0+0.0im  0.0+0.0im       0.0+0.0im       0.965926+0.258819im
```
"""
function c_r_z(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), r_z(θ)) 
end

"""
    c_r_phase(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}

Function which generates the controlled parametric phase shifting gate [1 0; 0 exp(1im*θ)] as a block diagonal 4x4 matrix.

Note, this is not the controlled Phase gate. 

# Examples
```julia-repl
julia> QXZoo.GateMap.c_r_phase(pi/9)
4×4 StaticArrays.SArray{Tuple{4,4},Complex{Float64},2,16} with indices SOneTo(4)×SOneTo(4):
 1.0+0.0im  0.0+0.0im  0.0+0.0im       0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im       0.0+0.0im
 0.0+0.0im  0.0+0.0im  1.0+0.0im       0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  0.939693+0.34202im
```
"""
function c_r_phase(θ::Number)::SArray{Tuple{4,4},Complex{Float64},2,16}
    return kron(p00(), I()) + kron(p11(), r_phase(θ)) 
end

# =========================================================================== #
"""
Allow access directly using a gate-call for ease-of-use
"""
function Base.getindex(gc::Dict{GateOps.AGateSymbol, Matrix{<:Number}}, gs::GateOps.AGateCall)
    return gc[gs.gate_label]
end

"""
    clear_cache()

Empty the stored gates from the cache.
"""
function clear_cache()
    empty!(gates)
end

end