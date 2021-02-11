module Circuit

using DataStructures
using QXZoo.GateOps
using QXZoo.GateMap
using QXZoo.DefaultGates

include("utils/DLList.jl")
using .DS

export append!
export push!

# =========================================================================== #
#                  Circuit generation functions and structures
# =========================================================================== #

"""
    Circ

Structure for ordered quantum circuit gate operations. 
Maintains mutable Doubly Linked List (DLList) of gate-calls and a set of the gates used.
"""
struct Circ
    circ_ops::DS.DLList{<:GateOps.AGateCall}
    gate_set::Set{<:GateOps.AGateSymbol}
    num_qubits::Int
end

"""
    Circ()

Default constructor for empty circuit. Registers Pauli and Hadamard gates during initialisation.
"""
function Circ()
    circ_ops = DS.DLList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    gate_set = Set{Union{GateOps.GateSymbol, GateOps.GateSymbolP}}()
    return Circ(circ_ops, gate_set, 0)
end
"""
    Circ(num_qubits::Int)

Circ constructor for given number of qubits circuit. Registers Pauli and Hadamard gates during initialisation.
"""
function Circ(num_qubits::Int)
    circ_ops = DS.DLList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    gate_set = Set{Union{GateOps.GateSymbol, GateOps.GateSymbolP}}()
    return Circ(circ_ops, gate_set, num_qubits)
end
"""
    Circ(num_qubits::Int, gate_set::Set{<:GateOps.AGateSymbol})

Circ constructor for given number of qubits circuit. Registers Pauli and Hadamard gates during initialisation, and the included gate_set.
"""
function Circ(num_qubits::Int, gate_set::Set{<:GateOps.AGateSymbol})
    circ_ops = DS.DLList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    return Circ(circ_ops, gate_set, num_qubits)
end

"""
    num_qubits(circuit::Circ)::Int

Return the number of qubits for the given circuit.
"""
function num_qubits(circuit::Circ)::Int
    return circuit.num_qubits
end

function Base.:append!(circ::Circ, gc)
    add_gatecall!(circ, gc);
end

function Base.:append!(circ1::Circ, circ2::Circ)
    if circ1.num_qubits == circ2.num_qubits
        append!(circ1.circ_ops, circ2.circ_ops);
        union!(circ1.gate_set, circ2.gate_set);
        empty!(circ2.gate_set);
    else
        error("Number of qubits incompatible between circuits: $(circ1.num_qubits), $(circ2.num_qubits)")
    end
end

"""
    add_gatecall!(circ::Circ, gc::GateOps.AGateCall)

Adds the given gate call `gc` to the circuit at the end position.

# Example 1
```julia-repl
julia> Circuit.add_gatecall!(circ, DefaultGates.x(4)) #Apply Paulix to qubit index 4
```
This functionality is also added by overloading `<<` and used as:
# Example 2
```julia-repl
julia> circ << GateOps.x(4) #Apply Paulix to qubit index 4
```
"""
function add_gatecall!(circ::Circ, gc::GateOps.AGateCall)
    if circ.num_qubits < gc.target
        error("Target is outside qubit register range")
    end
    if gc isa GateOps.GateCall2 && circ.num_qubits < gc.ctrl
        error("Ctrl is outside qubit register range")
    end
    if ~haskey(GateMap.gates, gc.gate_symbol)

        if (typeof(gc.gate_symbol) == GateOps.GateSymbolP) && (isdefined(GateMap, gc.gate_symbol.label) )
            GateMap.cache_gate!(gc.gate_symbol, ()->getproperty(GateMap, gc.gate_symbol.label)(gc.gate_symbol.param) )

        elseif haskey(GateMap.gates, GateOps.GateSymbol(gc.gate_symbol.label, 0, false) ) && (gc.gate_symbol.rt_depth != 0)
            GateMap.cache_gate!(gc.gate_symbol, ()->GateMap.gates[GateSymbol(gc.gate_symbol.label, 0, false)]()^(1/2^(gc.gate_symbol.rt_depth)) )

        elseif haskey(GateMap.gates, GateOps.GateSymbol(gc.gate_symbol.label, gc.gate_symbol.rt_depth, false) ) && (gc.gate_symbol.is_adj == true) #handle non-param adjoint gates
            GateMap.cache_gate!(gc.gate_symbol, ()->adjoint(GateMap.gates[GateOps.GateSymbol(gc.gate_symbol.label, gc.gate_symbol.rt_depth, false)]()) )

        else
            error("Gate $(gc.gate_symbol.label) not registered")
        end
    end
    if ~(gc.gate_symbol in circ.gate_set)
        push!(circ.gate_set, gc.gate_symbol)
    end
    push!(circ.circ_ops, gc);
end

function Base.push!(circ::Circ, gc::GateOps.AGateCall)
    if ~haskey(GateMap.gates, gc.gate_symbol)
        throw("Gate $(gc.gate_symbol) not registered")
    end
    if ~(gc.gate_symbol in circ.gate_set)
        push!(circ.gate_set, gc.gate_symbol)
    end
    push!(circ.circ_ops, gc);
end


Base.show(io::IO, circ::Circ) = print(io, "$(circ.num_qubits) qubits with $(circ.circ_ops.len) gate-calls using $(length(circ.gate_set)) unique gates.")
Base.show(io::IO, m::MIME"text/plain", circ::Circ) = print(io, "$(circ.num_qubits) qubits with $(circ.circ_ops.len) gate-calls using $(length(circ.gate_set)) unique gates.")

Base.:sqrt(U::Symbol) = Symbol("s"*string(U));
Base.:adjoint(U::Symbol) = Symbol("a"*string(U));
Base.:copy(circ::Circ) = Circ(circ.circ_ops, circ.gate_set, circ.num_qubits);
Base.:<<(circ::Circ, gc::GateOps.GateCall1) = add_gatecall!(circ, gc::GateOps.GateCall1)
Base.:<<(circ::Circ, gc::GateOps.GateCall2) = add_gatecall!(circ, gc::GateOps.GateCall2)
Base.:<<(circ1::Circ, circ2::Circ) = append!(circ1::Circ, circ2::Circ)

# =========================================================================== #
# =========================================================================== #

end