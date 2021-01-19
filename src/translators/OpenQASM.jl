
module OpenQASM_Translator

using QXZoo
using QXZoo.GateOps
using QXZoo.DefaultGates
using StaticArrays
using LinearAlgebra
using QXZoo.GateMap
using QXZoo.Circuit
using QXZoo.NCU
using Memoize


################################ OpenQASM Translator struct #################################

mutable struct OpenQASM #<: ATranslator
    gate_gen::Dict{Union{QXZoo.GateOps.GateSymbol, Function}, Function}
    version::Float64
    custom_gates::String
    header::String
    cct::String
    OpenQASM(version) = new(gate_map(), version, "", "", "")
end

######################## OpenQASM translate method ##########################


function translate!(tlr::OpenQASM, cct::Circuit.Circ)
    add_header!(tlr, cct.num_qubits)
    ii=1
    for gc in cct.circ_ops
        println(ii)
        println(gc)
        add_gate!(tlr, gc)
        ii+=1
    end
    return tlr.header * tlr.custom_gates * tlr.cct
end


######################## OpenQASM default gate-set mappings ##########################

function gate_map()
    gates = Dict{Union{QXZoo.GateOps.GateSymbol, Function}, Function}()
    #push!(gates, DefaultGates.GateSymbols.p00 => p00)
    #push!(gates, DefaultGates.GateSymbols.p10 => p10)
    #push!(gates, DefaultGates.GateSymbols.p01 => p01)
    #push!(gates, DefaultGates.GateSymbols.p11 => p11)
    #push!(gates, DefaultGates.GateSymbols.I => I)
    push!(gates, DefaultGates.GateSymbols.H => h)
    push!(gates, DefaultGates.GateSymbols.x => x)
    push!(gates, DefaultGates.GateSymbols.y => y)
    push!(gates, DefaultGates.GateSymbols.z => z)
    push!(gates, DefaultGates.GateSymbols.c_x => c_x)
    push!(gates, DefaultGates.GateSymbols.c_y => c_y)
    push!(gates, DefaultGates.GateSymbols.c_z => c_z)
    push!(gates, DefaultGates.GateSymbols.r_x => r_x)
    push!(gates, DefaultGates.GateSymbols.r_y => r_y)
    push!(gates, DefaultGates.GateSymbols.r_z => r_z)
    push!(gates, DefaultGates.GateSymbols.r_phase => r_phase)
    return gates
end

function x(gc::GateOps.GateCall1)
    return "x q[$(gc.target)];\n"
end
function y(gc::GateOps.GateCall1)
    return "y q[$(gc.target)];\n"
end
function z(gc::GateOps.GateCall1)
    return "z q[$(gc.target)];\n"
end
function h(gc::GateOps.GateCall1)
    return "h q[$(gc.target)];\n"
end
function r_x(gc::GateOps.GateCall1)
    return "rx($(gc.gate_symbol.params["θ"])) q[$(gc.target)];\n"
end
function r_y(gc::GateOps.GateCall1)
    return "ry($(gc.gate_symbol.params["θ"])) q[$(gc.target)];\n"
end
function r_z(gc::GateOps.GateCall1)
    return "rz($(gc.gate_symbol.params["θ"])) q[$(gc.target)];\n"
end
function r_phase(gc::GateOps.GateCall1)
    return "phase($(gc.gate_symbol.params["θ"])) q[$(gc.target)];\n"
end
function c_x(gc::GateOps.GateCall2)
    return "cx q[$(gc.ctrl)], q[$(gc.target)];\n"
end
function c_y(gc::GateOps.GateCall1)
    return "cy q[$(gc.ctrl)], q[$(gc.target)];\n"
end
function c_z(gc::GateOps.GateCall1)
    return "cz q[$(gc.ctrl)], q[$(gc.target)];\n"
end
function u(gc::GateOps.GateCall1)
    return "u3(a,b,c) q[$(gc.target)];\n"
