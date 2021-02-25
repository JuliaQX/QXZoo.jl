# Quantum Fourier Transform (QFT)
The `QFT` module enables the creation of circuit for $n$-qubit quantum Fourier transforms, and their inverses.

## API
### rqc.jl
```@docs
QXZoo.QFT.apply_qft!(cct::QXZoo.Circuit.Circ, qubit_indices::Vector)
QXZoo.QFT.apply_qft!(cct::QXZoo.Circuit.Circ)
QXZoo.QFT.apply_iqft!(cct::QXZoo.Circuit.Circ, qubit_indices::Vector)
QXZoo.QFT.apply_iqft!(cct::QXZoo.Circuit.Circ)
QXZoo.QFT.swap_idx(qubit_indices::Vector)
```

## Example 
The following demonstrates the application of the QFT to a subset of qubits in the register, and the IQFT to the entire register.

```@example 1
using QXZoo

cct = QXZoo.Circuit.Circ(8)

QXZoo.QFT.apply_qft!(cct, collect(1:4))
QXZoo.QFT.apply_iqft!(cct)

println(cct)

for i in cct.circ_ops
    println(i)
end
```
