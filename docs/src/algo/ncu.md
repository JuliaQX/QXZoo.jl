# NCU module
The NCU module enables the implementation of an $n$-qubit controlled unitary gate. In this instances, we have chosen to work primarily with $n$CX and $n$CZ gates, though others may also be used.

## Implementation
The general principle follows the work of Barenco *et al.*, Phys. Rev. A 52, 3457, (1995). All higher-order controlled quantum gates can be decomposed into 1 and 2 qubit gate calls, with varying degrees of optimisation. We implement the default quadratic gate decomposition strategy, alongside the 3CU optimised, and auxiliary register optimised variants.

## API

```@docs
QXZoo.NCU.apply_ncu!(circuit::QXZoo.Circuit.Circ, q_ctrl::Vector, q_aux::Vector, q_tgt, U::QXZoo.GateOps.GateSymbol)
QXZoo.NCU.get_intermed_gate(U::QXZoo.GateOps.GateSymbol)
```

## Example 
To use the NCU module, we provide example code below to apply an n-controlled Pauli Z gate using either the unoptimised (quadratic) or optimised (linear) decomposition routines.

### Default NCU with 3CU optimisation 
```@example
using QXZoo

# Set 10-qubit limit on circuit
num_qubits = 10

# Create Pauli-Z gate-label for application
gate_z = QXZoo.DefaultGates.GateSymbols.c_z

# Create empty circuit with qiven qubit count
cct = QXZoo.Circuit.Circ(num_qubits)

ctrl = collect(range(1, length=num_qubits  ) ) 
aux = []
tgt = num_qubits

for i in ctrl
    QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.x(i) )
end

QXZoo.NCU.apply_ncu!(cct, ctrl, aux, tgt, gate_z)

# Number of generation gate-call operations
println(cct)
```

### Auxiliary optimised NCU

```@example
# Auxiliary-assisted NCU

using QXZoo

# 19 qubit aux-optimised matches 10 qubit unoptimised.
num_qubits = 19

cct = QXZoo.Circuit.Circ(num_qubits)

ctrl = collect(1:10)
tgt = 11
aux =  collect(11:19)

for i in ctrl
    cct << QXZoo.DefaultGates.x(i)
end

QXZoo.NCU.apply_ncu!(cct, ctrl, aux, tgt, DefaultGates.GateSymbols.c_z)

println(cct)
```