end
function c_u(gc::GateOps.GateCall2)
    return "cu3(a,b,c) q[$(gc.target)],q[$(gc.target)];\n"
end
function c_phase(gc::GateOps.GateCall2)
    return "cphase($(gc.gate_symbol.params["θ"])) q[$(gc.target)],q[$(gc.target)];\n"
end

################################ OpenQASM gate builder #################################

function add_gate!(tlr::OpenQASM, gc::Union{GateOps.GateCall1, GateOps.GateCall2})
    gate_output = ""
    if ~haskey(tlr.gate_gen, gc.gate_symbol)
        #Qiskit doesnt have a default mapping for this gate, so we need to generate it
        
        if typeof(gc.gate_symbol) == GateOps.GateSymbol # check type of gate is param or not
            gate_func = GateMap.gates[gc.gate_symbol]
            gate = gate_func()
        elseif typeof(gc.gate_symbol) == GateOps.GateSymbolP
            gate_func = GateMap.gates[gc.gate_symbol]
            gate = gate_func(gc.gate_symbol.params)
        else
            error("Unsupported type: $(gc)")
        end
        
        create_gate!(tlr, gc);
        
    end
    if typeof(gc) == GateOps.GateCall2 && ( string(gc.gate_symbol.label)[1] != 'c') # 2 qubit
        c_sym = GateOps.GateSymbol(Symbol("c_"*string(gc.gate_symbol.label)), gc.gate_symbol.rt_depth, gc.gate_symbol.is_adj)
        tlr.cct *= tlr.gate_gen[c_sym](gc);
    else
        tlr.cct *= tlr.gate_gen[gc.gate_symbol](gc);
    end
end

################################ OpenQASM document helpers #################################

"""
    add_header(num_qubits::Int, reg::String="q", creg::String="c")

Returns the given OpenQASM header for number of quantum and classical bits.
"""
function add_header!(tlr::OpenQASM, num_qubits::Int, reg::String="q", creg::String="c")
    if tlr.version < 3.0
        header = "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg $(reg)[$(num_qubits)];\ncreg $(creg)[$(num_qubits)];\n"
    else
        header = "OPENQASM 3.0;\ninclude \"stdgates.inc\";\nqreg $(reg)[$(num_qubits)];\ncreg $(creg)[$(num_qubits)];\n"
    end
    tlr.header = header
    return header
end

function gate_builder(a, b, c, d, gc, is_x)
    g = """
    gate $(gc.gate_symbol.label) q
    {
        $(is_x ? "h q;" : "")
        u3($(a), $(b), $(c)) q;
        $(is_x ? "h q;" : "")
    }
    gate c_$(gc.gate_symbol.label) q1, q2
    {
        $(is_x ? "h q;" : "")
        cu3($(a), $(b), $(c)) q1, q2;
        $(is_x ? "h q;" : "")
    }
    """
    return g
end

function create_gate!(tlr::OpenQASM, gc::GateOps.AGateCall)
    is_x = false

    # Due to the way Qiskit handles X-gates, it is better to apply H and treat as Z for controlled and sqrt operations
    if gc.gate_symbol.label === :x
        is_x = true
        sym = GateOps.GateSymbol(:z, gc.gate_symbol.rt_depth, gc.gate_symbol.is_adj)
        if ~haskey(GateMap.gates, sym)
            NCU.gen_intermed_gates(GateOps.GateSymbol(:z, 0, false), gc.gate_symbol.rt_depth)
        end
        gc_internal = typeof(gc)(sym, [getfield(gc, i) for i in fieldnames(typeof(gc))][2:end]...)
    else
        gc_internal = gc
    end
    gate = nothing
    if typeof(gc_internal) === GateOps.GateSymbolP
        gate = GateMap.gates[gc_internal.gate_symbol](gc_internal.params...)
    else
        gate = GateMap.gates[gc_internal.gate_symbol]()
    end

    a, b, c, d = u3_transform(gc_internal) #exp(1i*d)*rz(c)*ry(b)*rz(a)

    qasm_gate_label = "$(gc_internal.gate_symbol.label)_$(gc_internal.gate_symbol.rt_depth)_$(gc_internal.gate_symbol.is_adj)"
    
    g = gate_builder(a, b, c, d, gc, is_x)

    tlr.custom_gates *= g
    tlr.gate_gen[gc_internal.gate_symbol] = (gc1::GateOps.GateCall1)->"$(qasm_gate_label) q[$(gc1.target)];\n"
    c_sym = GateOps.GateSymbol(Symbol("c_"*string(gc_internal.gate_symbol.label)), gc_internal.gate_symbol.rt_depth, gc_internal.gate_symbol.is_adj)
    tlr.gate_gen[c_sym] = (gc2::GateOps.GateCall2)->"c_$(qasm_gate_label) q[$(gc2.ctrl)],q[$(gc2.target)];\n"
