# Examples
To best use the QXZoo.jl package, we provide some examples below of expected use-cases.

## 1. Creating an empty 5-qubit circuit and add default gates
```@example
using QXZoo

# Create a 5-qubit Circ struct from the Circuit module to organise gates
circ = Circuit.Circ(5)

# Insert Pauli gates into the circuit for given qubit indices
circ << DefaultGates.x(1) #explicit location
circ << y(2) #using exported symbols
circ << h(3)

# Default gate addition function call
Circuit.add_gatecall!(circ, DefaultGates.z(4))

circ << DefaultGates.c_x(1,5)
circ << c_z(2,5)

println(circ)
println(circ.gate_set)
```

## 2. Combining existing circuits
This example creates two separate circuits, and combines their operations. Not that the second circuit will close ownership of all its operations following a combine step.

```@example
using QXZoo

# Create two 8-qubit Circ struct from the Circuit module to organise gates
circ1 = Circuit.Circ(8)
circ2 = Circuit.Circ(8)

circ1 << x(1)
circ1 << c_y(1,2)
circ1 << h(3)
println(circ1)
println(circ1.gate_set)

circ2 << c_x(1,2)
circ2 << c_z(3,1)
circ2 << c_x(1,3)
println(circ2)
println(circ2.gate_set)

# The following operation performs the combination
# append!(circ1,circ2) withe short-hand given below
circ1 << circ2

println(circ1)
println(circ1.gate_set)
println(circ2)
println(circ2.gate_set)
```

## 3. Using parametric gates
Many quantum circuits require parametric (e.g. rotation) gates. Here we demonstrate their usage.

```@example
using QXZoo

# Create two 8-qubit Circ struct from the Circuit module to organise gates
circ = Circuit.Circ(5)

circ << r_x(1, pi/4)
circ << r_y(2, pi/3)
circ << r_y(3, 1)
circ << c_r_y(1, 3, pi/9)
circ << c_r_x(1, 3, pi/2)
circ << c_r_phase(1, 3, -pi/2)
println(circ)
println(circ.gate_set)
```

## 4. Creating custom gates
Custom gates can also be used. First, we must register the gate with the GateMap cache utility. The gate may then be used with the `u` functions and return GateSymbol struct.

```@example
using QXZoo

# Single qubit gates

function custom_gate_1q()
    return [1 0; 0 -1im]
end

my_gate = create_gate_1q("my_gate", custom_gate_1q)

# Two qubit gates

function custom_gate_2q()
    return kron([1 0; 0 1], [1 0; 0 1])
end

my_gate_2 = create_gate_2q("my_gate_2", custom_gate_2q)

# Create two 8-qubit Circ struct from the Circuit module to organise gates
circ = Circuit.Circ(5)

circ << u(my_gate, 1)

circ << c_u(my_gate_2, 1, 2)

println(circ)
println(circ.gate_set)
```
