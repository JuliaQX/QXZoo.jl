using LinearAlgebra

@testset "Test NCU algorithm" begin
    @testset "Test default NCU with 2CX" begin
        cct1 = QXZoo.Circuit.Circ(3)
        cct2 = QXZoo.Circuit.Circ(3)
        QXZoo.NCU.apply_ncu!(cct1, collect(1:2), [], 3, DefaultGates.GateSymbols.c_x)

        cct2 << GateCall2(GateSymbol(:c_x, 1), 3, 2, nothing)
        cct2 << GateCall2(DefaultGates.GateSymbols.c_x, 2, 1, DefaultGates.GateSymbols.x)
        cct2 << GateCall2(GateSymbol(:c_x, 1, true), 3, 2, nothing)
        cct2 << GateCall2(DefaultGates.GateSymbols.c_x, 2, 1, DefaultGates.GateSymbols.x)
        cct2 << GateCall2(GateSymbol(:c_x, 1), 3, 1, nothing)

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

    @testset "Test default NCU with 3CX" begin
        cct1 = QXZoo.Circuit.Circ(4)
        cct2 = QXZoo.Circuit.Circ(4)
        QXZoo.NCU.apply_ncu!(cct1, collect(1:3), [], 4, DefaultGates.GateSymbols.c_x)

        cct2 << GateCall2(GateSymbol(:c_x, 2), 4, 1, nothing)
        cct2 << DefaultGates.c_x(2,1)
        cct2 << GateCall2(GateSymbol(:c_x, 2, true), 4, 2, nothing)
        cct2 << DefaultGates.c_x(2,1)
        cct2 << GateCall2(GateSymbol(:c_x, 2), 4, 2, nothing)
        cct2 << DefaultGates.c_x(3,2)
        cct2 << GateCall2(GateSymbol(:c_x, 2, true), 4, 3, nothing)
        cct2 << DefaultGates.c_x(3,1)
        cct2 << GateCall2(GateSymbol(:c_x, 2), 4, 3, nothing)
        cct2 << DefaultGates.c_x(3,2)
        cct2 << GateCall2(GateSymbol(:c_x, 2, true), 4, 3, nothing)
        cct2 << DefaultGates.c_x(3,1)
        cct2 << GateCall2(GateSymbol(:c_x, 2), 4, 3, nothing)

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


    @testset "Test aux. assisted NCU with 5CZ" begin
        cct1 = QXZoo.Circuit.Circ(9)
        cct2 = QXZoo.Circuit.Circ(9)
        QXZoo.NCU.apply_ncu!(cct1, collect(1:5), collect(6:8), 9, DefaultGates.GateSymbols.c_z)

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

end