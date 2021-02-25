# Random Quantum Circuits (RQC)
The `RQC` module aims to generate RQC capable of demonstrating results as those of Villalonga et al (npj Quantum Inf 5, 86 (2019)) and Arute et al. (Nature volume 574, 505–510 (2019)).

## API
### rqc.jl
```@docs
QXZoo.RQC.RQC_DS(n::Int, m::Int)
QXZoo.RQC.random_gate!(rqc::QXZoo.RQC.RQC_DS, i::Int, j::Int, rng::Random.MersenneTwister)
QXZoo.RQC.patterns(rqc::QXZoo.RQC.RQC_DS)
QXZoo.RQC.create_RQC(rows::Int, cols::Int, depth::Int, seed::Union{Int, Nothing}=nothing; use_iswap::Bool=false, final_Hadamard_layer::Bool=false)
```

## Example 
To use the Grover module, we provide example code below to search for a state in a 5-qubit quantum register marked by bit-pattern 11 (0b01011).

```@example 1
using QXZoo

# Set 2D qubit grid size and circuit depth
rows = 4
cols = 5
depth = 7

# Create RQC circuit using built-in generator
cct = QXZoo.RQC.create_RQC(rows, cols, depth)

println(cct)

for i in cct.circ_ops
    println(i)
end
```