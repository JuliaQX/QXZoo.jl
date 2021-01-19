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
Maintains MLL of gate-calls and a set of the gates used.
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
    Circ(num_qubits)

Circ constructor for given number of qubits circuit. Registers Pauli and Hadamard gates during initialisation.
"""
function Circ(num_qubits::Int)
    circ_ops = DS.DLList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    gate_set = Set{Union{GateOps.GateSymbol, GateOps.GateSymbolP}}()
    return Circ(circ_ops, gate_set, num_qubits)
end

function Circ(num_qubits::Int, gate_set::Set{<:GateOps.AGateSymbol})
    circ_ops = DS.DLList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    return Circ(circ_ops, gate_set, num_qubits)
end

function num_qubits(circuit::Circ)::Int
    return circuit.num_qubits
end

function Base.:append!(circ::Circ, gc)
    add_gatecall!(circ, gc);
end


"""
    add_gatecall!(circ::Circ, gc::GateOps.AGateCall)

Adds the given gate call `gc` to the circuit at the end position.

# Examples
```julia-repl
julia> Circuit.add_gatecall!(circ, GateOps.x(4)) #Apply Paulix to qubit index 4
```
"""
function add_gatecall!(circ::Circ, gc::GateOps.GateCall1)
    if ~haskey(GateMap.gates, gc.gate_symbol)
        error("Gate $(gc.gate_symbol.label) not registered")
    end
    if ~(gc.gate_symbol in circ.gate_set)
        push!(circ.gate_set, gc.gate_symbol)
    end
    push!(circ.circ_ops, gc);
end

"""
    add_gatecall!(circ::Circ, gc::GateOps.AGateCall)

Adds the given gate call `gc` to the circuit at the end position.

# Examples
```julia-repl
julia> Circuit.add_gatecall!(circ, GateOps.c_paul_x(3,4)) #Apply C_Paulix to qubit index 3, controlled on 4
```
"""
function add_gatecall!(circ::Circ, gc::GateOps.GateCall2)
    if ~haskey(GateMap.gates, gc.gate_symbol)
        error("Gate $(gc.gate_symbol.label) not registered")
    end
    if ~(gc.gate_symbol in circ.gate_set)
        push!(circ.gate_set, gc.gate_symbol)
    end
    push!(circ.circ_ops, gc);
end

function Base.push!(circ::Circ, gc::GateOps.AGateCall)
    if ~haskey(GateMap.gates, gc.gate_symbol)
        throw("Gate $(gc.gate_symbol.label) not registered")
    end
    if ~(gc.gate_symbol in circ.gate_set)
        push!(circ.gate_set, gc.gate_symbol)
    end
    push!(circ.circ_ops, gc);
end


"""
    to_string(circ::Circ)

Convert the circuit to a string intermediate representation

# Examples
```julia-repl
julia> Circuit.add_gatecall!(circ, GateOps.paul_x(4)) #Apply Paulix to qubit index 4
```
"""
function to_string(circ::Circ)
    circ_buffer = IOBuffer()
    for (k,v) in circ.gate_map
        write(circ_buffer, )
    end
    for c in circ.circ_ops

    end
end

function to_file!(circ::Circ, file_name::String="circuit.out", file_ext::String="circuit.err")
    open(file_name * file_ext, "a") do io
        println(io, String(take!(circ.circ_buffer)))
    end
end

function dump(file_name::String)
    open(file_name, "a") do io
        println(io, circ_buffer.data)
    end
end


Base.show(io::IO, circ::Circ) = print(io, "$(circ.num_qubits) qubits with $(circ.circ_ops.len) gate-calls using $(length(circ.gate_set)) unique gates.")
Base.show(io::IO, m::MIME"text/plain", circ::Circ) = print(io, "$(circ.num_qubits) qubits with $(circ.circ_ops.len) gate-calls using $(length(circ.gate_set)) unique gates.")

Base.:sqrt(U::Symbol) = Symbol("s"*string(U));
Base.:adjoint(U::Symbol) = Symbol("a"*string(U));
Base.:copy(circ::Circ) = Circ(circ.circ_ops, circ.gate_set, circ.num_qubits);
Base.:+(circ::Circ, gc::GateOps.GateCall1) = add_gatecall!(circ, gc::GateOps.GateCall1)
Base.:+(circ::Circ, gc::GateOps.GateCall2) = add_gatecall!(circ, gc::GateOps.GateCall2)

# =========================================================================== #
# =========================================================================== #

end