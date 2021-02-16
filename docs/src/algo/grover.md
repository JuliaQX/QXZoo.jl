# Grover Search
The Grover.jl module implements a Grover's search use-case. Assisted by Oracle.jl and Diffusion.jl, the appropriate chosen test state is marked by applying an $n$CZ gate, and appropriately amplified through the required number of iterations $r\approx \pi\sqrt{2^{n+1}}/4$.

To apply the Grover search algorithm, we require additional functionalities in the form an oracle to select the required state, and a diffusion operator to shift the state ampltiudes.

## API
```@docs
QXZoo.Grover.bitstring_ncu!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, U::QXZoo.GateOps.GateSymbol, aux_indices::Vector=Int[])
QXZoo.Grover.bitstring_phase_oracle!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx::Int, aux_indices::Vector=Int[])
QXZoo.Grover.apply_diffusion!(cct::QXZoo.Circuit.Circ, ctrl_indices::Vector, tgt_index::Int, aux_indices::Vector=Int[])
QXZoo.Grover.run_grover!(cct::QXZoo.Circuit.Circ, qubit_indices::Vector, state::Integer)
QXZoo.Grover.mark_state!(cct::QXZoo.Circuit.Circ, state::Integer, qubit_indices::Vector)
QXZoo.Grover.apply_grover_iteration!(cct::QXZoo.Circuit.Circ, qubit_indices::Vector)
QXZoo.Grover.state_init!(cct::QXZoo.Circuit.Circ, qubit_indices::Vector)
QXZoo.Grover.calc_iterations(num_states::Integer)
```

## Example 
To use the Grover module, we provide example code below to search for a state in a 5-qubit quantum register marked by bit-pattern 11 (0b01011).

```@example 1
using QXZoo

# Set 6-qubit limit on circuit
num_qubits = 10

# Set bit-pattern to 11 (0b01011)
bit_pattern = 11

# Create empty circuit with qiven qubit count
cct = QXZoo.Circuit.Circ(num_qubits)

# Run Grover algorithm for given oracle bit-pattern
QXZoo.Grover.run_grover!(cct, collect(1:num_qubits), bit_pattern)

println(cct)
```

Similarly, for an optimised variant of the same operations using more qubits:

```@example 2
using QXZoo

# Set 6-qubit limit on circuit
num_qubits = 19

qubits_range = 1:Int((num_qubits+1)/2) + 1 
aux_range = Int((num_qubits+1)/2 + 2):num_qubits

# Set bit-pattern to 11 (0b01011)
bit_pattern = 11

# Create empty circuit with qiven qubit count
cct = QXZoo.Circuit.Circ(num_qubits)

# Run Grover algorithm for given oracle bit-pattern
QXZoo.Grover.run_grover!(cct, collect(qubits_range), bit_pattern, collect(aux_range))

println(cct)
```