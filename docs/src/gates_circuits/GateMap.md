# GateMap

Given many algorithms will have repeated use of specific custom or parametric gates, it can be useful to store these for later use. In addition, to allow use of the `GateSymbol` type to represent numeric matrices, we require a location to provide this mapping. This module operates as this cache, and allows sotrage for gates generated during the circuit creation.

The `GateMap.gates` dictionary defines a mapping between `GateSymbols` & `Functions` to a given generator `Function`. To aid with ease of translation and extensibility, additional platforms may define the base gate mappings here to generator the required out structures for a given target platform.

For our use as a framework for creating tensor network simulations, we map the required `GateSymbols` and `Functions` to produce `StaticArrays` types for numerical representation.

## Utility and types
```@docs
QXZoo.GateMap.gates
QXZoo.GateMap.init_cache()
QXZoo.GateMap.cache_gate!(key::Union{QXZoo.GateOps.GateSymbol, QXZoo.GateOps.GateSymbolP, Function}, mat_func::Function)
QXZoo.GateMap.clear_cache()

QXZoo.GateMap.create_gate_1q(gate_label::String, gen_func::Function)
QXZoo.GateMap.create_gate_1q(gate_label::String, mat::Array{<:Number,2})
QXZoo.GateMap.create_gate_2q(gate_label::String, gen_func::Function)
QXZoo.GateMap.create_gate_2q(gate_label::String, mat::Array{<:Number,2})
```

## Gate generator functions
```@docs
QXZoo.GateMap.p00()
QXZoo.GateMap.p01()
QXZoo.GateMap.p10()
QXZoo.GateMap.p11()

QXZoo.GateMap.x()
QXZoo.GateMap.y()
QXZoo.GateMap.z()
QXZoo.GateMap.h()
QXZoo.GateMap.I()

QXZoo.GateMap.r_x(θ::Number)
QXZoo.GateMap.r_y(θ::Number)
QXZoo.GateMap.r_z(θ::Number)
QXZoo.GateMap.r_phase(θ::Number)

QXZoo.GateMap.c_x()
QXZoo.GateMap.c_y()
QXZoo.GateMap.c_z()
```