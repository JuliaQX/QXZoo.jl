




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

"""
    gatelabel_to_qasm(gl::GateOps.GateSymbol)

Defines an OpenQASM gate from the given GateSymbol and matched matrix
"""
function gatelabel_to_qasm(gl::GateOps.GateSymbol)
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
    reg="q"
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



"""
    apply_cu!(c::circuit.Circ, ctrl, tgt, reg, gl::GateOps.GateSymbol)

Module-specific CU gate. Defaults to using the implementation from GateOps.
Override for custom functionality.
"""
function apply_cu!(cct::circuit.Circ, ctrl, tgt, reg, gl::GateOps.GateSymbol)
    if String(gl.label)[end] == 'x'
        glz_s = String(gl.label)[1:end-1] * 'z'
        gl_z = GateOps.GateSymbol(Symbol(glz_s))

        push!(cct.gate_set, gl_z)

        circuit.add_gatecall!(cct, DefaultGates.h(tgt, reg))
        circuit.add_gatecall!(cct, GateOps.c_u(gl_z, ctrl, tgt, GateOps.u( GateOps.GateSymbol(Symbol(split(glz_s, "c_")[end])), tgt, reg), reg))
        circuit.add_gatecall!(cct, DefaultGates.h(tgt, reg))

    elseif String(gl.label)[end] == 'z'
        circuit.add_gatecall!(cct, GateOps.c_u(gl, ctrl, tgt, GateOps.pauli_z(tgt, reg), reg))
    else
        error("Currently only PauliX and PauliZ decomposed gates supported")
    end
end
