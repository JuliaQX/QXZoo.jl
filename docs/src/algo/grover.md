# Grover Search
The Grover.jl module implements a Grover's search use-case. Assisted by Oracle.jl and Diffusion.jl, the appropriate chosen test state is marked by applying an $n$CZ gate, and appropriately amplified through the required number of iterations $r\approx \pi\sqrt{2^{n+1}}/4$.

To apply the Grover search algorithm, we require additional functionalities in the form an oracle to select the required state, and a diffusion operator to shift the state ampltiudes.

## API
### oracle.jl
```@docs
QXZoo.Oracle.bitstring_ncu!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx, U::QXZoo.GateOps.GateSymbol)
QXZoo.Oracle.bitstring_ncu!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, aux_indices::Vector, tgt_idx, U::QXZoo.GateOps.GateSymbol)
QXZoo.Oracle.bitstring_phase_oracle!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, tgt_idx)
QXZoo.Oracle.bitstring_phase_oracle!(cct::QXZoo.Circuit.Circ, bitstring::Integer, ctrl_indices::Vector, aux_indices::Vector, tgt_idx)
```

### diffusion.jl
```@docs
QXZoo.Diffusion.apply_diffusion!(cct::QXZoo.Circuit.Circ, ctrl_indices::Vector, tgt_index)
QXZoo.Diffusion.apply_diffusion!(cct::QXZoo.Circuit.Circ, ctrl_indices::Vector, aux_indices::Vector, tgt_index)
```

```@docs
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

# Set 5-qubit limit on circuit
num_qubits = 5

# Set bit-pattern to 11 (0b01011)
bit_pattern = 11

# Do not use optimised routines
use_aux_qubits = false

# Create empty circuit with qiven qubit count
cct = QXZoo.Circuit.Circ(num_qubits)

# Initialise intermediate gates for use in NCU
QXZoo.NCU.init_intermed_gates(cct, num_qubits-1)

# Run Grover algorithm for given oracle bit-pattern
QXZoo.Grover.run_grover!(cct, collect(0:num_qubits-1), bit_pattern)
```

From here we can examine how many operations were generated as

```@example 1
println(cct)
```