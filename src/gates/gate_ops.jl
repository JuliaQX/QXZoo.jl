module GateOps

################################### Exports ###################################

export AGate, AGateSymbol, AGateCall
export GateSymbol, GateSymbolP, GateCall1, GateCall2, GateCallN, Gate

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
    param::Number
    GateSymbolP(label, rt_depth, is_adj, param) = new(label, rt_depth, is_adj, param)
    GateSymbolP(label, rt_depth, is_adj) = new(label, rt_depth, is_adj, 0)
    GateSymbolP(label, rt_depth) = new(label, rt_depth, false, 0)
    GateSymbolP(label) = new(label, 0, false, 0)
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
#                                  Utilities
###############################################################################
Base.:sqrt(gs::GateSymbol) = GateSymbol(gs.label, gs.rt_depth+1, gs.is_adj)
Base.:adjoint(gs::GateSymbol) = GateSymbol(gs.label, gs.rt_depth, ~gs.is_adj)
Base.:adjoint(gs::GateSymbolP) = GateSymbolP(gs.label, gs.rt_depth, ~gs.is_adj, -gs.param)

Base.:sqrt(gc::GateCall1) = GateCall1(sqrt(gc.gate_symbol), gc.target)
Base.:adjoint(gc::GateCall1) = GateCall1(adjoint(gc.gate_symbol), gc.target)
Base.:sqrt(gc::GateCall2) = GateCall2(sqrt(gc.gate_symbol), gc.ctrl, gc.target, gc.base_gate)
Base.:adjoint(gc::GateCall2) = GateCall2(adjoint(gc.gate_symbol), gc.ctrl, gc.target, gc.base_gate)

end