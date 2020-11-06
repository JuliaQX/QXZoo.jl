include("LinAlg.jl")
using .LinAlg


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