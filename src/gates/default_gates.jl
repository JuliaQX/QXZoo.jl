module DefaultGates

using QXZoo.GateOps

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

    r_x(θ) = GateOps.GateSymbolP(Symbol("r_x(" * string(θ) * ")"), Dict("θ"=>θ))
    r_y(θ) = GateOps.GateSymbolP(Symbol("r_y(" * string(θ) * ")"), Dict("θ"=>θ))
    r_z(θ) = GateOps.GateSymbolP(Symbol("r_z(" * string(θ) * ")"), Dict("θ"=>θ))
    r_phase(θ) = GateOps.GateSymbolP(Symbol("r_ph(" * string(θ) * ")"), Dict("θ"=>θ))
    
    """Two qubit"""
    c_x = GateOps.GateSymbol(:c_x)
    c_y = GateOps.GateSymbol(:c_y)
    c_z = GateOps.GateSymbol(:c_z)
    c_H = GateOps.GateSymbol(:c_h)

    c_r_x(θ) = GateOps.GateSymbolP(Symbol("c_r_x(" * string(θ) * ")"), Dict("θ"=>θ))
    c_r_y(θ) = GateOps.GateSymbolP(Symbol("c_r_y(" * string(θ) * ")"), Dict("θ"=>θ))
    c_r_z(θ) = GateOps.GateSymbolP(Symbol("c_r_z(" * string(θ) * ")"), Dict("θ"=>θ))
    c_r_phase(θ) = GateOps.GateSymbolP(Symbol("c_r_ph(" * string(θ) * ")"), Dict("θ"=>θ))
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            1Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    x(q_target::Int)

Generate a single qubit Pauli-x GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.x(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:x, nothing), 0)
```
"""
function x(q_target::Integer)
    return GateOps.GateCall1(GateSymbols.x, q_target)
end

"""
    y(q_target::Int)

Generate a single qubit Pauli-y GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.y(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:y, nothing), 0)
```
"""
function y(q_target::Int)
    return GateOps.GateCall1(GateSymbols.y, q_target)
end

"""
    z(q_target::Int)

Generate a single qubit Pauli-z GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.z(0)
QXZoo.GateOps.GateCall1(QXZoo.GateOps.GateSymbol(:z, nothing), 0)
```
"""
function z(q_target::Int)
    return GateOps.GateCall1(GateSymbols.z, q_target)
end

"""
    h(q_target::Int)

Generate a single qubit Hadamard GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.h(0)
GateOps.GateCall1(GateOps.GateSymbol(:h, nothing), 0)
```
"""
function h(q_target::Int)
    return GateOps.GateCall1(GateSymbols.H, q_target)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    u(label::GateSymbol, q_target::Int)

Generate a single qubit arbitrary unitary GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.u(GateOps.GateSymbol(:mygate), 1)
GateOps.GateCall1(GateOps.GateSymbol(:mygate, nothing), 1)
```
"""
function u(label::GateSymbol, q_target::Int)
    return GateOps.GateCall1( label, q_target, register)
end
function u(label::String, q_target::Int)
    return GateOps.GateCall1( Symbol(label), q_target, register)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    r_x(q_target::Int, theta::Real)

