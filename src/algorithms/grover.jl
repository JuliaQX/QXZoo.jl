module Grover

using QXZoo.Oracle
using QXZoo.Diffusion
using QXZoo.Circuit
using QXZoo.DefaultGates

export run_grover

"""
    calc_iterations(num_states::Integer)

Calculate the required number of iterations to maximise the state's amplitude.
"""
function calc_iterations(num_states::Integer)
    return pi*sqrt(num_states)/4
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
    apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector)

Applies a single Grover iteration. To be used following `mark_state!`
"""
function apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector)
    return Diffusion.apply_diffusion(cct, qubit_indices[1:end-1], qubit_indices[end])
end

"""
    apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector)

Applies a single Grover iteration. To be used following `mark_state!`
"""
function apply_grover_iteration!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector)
    return Diffusion.apply_diffusion(cct, qubit_indices[1:end-1], qubit_aux_indices, qubit_indices[end])
end

"""
    mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector)

Applies the state marking procedure of the Grover iteration.
"""
function mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector)
    return Oracle.bitstring_phase_oracle(cct::Circuit.Circ, state, qubit_indices[1:end-1], qubit_indices[end])
end

"""
    mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector, qubit_aux_indices::Vector)

Applies the state marking procedure of the Grover iteration.
"""
function mark_state!(cct::Circuit.Circ, state::Integer, qubit_indices::Vector, qubit_aux_indices::Vector)
    return Oracle.bitstring_phase_oracle(cct::Circuit.Circ, state, qubit_indices[1:end-1], qubit_aux_indices, qubit_indices[end])
end


"""
    run_grover!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector, state::Integer)

Generates a Grover search Circuit sample, marking the state defined by `state`
and performing iterations to amplify the desired result upon measurement.
"""
function run_grover!(cct::Circuit.Circ, qubit_indices::Vector, state::Integer)
    num_states = 2^(length(qubit_indices))
    state_init!(cct, qubit_indices)
    for i in range(1,stop=ceil(Integer, calc_iterations(num_states)))
        mark_state!(cct, state, qubit_indices)
        apply_grover_iteration!(cct, qubit_indices)
    end
end

"""
    run_grover!(cct::Circuit.Circ, qubit_indices::Vector, state::Integer)

Generates a Grover search Circuit sample, marking the state defined by `state`
and performing iterations to amplify the desired result upon measurement.
"""
function run_grover!(cct::Circuit.Circ, qubit_indices::Vector, qubit_aux_indices::Vector, state::Integer)
    num_states = 2^(length(qubit_indices))
    state_init!(cct, qubit_indices)
    for i in range(1,stop=ceil(Integer, calc_iterations(num_states)))
        mark_state!(cct, state, qubit_indices, qubit_aux_indices)
        apply_grover_iteration!(cct, qubit_indices, qubit_aux_indices)
    end
end

end