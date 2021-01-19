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
    rt_depth::Int
    is_adj::Bool
    params::Dict{String, Number}
    GateSymbolP(label, rt_depth, is_adj, params) = new(label, rt_depth, is_adj, params)
    GateSymbolP(label, rt_depth, is_adj) = new(label, rt_depth, is_adj, Dict{String, Number})
    GateSymbolP(label, rt_depth) = new(label, rt_depth, false, Dict{String, Number})
    GateSymbolP(label) = new(label, 0, false, Dict{String, Number})
end

"Gate label. Tracks the gate symbol (:x,:y,:z, etc)"
struct GateSymbol <: AGateSymbol
    label::Symbol
    rt_depth::Int
    is_adj::Bool
    GateSymbol(label) = new(label, 0, false)
    GateSymbol(label, rt_depth) = new(label, rt_depth, false)
    GateSymbol(label, rt_depth, is_adj) = new(label, rt_depth, is_adj)
end

"Single qubit Gate call. Has a GateSymbol, target qubit index"
struct GateCall1 <: AGateCall
    gate_symbol::AGateSymbol
    target::Integer
    GateCall1(gate_symbol, target) = new(gate_symbol, target)
end

"""
Two qubit Gate call. 
Has a GateSymbol, control and target qubit indices, and base gate.
"""
struct GateCall2 <: AGateCall
    gate_symbol::AGateSymbol
    ctrl::Integer
    target::Integer
    base_gate::Union{AGateSymbol, Nothing}
    GateCall2(gate_symbol, ctrl, target, base_gate) = 
    new(gate_symbol, ctrl, target, base_gate)

    GateCall2(gate_symbol, ctrl, target) = 
    new(gate_symbol, ctrl, target, nothing)
end

"""
n-qubit Gate call. 
Has a GateSymbol, control vector indices, target qubit index, and base gate.
"""
struct GateCallN <: AGateCall
    gate_symbol::AGateSymbol
    ctrl::Union{Integer, Vector{Integer}}
    target::Integer
    base_gate::Union{AGateSymbol, Nothing}

    GateCallN(gate_symbol, ctrl, target, base_gate) = 
    new(gate_symbol, ctrl, target, base_gate)

    GateCallN(gate_symbol, ctrl, target) = 
    new(gate_symbol, ctrl, target, nothing)
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