module Evolution

using QXZoo.Circuit
using QXZoo.GateOps
using QXZoo.DefaultGates


"""
    apply_pauli_string(θ::Number, pauli_gates::Vector{GateCall1})

Create a circuit representating a given exp Pauli string (eg exp(-i0.5*X*X*Y*Y))

# Examples
```julia-repl
```
"""
function apply_pauli_string!(cct::Circuit.Circ, θ::Number, pauli_gates::Vector{GateCall1})
    coupling_map = [i.target for i in pauli_gates]
    gates = [i.gate_symbol for i in pauli_gates]
    @assert issubset(Set(gates), Set([DefaultGates.GateSymbols.x, DefaultGates.GateSymbols.y, DefaultGates.GateSymbols.z]))
    
    u_t = []
    for g in pauli_gates
        if g.gate_symbol === DefaultGates.GateSymbols.x
            push!(u_t, DefaultGates.h(g.target))
        elseif g.gate_symbol === DefaultGates.GateSymbols.y
            push!(u_t, DefaultGates.r_x(g.target, pi/2))
        end
    end

    #label = GateSymbol(Symbol("exp_"*string([i.label for i in gates]...)))

    for i in u_t
        cct << i
    end

    for i in 1:length(coupling_map)-1
        cct << DefaultGates.c_x(coupling_map[i], coupling_map[i+1])
    end

    cct << DefaultGates.r_z(coupling_map[end], θ)

    for i in reverse(1:length(coupling_map)-1)
        cct << DefaultGates.c_x(coupling_map[i], coupling_map[i+1])
    end

    for i in reverse(u_t)
        cct << adjoint(i)
    end

end


end