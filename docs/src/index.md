# QuantExQASM.jl Documentation

*QuantExQASM.jl* is a generator suite for quantum algorithms. Using a high-level approach to quantum circuit design, we create quantum circuits taking note of all intermediate gate-calls between qubits, performing operation caching and optimisation where possible. 

Currently, we support a limited set of quantum algoritms (see the `Algorithms` dropdown for details), where the resulting methods can be used to generate OpenQASM output, or integrated with the `PicoQuant.jl` package to create and run a tensor network simulation.
