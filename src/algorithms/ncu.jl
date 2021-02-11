module NCU

using QXZoo.Circuit
using QXZoo.GateOps
using QXZoo.GateMap
using QXZoo.DefaultGates

# =========================================================================== #
# 
# =========================================================================== #

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
    apply_ncu!(cct::Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, U::GateOps.GateSymbol)

Apply an n-qubit controlled gate operation on the given target qubit.
Ensure the 2-qubit gate corresponding with symbol c_U is registered with GateMap.gates before use.
Appends the GateCall operations to circuit

# Arguments
- `cct::Circuit.Circ`
- `ctrls::Vector`: 
- `aux::Vector`: 
- `tgt::Int`:
- `U::GateOps.GateSymbol`: symbol for 2-qubit gate to extend (c_x, c_z, etc)
"""
function apply_ncu!(cct::Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, c_U::GateOps.GateSymbol)

    # Check global Circuit cache for gate
    if ~haskey(GateMap.gates, c_U )
        error("Gate $(U) does not exist")
    end

    su,asu = get_intermed_gate(c_U)

    if length(q_ctrl) == 2
        cct << DefaultGates.c_u(su, q_tgt, q_ctrl[2])
        cct << DefaultGates.c_x(q_ctrl[2], q_ctrl[1])
        cct << DefaultGates.c_u(asu, q_tgt, q_ctrl[2])
        cct << DefaultGates.c_x(q_ctrl[2], q_ctrl[1])
        cct << DefaultGates.c_u(su, q_tgt, q_ctrl[1])

    elseif length(q_ctrl) == 3 # Optimisation for 3 control lines

        ssu,assu = get_intermed_gate(su)
        
        cct << DefaultGates.c_u(ssu, q_tgt, q_ctrl[1])
        cct << DefaultGates.c_x(q_ctrl[2], q_ctrl[1])
        cct << DefaultGates.c_u(assu, q_tgt, q_ctrl[2])
        cct << DefaultGates.c_x(q_ctrl[2], q_ctrl[1])

        cct << DefaultGates.c_u(ssu, q_tgt, q_ctrl[2])
        cct << DefaultGates.c_x(q_ctrl[3], q_ctrl[2])
        cct << DefaultGates.c_u(assu, q_tgt, q_ctrl[3])
        cct << DefaultGates.c_x(q_ctrl[3], q_ctrl[1])

        cct << DefaultGates.c_u(ssu, q_tgt, q_ctrl[3])
        cct << DefaultGates.c_x(q_ctrl[3], q_ctrl[2])
        cct << DefaultGates.c_u(assu, q_tgt, q_ctrl[3])
        cct << DefaultGates.c_x(q_ctrl[3], q_ctrl[1])
        cct << DefaultGates.c_u(ssu, q_tgt, q_ctrl[3])

    # Optimisation for Multi-controlled x with additional qubit availability
    elseif (length(q_ctrl)>=5) && (length(q_aux)>=length(q_ctrl)-2) && (c_U == DefaultGates.GateSymbols.c_x)

        apply_ncu!(cct, [q_ctrl[end], q_aux[ 1 + length(q_ctrl)-3 ]], Int[], q_tgt, c_U)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], c_U)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], c_U)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], c_U)
        end
        
        apply_ncu!(cct, [q_ctrl[end], q_aux[1 + length(q_ctrl) - 3]], Int[], q_tgt, c_U)
        for i in reverse(2:length(q_ctrl)-2)
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], c_U)
        end
        
        apply_ncu!(cct, [q_ctrl[1], q_ctrl[2]], Int[], q_aux[1], c_U)
        for i in 2:length(q_ctrl)-2
            apply_ncu!(cct, [q_ctrl[1 + i], q_aux[1 + (i-2)]], Int[], q_aux[1 + (i-1)], c_U)
        end

    elseif (length(q_ctrl)>=5) && (length(q_aux)>=length(q_ctrl)-2) && (c_U == DefaultGates.GateSymbols.c_z)

        cct << DefaultGates.h(q_tgt)
        apply_ncu!(cct, q_ctrl, q_aux, q_tgt, DefaultGates.GateSymbols.c_x)
        cct << DefaultGates.h(q_tgt)

    else
        # By cat'ing the unused qubits as part of this recursive decomposition steps, large
        # controlled circuits eventually converge to the auxiliary assisted routines,
        # assuming controlled-x operations.
        cct << DefaultGates.c_u(su, q_tgt, q_ctrl[end])
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_tgt), q_ctrl[end], DefaultGates.GateSymbols.c_x)
        cct << DefaultGates.c_u(asu, q_tgt, q_ctrl[end])
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_tgt), q_ctrl[end], DefaultGates.GateSymbols.c_x)
        apply_ncu!(cct, q_ctrl[1:end-1], vcat(q_aux, q_ctrl[end]), q_tgt, su)
    end
    ;
end

end
