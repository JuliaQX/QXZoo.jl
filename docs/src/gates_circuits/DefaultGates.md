# DefaultGates

## DefaultGates.GateSymbols
Here we store symbols for the gates available in DefaultGates, and generator functions for parameteric variants of these gates. This allos us to track the mappings as to be used by the gate type hierarchy and architecture.


## Commonly used gates
The functions in this module allow use to create a `QXZoo.GateOps.AGateCall` struct for a given qubit target and symbol type.

### Single Qubit Gates: default
```@docs
QXZoo.DefaultGates.x(q_target::Int)
QXZoo.DefaultGates.y(q_target::Int)
QXZoo.DefaultGates.z(q_target::Int)
QXZoo.DefaultGates.h(q_target::Int)
QXZoo.DefaultGates.s(q_target::Int)
QXZoo.DefaultGates.t(q_target::Int)
```

### Single Qubit Gates: rotation and arbitrary
```@docs
QXZoo.DefaultGates.u(label::QXZoo.GateOps.GateSymbol, q_target::Int )
QXZoo.DefaultGates.r_x(q_target::Int, theta::Number )
QXZoo.DefaultGates.r_y(q_target::Int, theta::Number )
QXZoo.DefaultGates.r_z(q_target::Int, theta::Number )
QXZoo.DefaultGates.r_phase(q_target::Int, theta::Number )
```

### Two Qubit Gates: default
```@docs
QXZoo.DefaultGates.c_x(q_target::Int, q_ctrl::Int )
QXZoo.DefaultGates.c_y(q_target::Int, q_ctrl::Int )
QXZoo.DefaultGates.c_z(q_target::Int, q_ctrl::Int )
```

### Two Qubit Gates: rotation and arbitrary
```@docs
QXZoo.DefaultGates.c_u(label::QXZoo.GateOps.GateSymbol, q_target::Int, q_ctrl::Int )
QXZoo.DefaultGates.c_r_x(q_target::Int, q_ctrl::Int, theta::Number )
QXZoo.DefaultGates.c_r_y(q_target::Int, q_ctrl::Int, theta::Number )
QXZoo.DefaultGates.c_r_z(q_target::Int, q_ctrl::Int, theta::Number )
QXZoo.DefaultGates.c_r_phase(q_target::Int, q_ctrl::Int, theta::Number )
```