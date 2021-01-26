module RQC
using QXZoo.Circuit
using QXZoo.GateMap
using QXZoo.DefaultGates
using QXZoo.GateOps
using Random

# *************************************************************************** #
#                              RQC functions
# *************************************************************************** #

"""
    lin_idx(i,j)

Linearise 2D indices to 1D as [i,j] -> i*(max_i-1) + j
"""
function lin_idx(i, j, max_i)
    return i*(max_i-1) + j
end

"Struct to represent a random quantum circuit"
struct RQC_DS
    # The dimensions of the 2-dimensional array of qubits.
    n::Int
    m::Int

    # Circuit object to house gates
    circ::Circuit.Circ

    # A 2-dimensional array of integers to keep track of which single qubit
    # gate should next be applied to a given qubit in the circuit.
    # The integers map to gates as follows:
    # 1 => T, 2 => sqrt(X), 3 => sqrt(Y).
    # The sign of the integer is used to indicate if the corresponding qubit
    # has been hit by a two qubit gate and can be hit by a single qubit gate.
    # This should be initialised as an array of ones as the first single qubit
    # gate is always a T gate.
    next_gate::Array{Int, 2}

    # A dictionary to convert integers from the above array into gates
    single_qubit_gates::Dict{Int, AGateSymbol}
end


function RQC_DS(n::Int, m::Int)
    RQC_DS(n, m, Circuit.Circ(n*m), -ones(Int, n, m),
        Dict(1=>DefaultGates.GateSymbols.t, 2=>sqrt(DefaultGates.GateSymbols.x), 3=>sqrt(DefaultGates.GateSymbols.y)) )
end

"""
    random_gate!(rqc::RQC, i::Int, j::Int)

Returns the gate name for the next single qubit gate to be applied to the qubit
at (i, j).
"""
function random_gate!(rqc::RQC_DS, i::Int, j::Int, rng::MersenneTwister)
    gate = rqc.next_gate[i, j]
    if gate > 0
        rqc.next_gate[i, j] = (rqc.next_gate[i, j] + rand(rng, [0,1]))%3 + 1
        rqc.next_gate[i, j] *= -1
        return rqc.single_qubit_gates[gate]
    else
        return nothing
    end
end

"""
    patterns(rqc::RQC)

Generate a dictionary of patterns of qubit pairs to apply two qubit gates to.
The patterns are numbers 1 to 8 like in Boxio_2018 but in a different order.
(Note, the order used in Boxio_2018 is 3, 1, 6, 8, 5, 7, 2, 4)
"""
function patterns(rqc::RQC_DS)
    key = 1
    gp = Dict()
    N = max(rqc.m, rqc.n)
    for v in [1, -1]
        for shift in [0, 1]
            for flip in [false, true]
                gp[key] = [[[i, j], [i, j+v]] for j in 1:2:N
                                              for i in 1+((j+shift)÷2)%2:2:N]
                if flip; gp[key] = map(x->reverse.(x), gp[key]); end
                filter!(gp[key]) do p
                    out_of_bounds(rqc, p)
                end
                key += 1
            end
        end
    end
    gp
end

"""
    out_of_bounds(rqc::RQC, targets::Array{Array{Int, 1}, 1})

Check if any of the qubits, in the given qubit pair, are out of bounds.
"""
function out_of_bounds(rqc::RQC_DS, targets::Array{Array{Int, 1}, 1})
    ((i, j), (u, v)) = targets
    (0 < i <= rqc.n) && (0 < u <= rqc.n) &&
    (0 < j <= rqc.m) && (0 < v <= rqc.m)
end

"""
    create_RQC(rows::Int, cols::Int, depth::Int,
                        seed::Union{Int, Nothing}=nothing;
                        use_iswap::Bool=false,
                        final_Hadamard_layer::Bool=false)

Generate a random quantum circuit with a (rows x cols) grid of qubits. The
parameter 'depth' is the number of one and two qubit gate layers to be used in
the circuit.

The single qubit gates used are chossen randomly from the set
{T, sqrt(X), sqrt(Y)}. The seed for the random selection can be set with the
seed parameter.

CZ gates are used by default as the two qubit gates. 
[TODO] Setting 'use_iswap' to true will use iSWAP gates inplace of CZ gates.

Setting 'final_Hadamard_layer' to true will include a layer of Hadamard gates
at the end of the circuit.
"""
function create_RQC(rows::Int, cols::Int, depth::Int,
                    seed::Union{Int, Nothing}=nothing;
                    use_iswap::Bool=false,
                    final_Hadamard_layer::Bool=false)

    if seed === nothing
        rng = MersenneTwister()
    else
        rng = MersenneTwister(seed)
    end

    # Create an empty rqc.
    rqc = RQC_DS(rows, cols)

    # A dictionary to map gate names to methods that add the
    # corresponding gate to the rqc.
    # TODO: x and y should be replaced by sqrt of x and y
    gates = Dict("h" => DefaultGates.h, "cz" => DefaultGates.c_z, "t" => DefaultGates.t,
                 "x" => target -> rqc.circ.rx(pi/2, target),
                 "y" => target -> rqc.circ.ry(pi/2, target) )

    # The rqc starts with a layer of hadamard gates applied to all qubits.
    for i in 1:rqc.n, j in 1:rqc.m
        rqc.circ << DefaultGates.h((i-1)*rqc.n + j)
    end

    # Get the patterns to apply two qubit gates in.
    gate_patterns = patterns(rqc)

    # Loop through the patterns applying the two qubit gates and apply a random
    # single qubit gate to the appropriate qubits.
    pattern = [3, 1, 6, 8, 5, 7, 2, 4]
    two_qubit_gate = use_iswap ? nothing : DefaultGates.c_z
    for i in 0:depth-1
        i = pattern[i%8 + 1]

        if !(length(gate_patterns[i]) == 0)
            # Apply the two qubit gates.
            for targets in gate_patterns[i]
                rqc.circ << two_qubit_gate( lin_idx(targets[2][2], targets[2][1], rqc.n),  lin_idx(targets[1][2], targets[1][1], rqc.n))
            end

            # Apply the single qubit gates
            qubits_hit = reduce(vcat, gate_patterns[i])
            for i in 1:rqc.n, j in 1:rqc.m
                if !([i, j] in qubits_hit)
                    gate = random_gate!(rqc, i, j, rng)
                    if gate !== nothing
                        rqc.circ << DefaultGates.u(gate, lin_idx(i, j, rqc.n))
                    end
                end
            end

            # Update rqc with which qubits were hit by a two qubit gate
            # and so may be hit by a single qubit gate next round.
            for ((i, j), (u, v)) in gate_patterns[i]
                rqc.next_gate[i, j] = abs(rqc.next_gate[i, j])
                rqc.next_gate[u, v] = abs(rqc.next_gate[u, v])
            end
        end

        #rqc.circ.barrier()
    end

    if final_Hadamard_layer
        for i in 1:rqc.n, j in 1:rqc.m
            rqc.circ << DefaultGates.h((i-1)*rqc.n + j)
        end
    end

    rqc.circ
end

end