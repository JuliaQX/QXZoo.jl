# Circuits 

To compose a quantum algorithm, we need a structured manner for representing the gate calls, as defined in [GateOps.md](GateOps.md). 

## Circuit.jl
The `Circuit.jl` module allows us to structure the gate-calls into a quantum circuit representation. Circuits are appendable, pushable, and are represented under the hood as a doubly linked-list (see `circuits/utils/DLList.jl`), to allow ease of further optimisation and manipulation, if required.

The Circuit module also maintains a cached mapping from GateSymbols to numerical matrices, wherein new gates created are stored for later use by other circuits. This memoization improves the performance of constructing circuits involving calculating sub-matrices (see the algorithms modules for examples).

```@docs
QXZoo.Circuit.Circ
QXZoo.Circuit.Circ()
QXZoo.Circuit.Circ(num_qubits::Int)
QXZoo.Circuit.Circ(num_qubits::Int, gate_set::Set{<:QXZoo.GateOps.AGateSymbol})

QXZoo.Circuit.num_qubits(circuit::QXZoo.Circuit.Circ)

QXZoo.Circuit.add_gatecall!(circ::QXZoo.Circuit.Circ, gc::QXZoo.GateOps.GateCall1)
QXZoo.Circuit.add_gatecall!(circ::QXZoo.Circuit.Circ, gc::QXZoo.GateOps.GateCall2)
```

```@example
using QXZoo

qubits = 10

# Create empty circuit with qiven qubit count
cct = QXZoo.Circuit.Circ(qubits)

for i in 1:9
    QXZoo.Circuit.add_gatecall!(cct, QXZoo.DefaultGates.x(i) )
end

# Additional way to add a gate
cct << QXZoo.DefaultGates.z(10)

println(cct)
```