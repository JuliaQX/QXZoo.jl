module QuantCircuit

using QuantZoo.GateOps
using QuantZoo.CircuitList
using DataStructures

export append!

# =========================================================================== #
#                       Gate caching and retrieval
# =========================================================================== #


"""Global gate cache

Since many different circuits may use the same gates, keeping a module-global 
cache makes sense to avoid recreating them. Each subcircuit can have a subset of 
the global cache's gates."""
gate_cache = Dict{GateOps.GateLabel, Matrix{<:Number}}(
    GateOps.GateLabel(:x)=>([0 1; 1 0].+0im),
    GateOps.GateLabel(:y)=>([0 -1im; 1im 0]),
    GateOps.GateLabel(:z)=>([1 0; 0 -1].+0im),
    GateOps.GateLabel(:h)=>((1/sqrt(2)).*[1 1; 1 -1].+0im),
)

"""
    add_to_cache(label::GateOps.GateLabel, mat::Matrix{<:Number})

Adds a mapping between label=>mat for fast retrieval of gates in circuit generation.

# Examples
```julia-repl
julia> Circuit.add_to_cache(GateOps.GateLabel(:x), [0 1;1 0].+0im)
```
"""
function add_to_cache(label::GateOps.GateLabel, mat::Matrix{<:Number})
    if ~haskey(gate_cache, label)
        gate_cache[label] = mat
    end
    return ;
end

# =========================================================================== #
#                  Output generation functions
# =========================================================================== #

function gate_to_str(g::GateOps.GateLabel)
    p=[]
    if g.params != nothing
        p = ["$(k)=$(v)_" for (k,v) in g.params]
    end
    return String(g.label) * "_" * string(p...)
end

# =========================================================================== #

"""
    create_gates_nonparam(gate_call::AGateCall)

    Create QASM syntax for gates cached in g_map_lg dictionary. 
    Single and controlled versions generated.
    Maps X^{1/2^n} gates to H Z^{1/2^n} H

"""
function create_gate_qasm(gate_call::GateOps.AGateCall)
    if isdefined(gate_call, :ctrl)
        ct = "ctrl,tgt";
        u_pre = "c"
    else
        ct = "tgt";
        u_pre = ""
    end
    label = gate_call.gate_label
    gate = gate_cache[label]

    # Problematic if z-gates not populated before x-gates; init to sufficient depth to prevent issues
    if String(label.gate_label)[end] == 'x'
        gl = typeof(label)
        gate_label_sub = gl(Symbol(String(label.gate_label)[1:end-1] * "z"))
        gate = gate_cache[gate_label_sub]
    end

    euler_vals = GateOps.mat_to_euler(gate)
    u3_vals = GateOps.zyz_to_u3(euler_vals...)

    # QASM and X^{1/2^n} gates do not work well, so map to H Z^{1/2^n} H
    if String(label.gate_label)[end] == 'x'
        g = """gate $(u_pre)$(label.gate_label) tgt{\nh tgt;\n$(u_pre)u3($(u3_vals[1]),$(u3_vals[2]),$(u3_vals[3])) tgt;\nh tgt;\n}"""
    elseif String(label.gate_label)[end] == 'z'
        g = """gate $(u_pre)$(label.gate_label) tgt{\n$(u_pre)u3($(u3_vals[1]),$(u3_vals[2]),$(u3_vals[3])) tgt;\n}"""
    else
        error("Unsupported gate: Pauli-X and Pauli-Z currently only supported")
    end

    return g
end

"""
Returns a single qubit QASM gate call
"""
function gate_to_qasm(g::GateOps.GateCall1)
    return "$(String(g.label)) $(g.reg)[$(g.target)];"
end

"""
Returns a two qubit QASM gate call
"""
function gate_to_qasm(g::GateOps.GateCall2)
    return "$(String(g.label)) $(g.reg)[$(g.ctrl)],$(g.reg)[$(g.target)];"

end

# =========================================================================== #
#                  Circuit generation functions and structures
# =========================================================================== #

"""
    Circ

Structure for ordered quantum circuit gate operations. 
Maintains MLL of gate-calls and a set of the gates used.
"""
struct Circ
    circ_ops::CircuitList.CList{<:GateOps.AGate}
    gate_set::Set{GateOps.GateLabel}
    num_qubits::Int
end

"""
    Circ()

Default constructor for empty circuit. Registers Pauli and Hadamard gates during initialisation.
"""
function Circ()
    circ_ops = CircuitList.CList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    gate_set = Set{GateOps.GateLabel}([
        GateOps.GateLabel(:x),
        GateOps.GateLabel(:y),
        GateOps.GateLabel(:z),
        GateOps.GateLabel(:h),
    ])
    return Circ(circ_ops, gate_set, 0)
end
"""
    Circ(num_qubits)

Circ constructor for given number of qubits circuit. Registers Pauli and Hadamard gates during initialisation.
"""
function Circ(num_qubits)
    circ_ops = CircuitList.CList{Union{GateOps.GateCall1, GateOps.GateCall2}}()
    gate_set = Set{GateOps.GateLabel}([
        GateOps.GateLabel(:x),
        GateOps.GateLabel(:y),
        GateOps.GateLabel(:z),
        GateOps.GateLabel(:h),
    ])
    return Circ(circ_ops, gate_set, num_qubits)
end

