module CompositeGates

using QXZoo.GateOps
using QXZoo.DefaultGates
using QXZoo.Circuit

module GateSymbols
    using QXZoo.GateOps
    
    """Two qubit"""
    swap = GateOps.GateSymbol(:swap)
    iswap = GateOps.GateSymbol(:iswap)

    xx(θ) = GateOps.GateSymbolP(Symbol("xx(" * string(θ) * ")"), Dict("θ"=>θ))
    yy(θ) = GateOps.GateSymbolP(Symbol("yy(" * string(θ) * ")"), Dict("θ"=>θ))
    zz(θ) = GateOps.GateSymbolP(Symbol("zz(" * string(θ) * ")"), Dict("θ"=>θ))

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
function xx(q_target1::Int, q_target2::Int, theta::Real)
    cct = Circuit.Circ()
    Circuit.add_gates!(cct, DefaultGates.h(q_target1))
    Circuit.add_gates!(cct, DefaultGates.h(q_target2))    
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    Circuit.add_gates!(cct, DefaultGates.h(q_target1))
    Circuit.add_gates!(cct, DefaultGates.h(q_target2))    
    return cct
end


"""
    swap(q_target1::Int, q_target2::Int)

Generate a SWAP gate equivalent circuit, composed of fundamental gate operations (CX)

# Examples
```julia-repl
```
"""
function swap(q_target1::Int, q_target2::Int)
    cct = Circuit.Circ() 
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target2, q_target1))
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    return cct
end

"""
    iswap(q_target1::Int, q_target2::Int)

Generate a iSWAP gate equivalent circuit, composed of fundamental gate operations (CX)

# Examples
```julia-repl
```
"""
function iswap(q_target1::Int, q_target2::Int)
    cct = Circuit.Circ() 
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target2, q_target1))
    Circuit.add_gates!(cct, DefaultGates.c_x(q_target1, q_target2))
    return cct
end



end