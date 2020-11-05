# NCU module
The NCU module enables the implementation of an $n$-qubit controlled unitary gate. In this instances, we have chosen to work primarily with $n$CX and $n$CZ gates, though others may also be used.

## Implementation
The general principle follows the work of Barenco *et al.*, Phys. Rev. A 52, 3457, (1995). All higher-order controlled quantum gates can be decomposed into 1 and 2 qubit gate calls, with varying degrees of optimisation. We implement the default quadratic gate decomposition strategy, alongside the 3CU optimised, and auxiliary register optimised variants.

## API

```@docs
QuantExQASM.NCU.apply_ncu!(circuit::QuantExQASM.Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, U::QuantExQASM.GateOps.GateLabel)
QuantExQASM.NCU.init_intermed_gates(circ::QuantExQASM.Circuit.Circ, num_ctrl::Union{Nothing, Int})
QuantExQASM.NCU.register_gate(circ::QuantExQASM.Circuit.Circ, U::QuantExQASM.GateOps.GateLabel, gate::Matrix{<:Number})
QuantExQASM.NCU.gen_intermed_gates(ctrl_depth::Int, U::QuantExQASM.GateOps.GateLabel)
QuantExQASM.NCU.get_intermed_gate(U::QuantExQASM.GateOps.GateLabel)
QuantExQASM.NCU.apply_cx!(c::QuantExQASM.Circuit.Circ, ctrl, tgt, reg)
QuantExQASM.NCU.apply_cu!(c::QuantExQASM.Circuit.Circ, ctrl, tgt, reg, gl::QuantExQASM.GateOps.GateLabel)
```

## Example 
To use the NCU module, we provide example code below to apply an n-controlled Pauli Z gate using either the optimised or unoptimised (quadratic) decomposition routines.

```@example
using QuantExQASM

# Set 5-qubit limit on circuit
num_qubits = 5

# Do not use optimised routines
use_aux_qubits = false

# Create Pauli-Z gate-label for application
gl = QuantExQASM.GateOps.GateLabel(:z)

# Create empty circuit with qiven qubit count
cct = QuantExQASM.Circuit.Circ(num_qubits)

# Initialise default intermediate gates (X,Y,Z,H) for use in NCU
QuantExQASM.NCU.init_intermed_gates(cct, num_qubits-1)

U = QuantExQASM.Circuit.gate_cache[gl]

if use_aux_qubits == true && (num_qubits/2+1 >= 4)
    ctrl = collect(0:Int( floor((num_qubits-1)//2) ))
    aux = collect(1 + Int( floor((num_qubits-1)//2)):num_qubits-2)
    tgt = num_qubits-1
else
    ctrl = collect(0:num_qubits-2)
    aux = Int[]
    tgt = num_qubits-1
end

for i in ctrl
    QuantExQASM.Circuit.add_gatecall!(cct, QuantExQASM.GateOps.pauli_x(i) )
end

QuantExQASM.NCU.apply_ncu!(cct, ctrl, aux, tgt, gl);

# Number of generation gate-call operations
println(cct.circ_ops.len)
```