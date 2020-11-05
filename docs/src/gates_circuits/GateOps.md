# Gate Operations

## Gate type-system hierarchy
Abstraction of types for representing gates.
```@docs
QuantExQASM.GateOps.AGate
QuantExQASM.GateOps.AGateLabel
QuantExQASM.GateOps.AGateCall
```

### GateLabel and GateCall
Specific gate instance in a circuit, applied to a given (set of) qubit(s).

```@docs
QuantExQASM.GateOps.GateLabelP{IType<:Integer, NType<:Number}
QuantExQASM.GateOps.GateCall1P{IType<:Integer, NType<:Number}
QuantExQASM.GateOps.GateCall2P{IType<:Integer, NType<:Number}
QuantExQASM.GateOps.GateCallNP{IType<:Integer, NType<:Number}
QuantExQASM.GateOps.Gate
```

### Single Qubit Gates: default
```@docs
QuantExQASM.GateOps.pauli_x(q_target::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.pauli_y(q_target::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.pauli_z(q_target::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.hadamard(q_target::Int, register::Union{String, Nothing}=nothing)
```

### Single Qubit Gates: rotation and arbitrary
```@docs
QuantExQASM.GateOps.u(label::QuantExQASM.GateOps.GateLabel, q_target::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.r_x(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.r_y(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.r_z(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.r_phase(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
```

### Two Qubit Gates: default
```@docs
QuantExQASM.GateOps.c_pauli_x(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_pauli_y(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_pauli_z(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
```

### Two Qubit Gates: rotation and arbitrary
```@docs
QuantExQASM.GateOps.c_u(label::QuantExQASM.GateOps.GateLabel, q_target::Int, q_ctrl::Int, gc::QuantExQASM.GateOps.GateCall1, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_r_x(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_r_y(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_r_z(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
QuantExQASM.GateOps.c_r_phase(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
```