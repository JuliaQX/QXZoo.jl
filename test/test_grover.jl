using LinearAlgebra


"""
Functions to ensure gate call counts match expected number
"""
function ncu_gate_calls_default(n::Int)
    @assert n >= 2
    
    if n == 2
        return 5
    else
        return 3*ncu_gate_calls_default(n-1) + 2
    end
end

function ncu_gate_calls_opt(n::Int)
    @assert n >= 3
    if n == 3
        return 13
    else
        return 3*ncu_gate_calls_opt(n-1) + 2
    end
end


@testset "Test Grover algorithm" begin
    @testset "Test diffusion operator" begin
        cct = QXZoo.Circuit.Circ(5)
    end

    @testset "Test bitstring oracle operator" begin
        cct1 = QXZoo.Circuit.Circ(9)
        cct2 = QXZoo.Circuit.Circ(9)
        QXZoo.Grover.bitstring_ncu!(cct1, 11, collect(1:5), 9, DefaultGates.GateSymbols.c_x, collect(6:8))

        cct2 << DefaultGates.x(3)
        cct2 << DefaultGates.x(5)
        cct2 << DefaultGates.x(9)
        QXZoo.NCU.apply_ncu!(cct2, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        cct2 << DefaultGates.x(9)
        cct2 << DefaultGates.x(5)
        cct2 << DefaultGates.x(3)

        # X @ (0b00100, 0b10000)*2
        @test cct1.circ_ops.len == cct2.circ_ops.len
        
        @test cct1.gate_set == cct2.gate_set

        h1 = cct1.circ_ops.head
        h2 = cct2.circ_ops.head
        for i in 1:cct1.circ_ops.len
            @test h1.data === h2.data
            h1 = h1.next
            h2 = h2.next
        end
    end

    @testset "Test phase oracle operator" begin
        cct1 = QXZoo.Circuit.Circ(6)
        cct2 = QXZoo.Circuit.Circ(9)
        cct3 = QXZoo.Circuit.Circ(9)
        QXZoo.Grover.bitstring_phase_oracle!(cct1, 11, collect(1:5), 6)
        QXZoo.Grover.bitstring_phase_oracle!(cct2, 11, collect(1:5), 9, collect(6:8))

        cct3 << DefaultGates.x(3)
        cct3 << DefaultGates.x(5)
        cct3 << DefaultGates.x(9)
        cct3 << DefaultGates.h(9)
        QXZoo.NCU.apply_ncu!(cct3, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct3, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        cct3 << DefaultGates.h(9)
        cct3 << DefaultGates.x(9)
        cct3 << DefaultGates.x(5)
        cct3 << DefaultGates.x(3)

        # X @ (0b00100, 0b10000)*2 + 2 Hadamard
        @test cct1.circ_ops.len == ncu_gate_calls_opt(5) + 6 
        @test cct2.gate_set == cct3.gate_set

        h2 = cct2.circ_ops.head
        h3 = cct3.circ_ops.head
        for i in 1:cct2.circ_ops.len
            @test h2.data === h3.data
            h2 = h2.next
            h3 = h3.next
        end
    end

    @testset "Test diffusion operator" begin
        cct1 = QXZoo.Circuit.Circ(9)
        cct2 = QXZoo.Circuit.Circ(9)
        QXZoo.Grover.apply_diffusion!(cct1, collect(1:5), 9, collect(6:8))

        for i in 1:5
            cct2 << DefaultGates.h(i)
            cct2 << DefaultGates.x(i)
        end
        cct2 << DefaultGates.h(9)
        cct2 << DefaultGates.x(9)
        
        cct2 << DefaultGates.h(9)
        QXZoo.NCU.apply_ncu!(cct2, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [5,8], [], 9, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [1,2], [], 6, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [3,6], [], 7, DefaultGates.GateSymbols.c_x)
        QXZoo.NCU.apply_ncu!(cct2, [4,7], [], 8, DefaultGates.GateSymbols.c_x)
        cct2 << DefaultGates.h(9)

        for i in 1:5
            cct2 << DefaultGates.x(i)
            cct2 << DefaultGates.h(i)
        end
        cct2 << DefaultGates.x(9)
        cct2 << DefaultGates.h(9)

        @test cct1.circ_ops.len == cct2.circ_ops.len
        
        @test cct1.gate_set == cct2.gate_set

        h1 = cct1.circ_ops.head;
        h2 = cct2.circ_ops.head;
        for i in 1:cct1.circ_ops.len
            @test h1.data === h2.data
            h1 = h1.next
            h2 = h2.next
        end
    end

    @testset "Test Grover combined" begin
        cct = QXZoo.Circuit.Circ(5)
        indices = collect(1:cct.num_qubits)
        QXZoo.Grover.run_grover!(cct, indices, 11)
    end
end