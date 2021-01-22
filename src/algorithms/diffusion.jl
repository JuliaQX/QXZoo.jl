module Diffusion

using QXZoo.NCU
using QXZoo.Oracle
using QXZoo.Circuit
using QXZoo.DefaultGates

"""
    apply_diffusion(cct::Circuit.Circ, ctrl_indices::Vector, tgt_index)

Application of the Grover diffusion operator to marked register.
"""
function apply_diffusion!(cct::Circuit.Circ, ctrl_indices::Vector, tgt_index)
    aux_idx = typeof(ctrl_indices)()

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
    end

    NCU.apply_ncu!(cct, ctrl_indices, aux_idx, tgt_index, DefaultGates.GateSymbols.z)

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
    end
end

"""
    apply_diffusion(cct::Circuit.Circ, ctrl_indices::Vector, aux_indices::Vector, tgt_index)

Application of the Grover diffusion operator to marked register. Uses additionally provided auxiliary qubits to reduce depth.
"""
function apply_diffusion!(cct::Circuit.Circ, ctrl_indices::Vector, aux_indices::Vector, tgt_index)

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
    end

    NCU.apply_ncu!(cct, ctrl_indices, aux_indices, tgt_index, DefaultGates.GateSymbols.z)

    for ctrl in vcat(ctrl_indices, tgt_index)
        Circuit.add_gatecall!(cct, DefaultGates.x(ctrl) )
        Circuit.add_gatecall!(cct, DefaultGates.h(ctrl) )
    end
end

end