# Circuits 

To compose a quantum algorithm, we need a structured manner for representing the gate calls, as defined in [GateOps.md](GateOps.md). 

## Circuit.jl
The `Circuit.jl` module allows us to structure the gate-calls into a quantum circuit representation. Circuits are appendable, pushable, and are represented under the hood as a doubly linked-list (`CList` from module `CircuitList.jl`), to allow ease of further optimisation and manipulation, if required.

The Circuit module also maintains a cached mapping from GateLabels to numerical matrices, wherein new gates created are stored for later use by other circuits. This memoization improves the performance of constructing circuits involving calculating sub-matrices (see the algorithms modules for examples).

```@docs
QuantExQASM.Circuit.Circ
QuantExQASM.Circuit.Circ()
QuantExQASM.Circuit.Circ(num_qubits)

QuantExQASM.Circuit.add_to_cache(label::QuantExQASM.GateOps.GateLabel, mat::Matrix{<:Number})
QuantExQASM.Circuit.add_gatecall!(circ::QuantExQASM.Circuit.Circ, gc::QuantExQASM.GateOps.GateCall1)
QuantExQASM.Circuit.add_gatecall!(circ::QuantExQASM.Circuit.Circ, gc::QuantExQASM.GateOps.GateCall2)

QuantExQASM.Circuit.to_string(circ::QuantExQASM.Circuit.Circ)
QuantExQASM.Circuit.gatelabel_to_qasm(gl::QuantExQASM.GateOps.GateLabel)
QuantExQASM.Circuit.gatecall_to_qasm(gc::QuantExQASM.GateOps.GateCall1)
QuantExQASM.Circuit.gatecall_to_qasm(gc::QuantExQASM.GateOps.GateCall2)

QuantExQASM.Circuit.add_header(num_qubits::Int, reg::String="q", creg::String="c")
QuantExQASM.Circuit.to_qasm(circ::QuantExQASM.Circuit.Circ, header::Bool=true, filename::Union{String, Nothing}=nothing)
```