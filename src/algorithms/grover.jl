module Grover

using QXZoo.NCU
using QXZoo.Circuit
using QXZoo.DefaultGates
using QXZoo.GateOps

export run_grover

"""
    calc_iterations(num_qubits::Integer)

Calculate the required number of iterations to maximise the state's amplitude.
"""
function calc_iterations(num_qubits::Integer)
    return pi*sqrt(num_qubits)/4
end

"""
    state_init!(cct::Circuit.Circ, qubit_indices::Vector)

Initialises the state to the required target; defaults to ``H^{\\otimes n}\\vert \\psi \\rangle`` . Override for custom initialisation.
"""
function state_init!(cct::Circuit.Circ, qubit_indices::Vector)
    for i in qubit_indices
        Circuit.add_gatecall!(cct, DefaultGates.h(i))
    end
end

"""
    bitstring_ncu(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, U::GateOps.GateSymbol, aux_indices::Vector=Int[])

Takes bitstring as the binary pattern and indices as the qubits to operate upon. Applies the appropriate PauliX gates to the control lines to call the NCU with the given matrix. Uses aux_indices to reduce Circuit depth by expanding width if |aux|+2 >= |ctrl|. If not specified, uses default quadratic gate expansion.
"""
function bitstring_ncu!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, U::GateOps.GateSymbol, aux_indices::Vector=Int[])
    bitmask =  0x1

    # Filter qubit values to mark specified pattern
    for idx in 0:length(ctrl_indices)
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                cct << DefaultGates.x(ctrl_indices[idx+1])
            else
                cct << DefaultGates.x(tgt_idx)
            end
        end
    end
    NCU.apply_ncu!(cct, ctrl_indices, aux_indices, tgt_idx, U)
    for idx in length(ctrl_indices):-1:0
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                cct << DefaultGates.x(ctrl_indices[idx+1])
            else
                cct << DefaultGates.x(tgt_idx)
            end
        end
    end
end

"""
    bitstring_phase_oracle(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, aux_indices::Vector=Int[])

Applies PauliX gates to the appropriate lines in the Circuit, then applies a n-controlled PauliZ to mark the state. Uses aux qubits to reduce circuit depth if |aux|+2 >= |ctrl|. If not provided, uses quadratic gate expansion
"""
function bitstring_phase_oracle!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, aux_indices::Vector=Int[])
    return bitstring_ncu!(cct, bitstring, ctrl_indices, tgt_idx, DefaultGates.GateSymbols.c_z, aux_indices)
end

"""
    apply_diffusion(cct::Circuit.Circ, ctrl_indices::Vector, tgt_index::Int, aux_indices::Vector=Int[] )

Application of the Grover diffusion operator to marked register. Uses additionally provided auxiliary qubits to reduce depth.
"""
function apply_diffusion!(cct::Circuit.Circ, ctrl_indices::Vector, tgt_index::Int, aux_indices::Vector=Int[])

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
    end

    NCU.apply_ncu!(cct, ctrl_indices, aux_indices, tgt_index, DefaultGates.GateSymbols.c_z)

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
    end
end

"""
    apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector)

Applies a single Grover iteration. To be used following `mark_state!`
"""
function apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector=Int[])
    return apply_diffusion!(cct, qubit_indices[1:end-1], qubit_indices[end], qubit_aux_indices)
end


"""
    mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector, qubit_aux_indices::Vector)

Applies the state marking procedure of the Grover iteration.
"""
function mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector, qubit_aux_indices::Vector=Int[])
    return bitstring_phase_oracle!(cct, state, qubit_indices[1:end-1], qubit_indices[end], qubit_aux_indices)
end


"""
    run_grover!(cct::Circuit.Circ, qubit_indices::Vector, state::Integer=1, qubit_aux_indices::Vector=Int[])

Generates a Grover search Circuit sample, marking the state defined by `state`
and performing iterations to amplify the desired result upon measurement.
"""
function run_grover!(cct::Circuit.Circ, qubit_indices::Vector, state::Integer=1, qubit_aux_indices::Vector=Int[])
    num_states = 2^(length(qubit_indices))
    state_init!(cct, qubit_indices)
    for i in range(1,stop=ceil(Integer, calc_iterations(num_states)))
        mark_state!(cct, state, qubit_indices, qubit_aux_indices)
        apply_grover_iteration!(cct, qubit_indices, qubit_aux_indices)
    end
end

end