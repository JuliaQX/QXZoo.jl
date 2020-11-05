# Grover Search
The Grover.jl module implements a Grover's search use-case. Assisted by Oracle.jl and Diffusion.jl, the appropriate chosen test state is marked by applying an $n$CZ gate, and appropriately amplified through the required number of iterations $r\approx \pi\sqrt{2^{n+1}}/4$.

## API

```@docs
QuantExQASM.Grover.run_grover!(cct::QuantExQASM.Circuit.Circ, qubit_indices::Vector, state::Integer)
QuantExQASM.Grover.mark_state!(cct::QuantExQASM.Circuit.Circ, state::Integer, qubit_indices::Vector)
QuantExQASM.Grover.apply_grover_iteration!(cct::QuantExQASM.Circuit.Circ, qubit_indices::Vector)
QuantExQASM.Grover.state_init!(cct::QuantExQASM.Circuit.Circ, qubit_indices::Vector)
QuantExQASM.Grover.calc_iterations(num_states::Integer)
QuantExQASM.Grover.apply_x!(cct::QuantExQASM.Circuit.Circ, tgt, reg::Union{String, Nothing}=nothing) 
QuantExQASM.Grover.apply_h!(cct::QuantExQASM.Circuit.Circ, tgt, reg::Union{String, Nothing}=nothing)
```


## Example 
To use the Grover module, we provide example code below to search for a state in a 5-qubit quantum register marked by bit-pattern 11 (0b01011).

```@example 1
using QuantExQASM

# Set 5-qubit limit on circuit
num_qubits = 5

# Set bit-pattern to 11 (0b01011)
bit_pattern = 11

# Do not use optimised routines
use_aux_qubits = false

# Create empty circuit with qiven qubit count
cct = QuantExQASM.Circuit.Circ(num_qubits)

# Initialise intermediate gates for use in NCU
QuantExQASM.NCU.init_intermed_gates(cct, num_qubits-1)

# Run Grover algorithm for given oracle bit-pattern
QuantExQASM.Grover.run_grover!(cct, collect(0:num_qubits-1), bit_pattern)
```

From here we can examine how many operations were generated as

```@example 1
println(cct.circ_ops.len)
```

We can also generate the OpenQASM equivalent circuit as

```@example 1
# Convert circuit to QASM populated buffer
cct_s = QuantExQASM.Circuit.to_qasm(cct, true)

# Print first 8 lines of QASM file
for i in split( String(cct_s), "\n")[1:8]
    println(i)
end
```