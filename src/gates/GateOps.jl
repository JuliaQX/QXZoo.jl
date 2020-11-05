module GateOps

################################### Exports ###################################

export AGate, AGateSymbol, AGateCall
export GateSymbol, GateCall1, GateCall2, GateCallN, Gate

################################ Abstract types ###############################

"Abstract Gate type"
abstract type AGate end
"Abstract Gate Label, for unique gates"
abstract type AGateSymbol <: AGate end
"Abstract Gate Call, for tracking Gate labels applied to specific qubits"
abstract type AGateCall <: AGate end

################################ Gate structs #################################

"Gate label with params. Tracks the gate symbol (:x,:y,:z, etc)"
struct GateSymbolP <: AGateSymbol
    label::Symbol
    params::Union{Nothing, Dict{String, Union{Number, Bool}}}
    GateSymbolP(label, params) = new(label, params)
    GateSymbolP(label) = new(label, nothing)
end

"Gate label. Tracks the gate symbol (:x,:y,:z, etc)"
struct GateSymbol <: AGateSymbol
    label::Symbol
    GateSymbol(label) = new(label)
end

"Single qubit Gate call. Has a GateSymbol, target qubit index 
and register label"
struct GateCall1 <: AGateCall
    gate_label::GateSymbol
    target::Integer
    reg::Union{String, Nothing}
    GateCall1P(gate_label, target, reg) = new(gate_label, target, reg)
    GateCall1P(gate_label, target) = new(gate_label, target, nothing)
end

"""
Two qubit Gate call. 
Has a GateSymbol, control and target qubit indices, register 
label, and base gate.
"""
struct GateCall2 <: AGateCall
    gate_label::GateSymbol
    ctrl::Integer
    target::Integer
    base_gate::Union{GateSymbol, Nothing}
    reg::Union{String, Nothing}

    GateCall2P(gate_label, ctrl, target, base_gate, reg) = 
    new(gate_label, ctrl, target, base_gate, reg)

    GateCall2P(gate_label, ctrl, target, base_gate) = 
    new(gate_label, ctrl, target, base_gate, nothing)

    GateCall2P(gate_label, ctrl, target) = 
    new(gate_label, ctrl, target, nothing, nothing)
end

"""
n-qubit Gate call. 
Has a GateSymbol, control vector indices, target qubit index, 
register label, and base gate.
"""
struct GateCallN <: AGateCall
    gate_label::GateSymbol
    ctrl::Union{Integer, Vector{Integer}}
    target::Integer
    base_gate::Union{GateSymbol, Nothing}
    reg::Union{String, Nothing}

    GateCallNP(gate_label, ctrl, target, base_gate, reg) = 
    new(gate_label, ctrl, target, base_gate, reg)

    GateCallNP(gate_label, ctrl, target, base_gate) = 
    new(gate_label, ctrl, target, base_gate, nothing)

    GateCallNP(gate_label, ctrl, target) = 
    new(gate_label, ctrl, target, nothing, nothing)
end

"""
Wrap of Matrix to fit type system hierarchy
"""
struct Gate <: AGate
    mat::Matrix{<:Number}
    Gate(mat) = new(mat)
end

###############################################################################

end