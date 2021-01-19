module NCU

using QXZoo.Circuit
using QXZoo.GateOps
using QXZoo.GateMap
using QXZoo.DefaultGates

# =========================================================================== #
# 
# =========================================================================== #

"""
    init_intermed_gates(circ::Circuit.Circ, num_ctrl::Union{Nothing, Int})

Generates the required intermediate gates for implementing the NCU using the given Circuit gate-set. Calling this routine is essential before running the NCU.apply_ncu! function.
"""
function init_intermed_gates(circ::Circuit.Circ, num_ctrl::Union{Nothing, Int})
    for k in circ.gate_set
        gen_intermed_gates(num_ctrl == nothing ? 8 : num_ctrl, k)
    end
end

"""
    register_gate(circ::Circuit.Circ, U::GateOps.GateSymbol, gate_f::Function)

Adds the user-defined gate to the cache with the pairing U=>gate_f
We use a gate generating function to avoid using matrices for static gates and 
functions for parameterised gates. In this way, all gates are create by a 
defining function, parameterised or not.

Given the small sizes, we use StaticArrays.jl to represent the gates as a given
matrix or 2x2 (1 qubit) or 4x4 (2 qubit) types
"""
function register_gate(circ::Circuit.Circ, U::GateOps.GateSymbol, gate_f::Function)
    # Some characters are reserved for internal gates
    @assert !(U in ["x","y","z","h","s","t","a","c"])
    gate = gate_f()
    @assert typeof(gate) === GateMap.SArray{Tuple{2,2},Complex{Float64},2,4}
    @assert size(gate) === (2,2) || size(gate) === (4,4)
    GateMap.gates[U] = gate_f
end

"""
    gen_intermed_gates(ctrl_depth::Int, U::GateOps.GateSymbol)

Generates all intermediate n-th root gates upto the given control depth.
"""
function gen_intermed_gates(ctrl_depth::Int, U::GateOps.GateSymbol)
    su,asu = get_intermed_gate(U)
    for i in 2:ctrl_depth-1
        su,asu = get_intermed_gate(su)
    end
    ;
end

"""
    get_intermed_gate(U::GateOps.GateSymbol)

Generate sqrt U and adjoint sqrt U, given a previously cached gate U.
"""
function get_intermed_gate(U::GateOps.GateSymbol)
    su = GateOps.GateSymbol(U.label, U.rt_depth+1)
    asu = GateOps.GateSymbol(U.label, U.rt_depth+1, true)

    if ~haskey(GateMap.gates, su)

        SU = ()->sqrt(GateMap.gates[U]())
        ASU = ()->adjoint(SU())

        # Cache the gates
        GateMap.gates[su] = SU
        GateMap.gates[asu] = ASU
    end

    return su, asu
end

# =========================================================================== #
# 
# =========================================================================== #

"""
    apply_cu!(cct::Circuit.Circ, ctrl, tgt, gl::GateOps.GateSymbol)

Module-specific CU gate. Defaults to using the implementation from GateOps.
Override for custom functionality.
"""
function apply_cu!(cct::Circuit.Circ, ctrl, tgt, gl::GateOps.GateSymbol)
    @assert gl in keys(GateMap.gates)
    Circuit.add_gatecall!(cct, DefaultGates.c_u(gl, ctrl, tgt ) )
end

# =========================================================================== #
# 
# =========================================================================== #

"""
    apply_ncu!(cct::Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, U::GateOps.GateSymbol)

Apply an n-qubit controlled gate operation on the given target qubit.
Ensure the gate corresponding with symbol U is registered with GateMap.gates before use.
Appends the GateCall operations to circuit

# Arguments
- `cct::Circuit.Circ`
- `ctrls::Vector`: 
- `aux::Vector`: 
- `tgt::Int`:
- `U::GateOps.GateSymbol`:
"""
function apply_ncu!(cct::Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, U::GateOps.GateSymbol)

    # Check global Circuit cache for gate
    if ~haskey(GateMap.gates, U )
        error("Gate $(U) does not exist")
    end

    su,asu = get_intermed_gate(U)
    push!(cct.gate_set, su)
    push!(cct.gate_set, asu)

    if length(q_ctrl) == 2

        apply_cu!(cct, q_ctrl[2], q_tgt, su)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[2]))
        apply_cu!(cct, q_ctrl[2], q_tgt, asu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[2]))
        apply_cu!(cct, q_ctrl[1], q_tgt, su)

    elseif length(q_ctrl) == 3 # Optimisation for 3 control lines

        ssu,assu = get_intermed_gate(su)
        push!(cct.gate_set, ssu)
        push!(cct.gate_set, assu)

        apply_cu!(cct, q_ctrl[1], q_tgt, ssu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[2]))
        apply_cu!(cct, q_ctrl[2], q_tgt, assu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[2]))
        apply_cu!(cct, q_ctrl[2], q_tgt, ssu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[2], q_ctrl[3]))
        apply_cu!(cct, q_ctrl[3], q_tgt, assu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[3]))
        apply_cu!(cct, q_ctrl[3], q_tgt, ssu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[2], q_ctrl[3]))
        apply_cu!(cct, q_ctrl[3], q_tgt, assu)
            Circuit.add_gatecall!(cct, DefaultGates.c_x(q_ctrl[1], q_ctrl[3]))
        apply_cu!(cct, q_ctrl[3], q_tgt, ssu)
        
    # Optimisation for Multi-controlled x with additional qubit availability
    elseif (length(q_ctrl)>=5) && (length(q_aux)>=length(q_ctrl)-2) && (U == DefaultGates.GateSymbols.x)

        apply_ncu!(cct, [q_ctrl[end], q_aux[ 1 + length(q_ctrl)-3 ]], Int[], q_tgt, U)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], U)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], U)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], U)
        end
        
        apply_ncu!(cct, [q_ctrl[end], q_aux[1 + length(q_ctrl) - 3]], Int[], q_tgt, U)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], U)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], U)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], U)
        end

    elseif (length(q_ctrl)>=5) && (length(q_aux)>=length(q_ctrl)-2) && (U == GateOps.GateSymbol(:z))

        gl = GateOps.GateSymbol(:x)
        Circuit.add_gatecall!(cct, DefaultGates.h(q_tgt))

        apply_ncu!(cct, [q_ctrl[end], q_aux[ 1 + length(q_ctrl)-3 ]], Int[], q_tgt, gl)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], gl)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], gl)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], gl)
        end
        
        apply_ncu!(cct, [q_ctrl[end], q_aux[1 + length(q_ctrl) - 3]], Int[], q_tgt, gl)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], gl)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], gl)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], gl)
        end

        Circuit.add_gatecall!(cct, DefaultGates.h(q_tgt))

    else
        # By cat'ing the unused qubits as part of this recursive decomposition steps, large
        # controlled circuits eventually converge to the auxiliary assisted routines,
        # assuming controlled-x operations.
        apply_cu!(cct, q_ctrl[end], q_tgt, su)
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_tgt), q_ctrl[end], GateOps.GateSymbol(:x))
        apply_cu!(cct, q_ctrl[end], q_tgt, asu)
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_tgt), q_ctrl[end], GateOps.GateSymbol(:x))
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_ctrl[end]), q_tgt, su)
    end
    ;
end

end
