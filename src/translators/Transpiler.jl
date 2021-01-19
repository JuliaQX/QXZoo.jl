module Transpiler

using QXZoo.Circuit
using QXZoo.DefaultGates

function basic_swap(circuit::Circuit.Circ, coupling_map::Array{Array{Int, 1}, 1})
    #TODO
end

function naive_basic_swap(cct::Circuit.Circ)
    cct_bs = Circuit.Circ(cct.num_qubits, cct.gate_set)
    for (index,gc) in enumerate(cct.circ_ops)
        if typeof(gc) === QXZoo.GateOps.GateCall2
            qubit_dist = (gc.ctrl - gc.target)
            if abs(qubit_dist) > 1
                for i in 1:(abs(qubit_dist)-1)
                    if gc.ctrl > gc.target
                        cct_bs + DefaultGates.c_x(gc.ctrl-i, gc.ctrl-i-1)
                        cct_bs + DefaultGates.c_x(gc.ctrl-i-1, gc.ctrl-i)
                        cct_bs + DefaultGates.c_x(gc.ctrl-i, gc.ctrl-i-1)
                    else
                        cct_bs + DefaultGates.c_x(gc.ctrl+i, gc.ctrl+i-1)
                        cct_bs + DefaultGates.c_x(gc.ctrl+i-1, gc.ctrl+i)
                        cct_bs + DefaultGates.c_x(gc.ctrl+i, gc.ctrl+i-1)
                    end
                end
                if gc.ctrl > gc.target
                    cct_bs + GateOps.GateCall2(gc.gate_symbol, gc.target+1, gc.target)
                else
                    cct_bs + GateOps.GateCall2(gc.gate_symbol, gc.target-1, gc.target)
                end

                for i in 1:(abs(qubit_dist)-1)
                    if gc.ctrl > gc.target
                        cct_bs + DefaultGates.c_x(gc.ctrl-i, gc.ctrl-i-1)
                        cct_bs + DefaultGates.c_x(gc.ctrl-i-1, gc.ctrl-i)
                        cct_bs + DefaultGates.c_x(gc.ctrl-i, gc.ctrl-i-1) 
                    else
                        cct_bs + DefaultGates.c_x(gc.ctrl+i, gc.ctrl+i-1)
                        cct_bs + DefaultGates.c_x(gc.ctrl+i-1, gc.ctrl+i)
                        cct_bs + DefaultGates.c_x(gc.ctrl+i, gc.ctrl+i-1)
                    end
                end
            else
                cct_bs + gc
            end
        else
            cct_bs + gc
        end
    end
    return cct_bs
end





end