using QuantZoo.GateOps

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            Default gate symbols
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

module GateSymbols

    module Q1
        σ_x = GateOps.GateSymbol(:x)
        σ_y = GateOps.GateSymbol(:y)
        σ_z = GateOps.GateSymbol(:z)
        H = GateOps.GateSymbol(:h)

        r_σ_x(θ) = GateOps.GateSymbol(Symbol("r_x(" * string(θ) * ")"), Dict("angle"=>θ))
        r_σ_y(θ) = GateOps.GateSymbol(Symbol("r_y(" * string(θ) * ")"), Dict("angle"=>θ))
        r_σ_z(θ) = GateOps.GateSymbol(Symbol("r_z(" * string(θ) * ")"), Dict("angle"=>θ))
        r_phase(θ) = GateOps.GateSymbol(Symbol("r_ph(" * string(θ) * ")"), Dict("angle"=>θ))
    end

    module Q2
        c_σ_x = GateOps.GateSymbol(:c_x)
        c_σ_y = GateOps.GateSymbol(:c_y)
        c_σ_z = GateOps.GateSymbol(:c_z)
        c_H = GateOps.GateSymbol(:c_h)

        c_r_σ_x(θ) = GateOps.GateSymbol(Symbol("c_r_x(" * string(θ) * ")"), Dict("angle"=>θ))
        c_r_σ_y(θ) = GateOps.GateSymbol(Symbol("c_r_y(" * string(θ) * ")"), Dict("angle"=>θ))
        c_r_σ_z(θ) = GateOps.GateSymbol(Symbol("c_r_z(" * string(θ) * ")"), Dict("angle"=>θ))
        c_r_phase(θ) = GateOps.GateSymbol(Symbol("c_r_ph(" * string(θ) * ")"), Dict("angle"=>θ))
    end

end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            1Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    pauli_x(q_target::Int, register::Union{String, Nothing}=nothing)

Generate a single qubit Pauli-x GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.x(0, "q")
QuantZoo.GateOps.GateCall1(QuantZoo.GateOps.GateSymbol(:x, nothing), 0, "q")
```
"""
function x(q_target::Integer, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.σ_x, q_target)
    else
        return GateOps.GateCall1(GateSymbols.Q1.σ_x, q_target, register)
    end
end

"""
    y(q_target::Int, register::Union{String, Nothing}=nothing)

Generate a single qubit Pauli-y GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.y(0, "q")
QuantZoo.GateOps.GateCall1(QuantZoo.GateOps.GateSymbol(:y, nothing), 0, "q")
```
"""
function y(q_target::Int, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.σ_y, q_target)
    else
        return GateOps.GateCall1(GateSymbols.Q1.σ_y, q_target, register)
    end
end

"""
    z(q_target::Int, register::Union{String, Nothing}=nothing)

Generate a single qubit Pauli-z GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.z(0, "q")
QuantZoo.GateOps.GateCall1(QuantZoo.GateOps.GateSymbol(:z, nothing), 0, "q")
```
"""
function z(q_target::Int, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.σ_z, q_target)
    else
        return GateOps.GateCall1(GateSymbols.Q1.σ_z, q_target, register)
    end
end

"""
    h(q_target::Int, register::Union{String, Nothing}=nothing)

Generate a single qubit Hadamard GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.h(0, "q")
GateOps.GateCall1(GateOps.GateSymbol(:h, nothing), 0, "q")
```
"""
function h(q_target::Int, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.H, q_target)
    else
        return GateOps.GateCall1(GateSymbols.H, q_target, register)
    end
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    u(label::GateSymbol, q_target::Int, register::Union{String, Nothing}=nothing)

Generate a single qubit arbitrary unitary GateCall (GateCall1) applied to the 
target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.u(GateOps.GateSymbol(:mygate), 1, "qr")
GateOps.GateCall1(GateOps.GateSymbol(:mygate, nothing), 1, "qr")
```
"""
function u(label::GateSymbol, q_target::Int, register::Union{String, Nothing}=nothing)
    return GateOps.GateCall1( label, q_target, register)