function Base.:append!(c1::Circ, c2::Circ)
    append!(c1.circ_ops, c2.circ_ops)
    union!(c1.gate_set, c2.gate_set)
end


"""
    add_gatecall!(circ::Circ, gc::GateOps.AGateCall)

Adds the given gate call `gc` to the circuit at the end position.

# Examples
```julia-repl
julia> Circuit.add_gatecall!(circ, GateOps.paul_x(4)) #Apply Paulix to qubit index 4
```
"""
function add_gatecall!(circ::Circ, gc::GateOps.GateCall1)
    if ~haskey(gate_cache, gc.gate_label)
        error("Gate $(gc.gate_label) not registered")
    end
    if ~(gc.gate_label in circ.gate_set)
        push!(circ.gate_set, gc.gate_label)
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
    if ~haskey(gate_cache, gc.base_gate.gate_label)
        error("Gate $(gc.gate_label) not registered")
    end
    if ~(gc.base_gate.gate_label in circ.gate_set)
        push!(circ.gate_set, gc.base_gate.gate_label)
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


###


"""
    apply_cx(q_ctrl::Int, q_tgt::Int)

Function to generate CX gate operation. Override function to implement different output formats

# Arguments
- `q_ctrl::Int`: 
- ` q_tgt::Int`: 
"""
function apply_cx(q_ctrl, q_tgt)
    println("cx $(q_ctrl),$(q_tgt);")
end

"""
    apply_cx(q_ctrl::Int, q_tgt::Int)

Function to generate CU gate operation. Override function to implement different output formats

# Arguments
- `q_ctrl::Int`: 
- ` q_tgt::Int`: 
"""
function apply_cu(q_ctrl, q_tgt, U)
    println("c$(U) $(q_ctrl),$(q_tgt);")
end

Base.:sqrt(U::Symbol) = Symbol("s"*string(U))
Base.:adjoint(U::Symbol) = Symbol("a"*string(U))

# =========================================================================== #
# =========================================================================== #

function get_qasm_gateset(circ::Circ)
    gs = ""
    for g in circ.gate_set
        if !(g in [:x,:y,:z,:h])
            # Create 1 qubit and 2 qubit (controlled) variants of gates
            gs *= create_gate_qasm(g, 1)
            gs *= create_gate_qasm(g, 2)
        end
    end
    return gs
end

##################################################################

"""
    gatelabel_to_qasm(gl::GateOps.GateLabel)

Defines an OpenQASM gate from the given GateLabel and matched matrix
"""
function gatelabel_to_qasm(gl::GateOps.GateLabel)
    if String(gl.label) in ["c_x", "x", "y", "z", "h"]
        return "\n"
    end

    u3_vals = GateOps.mat_to_u3( Circuit.gate_cache[gl] )

    qasm_gates = 
    """gate $(gl.label) tgt{
        u3($(u3_vals[1]),$(u3_vals[2]),$(u3_vals[3])) tgt;
    }
    gate c_$(gl.label) ctrl,tgt{
        cu3($(u3_vals[1]),$(u3_vals[2]),$(u3_vals[3])) ctrl,tgt;
    }
    """
    return qasm_gates
end

"""
    gatecall_to_qasm(gc::GateOps.GateCall1)

Convert a single-qubit gate call (GateCall1) to OpenQASM 
"""
function gatecall_to_qasm(gc::GateOps.GateCall1)
    gate_tag = gc.gate_label.label
    if gc.reg == nothing
        reg="q"
    else
        reg = gc.reg
    end
    return "$(gate_tag) $(reg)[$(gc.target)];\n"
end

"""
    gatecall_to_qasm(gc::GateOps.GateCall2)

Convert a two-qubit gate call (GateCall2) to OpenQASM 
"""
function gatecall_to_qasm(gc::GateOps.GateCall2)
    if gc.reg == nothing
        reg="q"
    else
        reg = gc.reg
    end
    if String(gc.gate_label.label) in ["c_x"]
        return "cx $(reg)[$(gc.ctrl)],$(reg)[$(gc.target)];\n"
    else
        gate_tag = gc.gate_label.label
        return "c_$(gate_tag) $(reg)[$(gc.ctrl)],$(reg)[$(gc.target)];\n"
    end
end

"""
    add_header(num_qubits::Int, reg::String="q", creg::String="c")

Returns the given OpenQASM header for number of quantum and classical bits.
"""
function add_header(num_qubits::Int, reg::String="q", creg::String="c")
    return """
    OPENQASM 2.0;
    include "qelib1.inc";
    qreg $(reg)[$(num_qubits)];
    creg $(creg)[$(num_qubits)];
    """
end

"""
    to_qasm(circ::Circ, header::Bool=true, filename::Union{String, Nothing}=nothing)

Convert a given circuit to OpenQASM.
"""
function to_qasm(circ::Circ, header::Bool=true, filename::Union{String, Nothing}=nothing)
    circ_buffer = IOBuffer()

    if header == true
        write(circ_buffer, add_header(circ.num_qubits))
    end

    for l in circ.gate_set
        write(circ_buffer, gatelabel_to_qasm(l))
    end

    for c in circ.circ_ops
        write(circ_buffer, gatecall_to_qasm(c))
    end
    
    if filename==nothing
        return circ_buffer.data
    else
        open(filename, "w") do f
            write(f, circ_buffer.data)
        end
    end
end

end