end

################################ OpenQASM gate calls #################################

"""
Returns a single qubit QASM gate call
"""
function gate_to_qasm(g::GateOps.GateCall1)
    return "$(String(g.label)) q[$(g.target)];"
end

"""
Returns a two qubit QASM gate call
"""
function gate_to_qasm(g::GateOps.GateCall2)
    return "$(String(g.label)) q[$(g.ctrl)],q[$(g.target)];"
end

################################ Qiskit U3 translation #################################

"""
    u3_transform(gc::QXZoo.GateOps.AGateCall)

Return exp(ia)Rz(b)Ry(c)Rz(d) rotation angles for a given GateCall. 
Decomposition only applicable to SU(2) matrices. If using a 2-qubit gate, assumes the base-gate type, otherwise throws error is unavailable.
"""
@memoize function u3_transform(gc::QXZoo.GateOps.AGateCall)
    if string(gc.gate_symbol.label)[1] != 'c' || ~hasproperty(gc, :ctrl) 
        return mat_to_u3(GateMap.gates[gc.gate_symbol]())
    else
        throw(DomainError(gc, "ZYZ decomposition can only be applied to 1 qubit gates"))
    end
end

"""
    mat_to_u3(unitary::Union{Matrix{<:Number}, SArray{Tuple{2,2},Complex{Float64},2,4}})
    
Returns Qiskit OpenQASM compatible U3 parameters and a global phase from a given 2x2 SU(2) matrix. Inverse operation of u3_to_mat. Direct port from Qiskit https://qiskit.org/documentation/_modules/qiskit/quantum_info/synthesis/one_qubit_decompose.html
"""
@memoize function mat_to_u3(unitary::Union{Matrix{<:Number}, SArray{Tuple{2,2},Complex{Float64},2,4}})
    coeff = 1/sqrt(det(unitary))
    phase = -angle(coeff)
    su_mat = coeff * unitary  # U in SU(2)

    theta = 2 * atan(abs(su_mat[2, 1]), abs(su_mat[1, 1]))
    phiplambda = 2 * angle(su_mat[2, 2])
    phimlambda = 2 * angle(su_mat[2, 1])
    phi = (phiplambda + phimlambda) / 2.0
    lam = (phiplambda - phimlambda) / 2.0
    
    return theta, phi, lam, phase - 0.5 * (phi + lam)
end
"""
    u3_to_mat(θ::Number,ϕ::Number,λ::Number,ph::Number)
    
Returns a 2x2 SU(2) matrix from given Qiskit OpenQASM compatible U3 parameters and a global phase. Inverse operation of mat_to_u3
"""
@memoize function u3_to_mat(θ::Number,ϕ::Number,λ::Number,ph::Number)
    u00 = cos(θ/2)
    u01 = -exp(1im*λ)*sin(θ/2)
    u10 = exp(1im*ϕ)*sin(θ/2)
    u11 = exp(1im*(ϕ+λ)/2)*cos(θ/2)
    return [u00 u01; u10 u11].*exp(1im*ph)
end

########################################################################################

end