end
function u(label::String, q_target::Int, register::Union{String, Nothing}=nothing)
    return GateOps.GateCall1( Symbol(label), q_target, register)
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    r_x(q_target::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a single qubit R_x(θ) GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_x(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_x(1.5707963267948966)"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_x(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_x(theta), q_target )
    else
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_x(theta), q_target, register )
    end
end

"""
    r_y(q_target::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a single qubit R_y(θ) GateCall (GateCall1) applied to the target qubit 
(on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_y(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_y(1.5707963267948966)"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_y(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_y(theta), q_target )
    else
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_y(theta), q_target, register )
    end
end

"""
    r_z(q_target::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a single qubit R_z(θ) GateCall (GateCall1) applied to the target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_z(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_z_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_z(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_z(theta), q_target )
    else
        return GateOps.GateCall1(GateSymbols.Q1.r_σ_z(theta), q_target, register )
    end
end

"""
    r_phase(q_target::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a single qubit phase shift GateCall ( diag(1, exp(1im*theta)) , GateCall1) applied to the target qubit (on given register, if provided)

# Examples
```julia-repl
julia> GateOps.r_phase(3,pi/2)
GateOps.GateCall1(GateOps.GateSymbol(Symbol("r_phase_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle"=>1.5708)), 3, nothing)
```
"""
function r_phase(q_target::Int, theta::Number, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall1(GateSymbols.Q1.r_phase(theta), q_target )
    else
        return GateOps.GateCall1(GateSymbols.Q1.r_phase(theta), q_target, register )
    end
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#                            2Q Gate calls ops
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

function swap(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateOps.GateCall2( GateLabel(:swp), q_target, q_ctrl )
    else
        return GateOps.GateCall2( GateLabel(:swp), q_target, q_ctrl, register )
    end
end

"""
    c_pauli_x(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)

Generate a controlled Pauli-x (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> GateOps.c_pauli_x(0, 1, "qreg")
GateOps.GateCall2(GateOps.GateLabel(:c_x, nothing), 0, 1, GateOps.GateCall1(GateOps.GateLabel(:x, nothing), 0, "qreg"), "qreg")
```
"""
function c_pauli_x(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
    return GateCall2( GateLabel(:c_x), q_target, q_ctrl, pauli_x(q_target,register), register)
end

"""
    c_pauli_y(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)

Generate a controlled Pauli-y (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> GateOps.c_pauli_y(0, 1, "qreg")
GateOps.GateCall2(GateOps.GateLabel(:c_y, nothing), 0, 1, GateOps.GateCall1(GateOps.GateLabel(:y, nothing), 0, "qreg"), "qreg")
```
"""
function c_pauli_y(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
    return GateCall2( GateLabel(:c_y), q_target, q_ctrl, pauli_y(q_target,register), register)
end

"""
    c_pauli_z(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)

Generate a controlled Pauli-x (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> GateOps.c_pauli_z(0, 1, "qreg")
GateOps.GateCall2(GateOps.GateLabel(:c_z, nothing), 0, 1, GateOps.GateCall1(GateOps.GateLabel(:z, nothing), 0, "qreg"), "qreg")
```
"""
function c_pauli_z(q_target::Int, q_ctrl::Int, register::Union{String, Nothing}=nothing)
    return GateCall2( GateLabel(:c_z), q_target, q_ctrl, pauli_z(q_target,register), register)
end

function c_u(label::String, q_target::Int, q_ctrl::Int, params::Dict, register::Union{String, Nothing}=nothing)
    return GateCall2( GateLabel( Symbol(label), params), q_target, q_ctrl, register)
end

"""
    c_u(label::GateLabel, q_target::Int, q_ctrl::Int, gc::GateCall1, register::Union{String, Nothing}=nothing)

Generate a controlled unitary (two qubit) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> GateOps.c_u(GateOps.GateLabel(:myCU), 0, 1, GateOps.pauli_x(0), "q")
GateOps.GateCall2(GateOps.GateLabel(:myCU, nothing), 0, 1, GateOps.GateCall1(GateOps.GateLabel(:x, nothing), 0, nothing), "q")
```
"""
function c_u(label::GateLabel, q_target::Int, q_ctrl::Int, gc::GateCall1, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateCall2( label, q_target, q_ctrl, gc)
    else
        return GateCall2( label, q_target, q_ctrl, gc, register)
    end
end

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #

"""
    c_r_x(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a controlled rotation about x (exp(iθσ_x/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QuantZoo.GateOps.c_r_x( 0, 1, pi/2, "q")
QuantZoo.GateOps.GateCall2(QuantZoo.GateOps.GateLabel(Symbol("c_r_x_angle=1.5707963267948966"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 1.5707963267948966)), 0, 1, nothing, nothing)
```
"""
function c_r_x(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateCall2( GateSymbols.Q2.c_r_x(theta), q_target, q_ctrl )
    else
        return GateCall2( GateSymbols.Q2.c_r_x(theta), q_target, q_ctrl, register )
    end
end

"""
    c_r_y(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a controlled rotation about y (exp(iθσ_y/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QuantZoo.GateOps.c_r_y( 0, 1, pi/3, "q")
QuantZoo.GateOps.GateCall2(QuantZoo.GateOps.GateLabel(Symbol("c_r_y_angle=1.0471975511965976"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 1.0471975511965976)), 0, 1, nothing, nothing)
```
"""
function c_r_y(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateCall2( GateSymbols.Q2.c_r_y(theta), q_target, q_ctrl )
    else
        return GateCall2( GateSymbols.Q2.c_r_y(theta), q_target, q_ctrl, register )
    end
end

"""
    c_r_z(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a controlled rotation about z (exp(iθσ_z/2)) GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QuantZoo.GateOps.c_r_z( 0, 1, pi/4, "q")
QuantZoo.GateOps.GateCall2(QuantZoo.GateOps.GateLabel(Symbol("c_r_z_angle=0.7853981633974483"), Dict{String,Union{Bool, Float64, Int64}}("angle" => 0.7853981633974483)), 0, 1, nothing, nothing)
```
"""
function c_r_z(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateCall2( GateSymbols.Q2.c_r_z(theta), q_target, q_ctrl )
    else
        return GateCall2( GateSymbols.Q2.c_r_z(theta), q_target, q_ctrl, register)
    end
end

"""
    c_r_phase(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)

Generate a controlled phase rotation about (controlled [1 0; 0 exp(iθ)] GateCall (GateCall2), controlled on the index `q_ctrl` applied to the target `q_target` (on given register, if provided).

# Examples
```julia-repl
julia> QuantZoo.GateOps.c_r_phase( 0, 1, pi/7, "q")
QuantZoo.GateOps.GateCall2(QuantZoo.GateOps.GateLabel(Symbol("c_r_phase(0.4487989505128276)"), Dict{String,Union{Bool, Number}}("angle" => 0.4487989505128276)), 0, 1, nothing, nothing)
```
"""
function c_r_phase(q_target::Int, q_ctrl::Int, theta::Real, register::Union{String, Nothing}=nothing)
    if register == nothing
        return GateCall2( GateSymbols.Q2.c_r_phase(theta), q_target, q_ctrl )
    else
        return GateCall2( GateSymbols.Q2.c_r_phase(theta), q_target, q_ctrl, register )
    end
end