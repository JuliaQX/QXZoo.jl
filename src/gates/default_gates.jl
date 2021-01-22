module DefaultGates

using QXZoo.GateOps

export x, y, z, h, c_x, c_y, c_z, u
export r_x, r_y, r_z, r_phase, c_r_x, c_r_y, c_r_z, c_u, c_r_phase

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            Default gate symbols
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

module GateSymbols
    using QXZoo.GateOps

    """Projection operators"""
    p00 = GateOps.GateSymbol(:p00) # |0><0|
    p10 = GateOps.GateSymbol(:p10) # |1><0|
    p01 = GateOps.GateSymbol(:p01) # |0><1|
    p11 = GateOps.GateSymbol(:p11) # |1><1|

    """Single qubit"""
    x = GateOps.GateSymbol(:x)
    y = GateOps.GateSymbol(:y)
    z = GateOps.GateSymbol(:z)
    H = GateOps.GateSymbol(:h)
    I = GateOps.GateSymbol(:I)

    r_x(θ) = GateOps.GateSymbolP(:r_x, 0, false, θ)
    r_y(θ) = GateOps.GateSymbolP(:r_y, 0, false, θ)
    r_z(θ) = GateOps.GateSymbolP(:r_z, 0, false, θ)
    r_phase(θ) = GateOps.GateSymbolP(:r_phase, 0, false, θ)
    
    """Two qubit"""
    c_x = GateOps.GateSymbol(:c_x)
    c_y = GateOps.GateSymbol(:c_y)
    c_z = GateOps.GateSymbol(:c_z)
    c_H = GateOps.GateSymbol(:c_h)

    c_r_x(θ) = GateOps.GateSymbolP(:c_r_x, 0, false, θ)
    c_r_y(θ) = GateOps.GateSymbolP(:c_r_y, 0, false, θ)
    c_r_z(θ) = GateOps.GateSymbolP(:c_r_z, 0, false, θ)
    c_r_phase(θ) = GateOps.GateSymbolP(:c_r_phase, 0, false, θ)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            1Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    x(q_target::Int)

Generate a single qubit Pauli-x GateCall (GateCall1) applied to the target qubit 

# Examples
```julia-repl
julia> QXZoo.DefaultGates.x(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:x, 0, false), 0)
```
"""
function x(q_target::Integer)
    return GateOps.GateCall1(GateSymbols.x, q_target)
end

"""
    y(q_target::Int)

Generate a single qubit Pauli-y GateCall (GateCall1) applied to the 
target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.y(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:y, 0, false), 0)
```
"""
function y(q_target::Int)
    return GateOps.GateCall1(GateSymbols.y, q_target)
end

"""
    z(q_target::Int)

Generate a single qubit Pauli-z GateCall (GateCall1) applied to the 
target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.z(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:z, 0, false), 0)
```
"""
function z(q_target::Int)
    return GateOps.GateCall1(GateSymbols.z, q_target)
end

"""
    h(q_target::Int)

Generate a single qubit Hadamard GateCall (GateCall1) applied to the 
target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.h(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:h, 0, false), 0)
```
"""
function h(q_target::Int)
    return GateOps.GateCall1(GateSymbols.H, q_target)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    u(label::GateSymbol, q_target::Int)

Generate a single qubit arbitrary unitary GateCall (GateCall1) applied to the 
target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.u(QXZoo.GateOps.GateSymbol(:mygate), 1)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:mygate, 0, false), 1)
```
"""
function u(label::GateSymbol, q_target::Int)
    return GateOps.GateCall1( label, q_target)
end
"""
    u(label::String, q_target::Int)

Generate a single qubit arbitrary unitary GateCall (GateCall1) applied to the 
target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.u("mygate", 1)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:mygate, 0, false), 0)
```
"""
function u(label::String, q_target::Int)
    return GateOps.GateCall1( QXZoo.GateOps.GateSymbol(Symbol(label)), q_target)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    r_x(q_target::Int, theta::Number)

Generate a single qubit R_x(θ) GateCall (GateCall1) applied to the target qubit 

# Examples
```julia-repl
julia> QXZoo.DefaultGates.r_x(3,pi/2)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbolP(:r_x, 0, false, 1.5707963267948966), 3)
```
"""
function r_x(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_x(theta), q_target )
end

"""
    r_y(q_target::Int, theta::Number)

Generate a single qubit R_y(θ) GateCall (GateCall1) applied to the target qubit.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.r_y(3,pi/2)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbolP(:r_y, 0, false, 1.5707963267948966), 3)
```
"""
function r_y(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_y(theta), q_target )
end

"""
    r_z(q_target::Int, theta::Number)

