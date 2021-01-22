module QFT

using QXZoo.GateOps
using QXZoo.Circuit
using QXZoo.DefaultGates
using QXZoo.CompositeGates

"""
    bitstring_ncu(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx, U::GateOps.GateSymbol) 

Takes bitstring as the binary pattern and indices as the qubits to operate upon. Applies the appropriate PauliX gates to the control lines to call the NCU with the given matrix 
"""
function apply_qft!(cct::Circuit.Circ, qubit_indices::Vector)
    for index_i in collect(1:length(qubit_indices))
        Circuit.add_gatecall!(cct, DefaultGates.h(qubit_indices[index_i]))
        for index_j in collect(index_i+1:length(qubit_indices))
            Circuit.add_gatecall!(cct, DefaultGates.c_r_z(index_i, index_j, π/(2^(index_j-index_i+1))))
        end
    end
    # TODO: do not add swap gates but return ordering information instead
    for i = 1:convert(Int, floor(length(qubit_indices)//2))
        cct += CompositeGates.swap(i, length(qubit_indices)-i)
    end
    cct
end

end