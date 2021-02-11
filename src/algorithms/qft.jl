module QFT

using QXZoo.GateOps
using QXZoo.Circuit
using QXZoo.DefaultGates
using QXZoo.CompositeGates

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
    for i = 1:convert(Int, floor(length(qubit_indices)//2))
        cct << CompositeGates.swap(i, length(qubit_indices)-i+1)
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
    for i = convert(Int, floor(length(qubit_indices)//2)):-1:1
        cct << CompositeGates.swap(i, length(qubit_indices)-i+1)
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

end