Generate a single qubit R_x(θ) GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_x(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_x(1.5707963267948966)"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_x(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_x(theta), q_target )
end

"""
    r_y(q_target::Int, theta::Real)

Generate a single qubit R_y(θ) GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_y(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_y(1.5707963267948966)"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_y(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_y(theta), q_target )
end

"""
    r_z(q_target::Int, theta::Real)

Generate a single qubit R_z(θ) GateCall (GateCall1) applied to the target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_z(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_z_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_z(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_z(theta), q_target )
end

"""
    r_phase(q_target::Int, theta::Real)

Generate a single qubit phase shift GateCall ( diag(1, exp(1im*theta)) , GateCall1) applied to the target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_phase(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_phase_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_phase(q_target::Int, theta::Number)
    return GateOps.GateCall1(GateSymbols.r_phase(theta), q_target )
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            2Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

function swap(q_target::Int, q_ctrl::Int)
    return GateOps.GateCall2( GateOps.GateSymbol(:swp), q_target, q_ctrl )
end

"""
    c_x(q_target::Int, q_ctrl::Int)

Generate a controlled Pauli-x (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> GateOps.c_x(0, 1)
GateOps.GateCall2(GateOps.GateSymbol(:c_x, nothing), 0, 1, GateOps.GateCall1(GateOps.GateSymbol(:x, nothing), 0), )
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
julia> GateOps.c_y(0, 1)
GateOps.GateCall2(GateOps.GateSymbol(:c_y, nothing), 0, 1, GateOps.GateCall1(GateOps.GateSymbol(:y, nothing), 0))
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
julia> GateOps.c_z(0, 1)
GateOps.GateCall2(GateOps.GateSymbol(:c_z, nothing), 0, 1, GateOps.GateCall1(GateOps.GateSymbol(:z, nothing), 0) )
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
julia> GateOps.c_u(GateOps.GateSymbol(:myCU), 0, 1, GateOps.x(0))
GateOps.GateCall2(GateOps.GateSymbol(:myCU, nothing), 0, 1, GateOps.GateCall1(GateOps.GateSymbol(:x, nothing), 0, nothing))
```
"""
function c_u(label::GateOps.GateSymbol, q_target::Int, q_ctrl::Int)
    return GateCall2( label, q_target, q_ctrl)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    c_r_x(q_target::Int, q_ctrl::Int, theta::Real)

Generate a controlled rotation about x (exp(iθx/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.GateOps.c_r_x( 0, 1, pi/2)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(Symbol("c_r_x_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 1.5707963267948966)), 0, 1, nothing, nothing)
```
"""
function c_r_x(q_target::Int, q_ctrl::Int, theta::Real)
    return GateCall2( GateSymbols.c_r_x(theta), q_target, q_ctrl )
end

"""
    c_r_y(q_target::Int, q_ctrl::Int, theta::Real)

Generate a controlled rotation about y (exp(iθy/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target`.

# Examples
```julia-repl
julia> QXZoo.GateOps.c_r_y( 0, 1, pi/3)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(Symbol("c_r_y_angle=1.0471975511965976"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 1.0471975511965976)), 0, 1, nothing, nothing)
```
"""
function c_r_y(q_target::Int, q_ctrl::Int, theta::Real)
    return GateCall2( GateSymbols.c_r_y(theta), q_target, q_ctrl )
end

"""
    c_r_z(q_target::Int, q_ctrl::Int, theta::Real)

Generate a controlled rotation about z (exp(iθz/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QXZoo.GateOps.c_r_z( 0, 1, pi/4)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(Symbol("c_r_z_angle=0.7853981633974483"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 0.7853981633974483)), 0, 1, nothing, nothing)
```
"""
function c_r_z(q_target::Int, q_ctrl::Int, theta::Real)
    return GateCall2( GateSymbols.c_r_z(theta), q_target, q_ctrl )
end

"""
    c_r_phase(q_target::Int, q_ctrl::Int, theta::Real)

Generate a controlled phase rotation about (controlled [1 0; 0 exp(iθ)] GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QXZoo.GateOps.c_r_phase( 0, 1, pi/7)
QXZoo.GateOps.GateCall2(QXZoo.GateOps.GateSymbol(Symbol("c_r_phase(0.4487989505128276)"), Dict{String,Union{Bool, Number}}("angle" => 0.4487989505128276)), 0, 1, nothing, nothing)
```
"""
function c_r_phase(q_target::Int, q_ctrl::Int, theta::Real)
    return GateCall2( GateSymbols.c_r_phase(theta), q_target, q_ctrl )
end

end