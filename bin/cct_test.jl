using QXZoo
using QXZoo.Circuit

num_qubits = parse(Int, ARGS[1])
test_set = parse(Int, ARGS[2])

###############################################################################
#                               Utility functions
###############################################################################

function get_cct_memory_usage_estimate_bytes(cct::QXZoo.Circuit.Circ)
    mem = sizeof(cct.num_qubits)
    mem += sizeof(cct.circ_ops)
    mem += sizeof(cct.gate_set)
    for i in cct.gate_set
        mem += sizeof(i)
    end
    for i in QXZoo.GateMap.gates
        mem += 64
    end
    for i in cct.circ_ops
        mem += sizeof(QXZoo.Circuit.DS.Node{Union{QXZoo.GateOps.GateCall2, QXZoo.GateOps.GateCall1}})
    end
    return mem
end

"""
Functions to ensure gate call counts match expected number
"""
function ncu_gate_calls_default(n::Int)
    @assert n >= 2
    
    if n == 2
        return 5
    else
        return 3*ncu_gate_calls_default(n-1) + 2
    end
end

function ncu_gate_calls_aux_opt(n::Int)
    @assert n >= 3
    if n == 3
        return 13
    else
        return 3*ncu_gate_calls_aux_opt(n-1) + 2
    end
end

###############################################################################
#                          Sample test-cases
###############################################################################

if test_set === 0 # Simple circuit creation

    # Create a Circ type
    cct = QXZoo.Circuit.Circ(num_qubits)
    print(cct)

    # Insert gates into cct
    @time for i=1:10000
        QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.c_x(0, 1))
        QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.c_x(1, 0))
        QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.c_x(0, 1))
    end

    print(cct)

    # Insert more gates into cct
    QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.h(0))
    QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.y(1))
    QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.z(2))

    print(cct)

    cz12 = QXZoo.DefaultGates.c_z(1, 2)
    cz21 = QXZoo.DefaultGates.c_z(2, 1)

    # Gates can also be added using '+'
    @time for i=1:10000
        cct << cz12
        cct << cz21
        cct << cz12
    end
    println("Gates:=", cct.circ_ops.len, " ", cct)

###############################################################################

elseif test_set === 1 # Default NCU

    cct = QXZoo.Circuit.Circ(num_qubits)

    ctrl = collect(range(0, length=num_qubits-1  ) ) 
    tgt = num_qubits-1
    QXZoo.NCU.apply_ncu!(cct, ctrl, [], tgt, QXZoo.GateOps.GateSymbol(:c_x))

    if num_qubits == 3
        @assert cct.circ_ops.len == ncu_gate_calls_default(num_qubits-1)
    else
        @assert cct.circ_ops.len == ncu_gate_calls_aux_opt(num_qubits-1)
    end

###############################################################################

elseif test_set === 2 # Aux-assisted NCU
    @assert num_qubits >= 9 && num_qubits%2==1 # must be 9 or more and odd numbers
    cct = QXZoo.Circuit.Circ(num_qubits)

    ctrl = collect(range(0, length=convert(Int, (num_qubits+1)/2  ))) 
    aux =  collect(range( convert(Int, (num_qubits+1)/2+1), stop=num_qubits-1))
    tgt = convert(Int, maximum(ctrl)+1 )
    QXZoo.NCU.apply_ncu!(cct, ctrl, aux ,tgt, QXZoo.GateOps.GateSymbol(:c_x))
    println(cct)

###############################################################################

elseif test_set === 3 # Default Grover
    cct = QXZoo.Circuit.Circ(4)
    register = collect( range(0, length=4 ) ) 
    QXZoo.Grover.run_grover!(cct, register, 2^(4-1) -1)
    println("Number of qubits:=", 4, " Number of gates:=",  cct.circ_ops.len)

    cct = QXZoo.Circuit.Circ(num_qubits)
    register = collect( range(0, length=num_qubits  ) ) 
    QXZoo.Grover.run_grover!(cct, register, 10)
    println("Number of qubits:=", num_qubits, " Number of gates:=",  cct.circ_ops.len)

###############################################################################

elseif test_set === 4 # Aux-assisted Grover
    cct = QXZoo.Circuit.Circ(num_qubits)
    @assert num_qubits >= 9 && num_qubits%2==1 # must be 9 or more and odd numbers

    ctrl = collect(range(0, length=convert(Int, (num_qubits+1)/2  ))) 
    aux =  collect(range( convert(Int, (num_qubits+1)/2+1), stop=num_qubits-1))
    tgt = convert(Int, maximum(ctrl)+1 )
    
    QXZoo.Grover.run_grover!(cct, vcat(ctrl, tgt), aux, 2^(num_qubits-1) -1)
    println("Number of qubits:=", num_qubits, " Number of gates:=",  cct.circ_ops.len)

end

###############################################################################