Generate a single qubit R_z(θ) GateCall (GateCall1) applied to the target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.r_z(3,pi/2)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbolP(:r_z, 0, false, 1.5707963267948966), 3)
```
"""
function r_z(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_z(theta), q_target )
end

"""
    r_phase(q_target::Int, theta::Number)

Generate a single qubit phase shift GateCall ( diag(1, exp(1im*theta)) , GateCall1) applied to the target qubit

# Examples
```julia-repl
julia> QXZoo.DefaultGates.r_phase(3,pi/2)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbolP(:r_phase, 0, false, 1.5707963267948966), 3)
```
"""
function r_phase(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_phase(theta), q_target )
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            2Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    swap(q_target::Int, q_ctrl::Int)

Apply swap gate between given qubits

# Examples
```julia-repl
julia> QXZoo.DefaultGates.swap(0,1)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(:swap, 0, false), 0, 1, nothing)
```
"""
function swap(q_target::Int, q_ctrl::Int)
    return GateOps.GateCall2( GateOps.GateSymbol(:swap), q_target, q_ctrl )
end

"""
    c_x(q_target::Int, q_ctrl::Int)

Generate a controlled Pauli-x (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_x(0, 1)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(:c_x, 0, false), 0, 1, QXZoo.GateOps.GateSymbol(:x, 0, false))
```
"""
function c_x(q_target::Int, q_ctrl::Int)
    return GateCall2( GateSymbols.c_x, q_target, q_ctrl, GateSymbols.x )
end

"""
    c_y(q_target::Int, q_ctrl::Int)

Generate a controlled Pauli-y (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_y(0, 1)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(:c_y, 0, false), 0, 1, QXZoo.GateOps.GateSymbol(:y, 0, false))
```
"""
function c_y(q_target::Int, q_ctrl::Int)
    return GateCall2( GateSymbols.c_y, q_target, q_ctrl, GateSymbols.y )
end

"""
    c_z(q_target::Int, q_ctrl::Int)

Generate a controlled Pauli-x (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_z(0, 1)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(:c_z, 0, false), 0, 1, QXZoo.GateOps.GateSymbol(:z, 0, false))
```
"""
function c_z(q_target::Int, q_ctrl::Int)
    return GateCall2( GateSymbols.c_z, q_target, q_ctrl, GateSymbols.z )
end

"""
    c_u(label::GateSymbol, q_target::Int, q_ctrl::Int)

Generate a controlled unitary (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_u(QXZoo.GateOps.GateSymbol(:myCU), 0, 1)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(:myCU, 0, false), 0, 1, nothing)
```
"""
function c_u(label::GateOps.GateSymbol, q_target::Int, q_ctrl::Int)
    return GateCall2( label, q_target, q_ctrl)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    c_r_x(q_target::Int, q_ctrl::Int, theta::Number)

Generate a controlled rotation about x (exp(-iθx/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_r_x( 0, 1, pi/2)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbolP(:c_r_x, 0, false, 1.5707963267948966), 0, 1, nothing)
```
"""
function c_r_x(q_target::Int, q_ctrl::Int, theta::Number)
    return GateCall2( GateSymbols.c_r_x(theta), q_target, q_ctrl )
end

"""
    c_r_y(q_target::Int, q_ctrl::Int, theta::Number)

Generate a controlled rotation about y (exp(iθy/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_r_y( 0, 1, pi/3)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbolP(:c_r_y, 0, false, 1.0471975511965976), 0, 1, nothing)
```
"""
function c_r_y(q_target::Int, q_ctrl::Int, theta::Number)
    return GateCall2( GateSymbols.c_r_y(theta), q_target, q_ctrl )
end

"""
    c_r_z(q_target::Int, q_ctrl::Int, theta::Number)

Generate a controlled rotation about z (exp(iθz/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_r_z( 0, 1, pi/4)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbolP(:c_r_z, 0, false, 0.7853981633974483), 0, 1, nothing)
```
"""
function c_r_z(q_target::Int, q_ctrl::Int, theta::Number)
    return GateCall2( GateSymbols.c_r_z(theta), q_target, q_ctrl )
end

"""
    c_r_phase(q_target::Int, q_ctrl::Int, theta::Real)

Generate a controlled phase rotation about (controlled [1 0; 0 exp(iθ)] GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.DefaultGates.c_r_phase( 0, 1, pi/7 )
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbolP(:c_r_phase, 0, false, 0.4487989505128276), 0, 1, nothing)
```
"""
function c_r_phase(q_target::Int, q_ctrl::Int, theta::Number)
    return GateCall2( GateSymbols.c_r_phase(theta), q_target, q_ctrl )
end

end