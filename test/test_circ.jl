using LinearAlgebra

@testset "Test QXZoo Circ" begin

    @testset "Test circuit creation" begin
        @testset "Test empty circuit" begin
            @test begin
                cct = QXZoo.Circuit.Circ()
                cct.num_qubits == 0
                cct.circ_ops.len == 0
                length(cct.gate_set) == 0
            end
        end

        @testset "Test gate n-qubit circuit" begin
            cct = QXZoo.Circuit.Circ(5)
            cct << QXZoo.DefaultGates.x(1)
            @test length(cct.gate_set) == 1
            @test cct.circ_ops.len == 1
            @test cct.num_qubits == 5
            @test_throws ErrorException cct << QXZoo.DefaultGates.x(6)
            @test_throws ErrorException cct << QXZoo.DefaultGates.c_x(1,6)
            @test_throws ErrorException cct << QXZoo.DefaultGates.c_x(6,1)
        end

        @testset "Test circuit iteration" begin
            cct1 = QXZoo.Circuit.Circ(5)

            for i in 1:5
                cct1 << QXZoo.DefaultGates.x(i)
            end

            for i in cct1.circ_ops
                @test i.gate_symbol === QXZoo.DefaultGates.GateSymbols.x
            end
        end

        @testset "Test defined gateset" begin
            gates = Set([QXZoo.DefaultGates.GateSymbols.x, QXZoo.DefaultGates.GateSymbols.h, QXZoo.DefaultGates.GateSymbols.r_phase(pi/5)])
            cct = QXZoo.Circuit.Circ(5, gates)
            @test cct.num_qubits == 5
            @test cct.gate_set == gates
        end

        @testset "Test circuit combine" begin
            cct1 = QXZoo.Circuit.Circ(5)
            cct2 = QXZoo.Circuit.Circ(5)
            cct3 = QXZoo.Circuit.Circ(5)
            cct4 = QXZoo.Circuit.Circ(6)

            for i in 1:5
                cct1 << QXZoo.DefaultGates.x(i)
                cct3 << QXZoo.DefaultGates.x(i)
                cct4 << QXZoo.DefaultGates.x(i)
            end
            for i in 1:4
                cct2 << QXZoo.DefaultGates.c_x(i, i+1)
                cct3 << QXZoo.DefaultGates.c_x(i, i+1)
                cct4 << QXZoo.DefaultGates.c_x(i, i+1)
            end

            @test cct3.circ_ops.len == cct1.circ_ops.len + cct2.circ_ops.len
            @test cct3.gate_set == union(cct1.gate_set, cct2.gate_set)
            
            cct1 << cct2
            
            @test cct3.circ_ops.len == cct1.circ_ops.len
            @test cct2.circ_ops.len == 0
            @test cct3.gate_set == cct1.gate_set

            h1 = cct1.circ_ops.head
            h3 = cct3.circ_ops.head

            for i in 1:cct1.circ_ops.len
                @test h1.data === h3.data
                h1 = h1.next
                h3 = h3.next
            end

            @test_throws ErrorException cct3 << cct4

        end
    end
end