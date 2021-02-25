# Composite Gates
This module is used for gates that can be composed of more fundamental gate operations. For simplicity, we refer to these as `Composite Gates`, and represent them as their numerical matrix values.

## CompositeGates.GateSymbols
As in `DefaultGates`, we store symbols for the gates available in CompositeGates, and generator functions for parameteric variants of these gates. This allows us to track the mappings as to be used by the gate type hierarchy and architecture.

### Two Qubit Gates: static
```@docs
QXZoo.CompositeGates.swap(q_target1::Int, q_target2::Int)
QXZoo.CompositeGates.iswap(q_target1::Int, q_target2::Int)
```

### Two Qubit Gates: rotation
```@docs
QXZoo.CompositeGates.xx(q_target1::Int, q_target2::Int, θ::Number)
QXZoo.CompositeGates.yy(q_target1::Int, q_target2::Int, θ::Number)
QXZoo.CompositeGates.zz(q_target1::Int, q_target2::Int, θ::Number)
```