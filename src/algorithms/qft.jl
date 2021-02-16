module QFT

using QXZoo.GateOps
using QXZoo.Circuit
using QXZoo.DefaultGates
using QXZoo.CompositeGates

export apply_qft!, apply_iqft!

"""
    apply_qft!(cct::Circuit.Circ, qubit_indices::Vector)

Apply the quantum Fourier transform over the given qubit index range.
"""
function apply_qft!(cct::Circuit.Circ, qubit_indices::Vector)
    for idx in 1:length(qubit_indices)
        cct << DefaultGates.h(qubit_indices[idx])
        for jdx in idx+1:length(qubit_indices)
            cct << DefaultGates.c_r_phase(qubit_indices[idx], qubit_indices[jdx], 2π/(2^(qubit_indices[jdx]-qubit_indices[idx]+1)))
        end
    end
    lhs, rhs = swap_idx(qubit_indices)
    for i in 1:length(lhs)
        cct << CompositeGates.swap(lhs[i], rhs[i])
    end
    ;
end
"""
    apply_qft!(cct::Circuit.Circ)

Apply the quantum Fourier transform over the entire qubit register
"""
apply_qft!(cct::Circuit.Circ) = apply_qft!(cct, collect(1:cct.num_qubits))


"""
    apply_qft!(cct::Circuit.Circ, qubit_indices::Vector)

Apply the inverse quantum Fourier transform over the given qubit index range.
"""
function apply_iqft!(cct::Circuit.Circ, qubit_indices::Vector)
    lhs, rhs = swap_idx(qubit_indices)

    for i in 1:length(lhs)
        cct << CompositeGates.swap(lhs[i], rhs[i])
    end

    for idx in length(qubit_indices):-1:1
        for jdx in length(qubit_indices):-1:idx+1
            cct << DefaultGates.c_r_phase(qubit_indices[idx], qubit_indices[jdx], -2π/(2^(qubit_indices[jdx]-qubit_indices[idx]+1)))
        end
        cct << DefaultGates.h(qubit_indices[idx])
    end

    ;
end
"""
    apply_iqft!(cct::Circuit.Circ)

Apply the inverse quantum Fourier transform over the entire qubit register
"""
apply_iqft!(cct::Circuit.Circ) = apply_iqft!(cct, collect(1:cct.num_qubits))


"""
    swap_idx(qubit_indices::Vector)

Return the indices of the qubits required to apply the swap operations as part of the transform.
"""
function swap_idx(qubit_indices::Vector)
    is_even = (length(qubit_indices) & 1 === 0)
    mp = convert(Int, floor(length(qubit_indices)//2))
    lhs = @view qubit_indices[1:mp]
    if is_even
        rhs = @view qubit_indices[end:-1:mp+1]
    else
        rhs = @view qubit_indices[end:-1:mp+2]
    end
    return lhs, rhs
end

end
