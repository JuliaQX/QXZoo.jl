module Oracle

using QXZoo.GateOps
using QXZoo.NCU
using QXZoo.Circuit
using QXZoo.DefaultGates

"""
    bitstring_ncu(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx, U::GateOps.GateSymbol) 

Takes bitstring as the binary pattern and indices as the qubits to operate upon. Applies the appropriate PauliX gates to the control lines to call the NCU with the given matrix 
"""
function bitstring_ncu!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx, U::GateOps.GateSymbol)
    bitmask =  0x1
    aux_idx = typeof(ctrl_indices)()

    # Filter qubit values to mark specified pattern
    for idx in collect(0:length(ctrl_indices))
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                Circuit.add_gatecall!(cct, DefaultGates.x(ctrl_indices[idx+1]))
            else
                Circuit.add_gatecall!(cct, DefaultGates.x(tgt_idx))
            end
        end
    end
    NCU.apply_ncu!(cct, ctrl_indices, aux_idx, tgt_idx, U)
    for idx in collect(0:length(ctrl_indices))
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                Circuit.add_gatecall!(cct, DefaultGates.x(ctrl_indices[idx+1]))
            else
                Circuit.add_gatecall!(cct, DefaultGates.x(tgt_idx))
            end
        end
    end
end

"""
    bitstring_ncu(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, aux_indices::Vector, tgt_idx, U::GateOps.GateSymbol)

Takes bitstring as the binary pattern and indices as the qubits to operate upon. Applies the appropriate PauliX gates to the control lines to call the NCU with the given matrix. Uses aux_indices to reduce Circuit depth by expanding width.
"""
function bitstring_ncu!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, aux_indices::Vector, tgt_idx, U::GateOps.GateSymbol)
    bitmask =  0x1

    # Filter qubit values to mark specified pattern
    for idx in collect(0:length(ctrl_indices))
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                Circuit.add_gatecall!(cct, DefaultGates.x(ctrl_indices[idx+1]))
            else
                Circuit.add_gatecall!(cct, DefaultGates.x(tgt_idx))
            end
        end
    end
    NCU.apply_ncu!(cct, ctrl_indices, aux_indices, tgt_idx, U)
    for idx in collect(0:length(ctrl_indices))
        if ~( (bitstring & (bitmask << idx) ) != 0)
            if idx < length(ctrl_indices)
                Circuit.add_gatecall!(cct, DefaultGates.x(ctrl_indices[idx+1]))
            else
                Circuit.add_gatecall!(cct, DefaultGates.x(tgt_idx))
            end
        end
    end
end

"""
    bitstring_phase_oracle(bitstring::Unsigned, ctrl_indices::Vector, tgt_idx::Unsigned)

Applies PauliX gates to the appropriate lines in the Circuit, then applies a n-controlled PauliZ to mark the state.
"""
function bitstring_phase_oracle!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx)
    return bitstring_ncu!(cct, bitstring, ctrl_indices, tgt_idx, DefaultGates.GateSymbols.z )
end

"""
    bitstring_phase_oracle(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx)

Applies PauliX gates to the appropriate lines in the Circuit, then applies a n-controlled PauliZ to mark the state. Uses aux qubits to reduce Circuit depth.
"""
function bitstring_phase_oracle!(cct::Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, aux_indices::Vector, tgt_idx)
    return bitstring_ncu!(cct, bitstring, ctrl_indices, aux_indices, tgt_idx, DefaultGates.GateSymbols.z )
end

end