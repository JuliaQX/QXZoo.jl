using LinearAlgebra

@testset "Test QXZoo gates" begin

    @testset "Test fundamental gate structs" begin
        @testset "GateSymbol" begin
            gs1 = QXZoo.GateSymbol(:label)
            gs2 = QXZoo.GateSymbol(:label, 2)
            gs3 = QXZoo.GateSymbol(:label, 1, true)
            gs4 = sqrt(gs1)
            gs5 = adjoint(gs1)
            @test begin
                gs1.label == :label
                gs1.rt_depth == 0
                gs1.is_adj == false
            end
            @test begin
                gs2.label == :label
                gs2.rt_depth == 2
                gs2.is_adj == false
            end
            @test begin
                gs3.label == :label
                gs3.rt_depth == 1
                gs3.is_adj == true
            end
            @test begin
                gs4.label == gs1.label
                gs4.rt_depth == 1
                gs4.is_adj == false
            end
            @test begin
                gs5.label == gs1.label
                gs5.rt_depth == 0
                gs5.is_adj == true
            end
        end
        @testset "GateSymbolP" begin
            gs1 = QXZoo.GateSymbolP(:label)
            gs2 = QXZoo.GateSymbolP(:label, 2)
            gs3 = QXZoo.GateSymbolP(:label, 1, true)
            gs4 = QXZoo.GateSymbolP(:label, 3, true, pi/7)
            @test begin
                gs1.label == :label
                gs1.rt_depth == 0
                gs1.is_adj == false
                gs1.param === 0
            end
            @test begin
                gs2.label == :label
                gs2.rt_depth == 2
                gs2.is_adj == false
                gs2.param === 0
            end
            @test begin
                gs3.label == :label
                gs3.rt_depth == 1
                gs3.is_adj == true
                gs3.param === 0
            end
            @test begin
                gs4.label == :label
                gs4.rt_depth == 1
                gs4.is_adj == true
                gs4.param === pi/7
            end
        end
        @testset "GateCall1" begin
            gs1 = QXZoo.GateSymbol(:label)
            gc1 = QXZoo.GateCall1(gs1, 3)

            @test begin
                gc1.gate_symbol == gs1
                gc1.target == 3
            end
        end
        @testset "GateCall2" begin
            gs1 = QXZoo.GateSymbol(:c_x, 0, false)
            gs2 = QXZoo.GateSymbolP(:asdf, 0, false, pi/5)
            gc1 = QXZoo.GateCall2(gs1, 2, 3, QXZoo.GateSymbol(:x))
            gc2 = QXZoo.GateCall2(gs2, 1, 2 )

            @test begin
                gc1.gate_symbol == gs1
                gc1.ctrl == 2
                gc1.target == 3
                gc1.base_gate == QXZoo.DefaultGates.GateSymbols.x
                gc2.gate_symbol == gs2
                gc2.ctrl == 1
                gc2.target == 2
                gc2.base_gate === nothing
            end
        end
    end

    @testset "Test default gate structs" begin
        @testset "Default GateSymbol structs" begin
            @test begin
                DefaultGates.GateSymbols.p00 === GateOps.GateSymbol(:p00)
                DefaultGates.GateSymbols.p01 === GateOps.GateSymbol(:p01)
                QXZoo.DefaultGates.GateSymbols.p10 === GateOps.GateSymbol(:p10)
                QXZoo.DefaultGates.GateSymbols.p11 === GateOps.GateSymbol(:p11)
                QXZoo.DefaultGates.GateSymbols.x === GateOps.GateSymbol(:x)
                QXZoo.DefaultGates.GateSymbols.y === GateOps.GateSymbol(:y)
                QXZoo.DefaultGates.GateSymbols.z === GateOps.GateSymbol(:z)

                QXZoo.DefaultGates.GateSymbols.s === GateOps.GateSymbol(:z, 1, false)
                QXZoo.DefaultGates.GateSymbols.t === GateOps.GateSymbol(:z, 2, false)
                QXZoo.DefaultGates.GateSymbols.h === GateOps.GateSymbol(:h)
                QXZoo.DefaultGates.GateSymbols.I === GateOps.GateSymbol(:I)
            end
        end
    end

    @testset "Test single-qubit gate values" begin
        @testset "Test static gates" begin
            @test begin # Individual tests
                QXZoo.GateMap.x() == [0 1; 1 0]
                QXZoo.GateMap.y() == [0 -1im; 1im 0]
                QXZoo.GateMap.z() == [1 0; 0 -1]
                QXZoo.GateMap.h() == [1 1; 1 -1].*(1/sqrt(2))
                QXZoo.GateMap.I() == [1 0; 0 1]

                QXZoo.GateMap.s() == sqrt(QXZoo.GateMap.z())
                QXZoo.GateMap.t() == sqrt(QXZoo.GateMap.s())

                QXZoo.GateMap.p00() == [1 0; 0 0]
                QXZoo.GateMap.p01() == [0 1; 0 0]
                QXZoo.GateMap.p10() == [0 0; 1 0]
                QXZoo.GateMap.p11() == [0 0; 0 1]
            end
            
            @test begin # identity tests
                QXZoo.GateMap.z() ≈ QXZoo.GateMap.h() * QXZoo.GateMap.x() * QXZoo.GateMap.h()
                -QXZoo.GateMap.y() ≈ QXZoo.GateMap.h() * QXZoo.GateMap.y() * QXZoo.GateMap.h()
                QXZoo.GateMap.x() ≈ QXZoo.GateMap.h() * QXZoo.GateMap.z() * QXZoo.GateMap.h()
            end

            @test begin # 
                QXZoo.GateMap.r_x(0) == QXZoo.GateMap.I()
                QXZoo.GateMap.r_y(0) == QXZoo.GateMap.I()
                QXZoo.GateMap.r_z(0) == QXZoo.GateMap.I()
                QXZoo.GateMap.r_phase(0) == QXZoo.GateMap.I()
            end
        end

        @testset "Test rotation gates" begin
            for θ in range(0, 2*pi, step=pi/5)
                @test QXZoo.GateMap.r_x(θ) ≈ cos(θ/2)*[1 0; 0 1] - 1im*sin(θ/2)*QXZoo.GateMap.x()
                @test QXZoo.GateMap.r_y(θ) ≈ cos(θ/2)*[1 0; 0 1] - 1im*sin(θ/2)*QXZoo.GateMap.y()
                @test QXZoo.GateMap.r_z(θ) ≈ cos(θ/2)*[1 0; 0 1] - 1im*sin(θ/2)*QXZoo.GateMap.z()
            end

            for θ in range(0, 2*pi, step=pi/5)
                @test QXZoo.GateMap.r_z(θ) ≈ QXZoo.GateMap.r_y(-pi/2) * QXZoo.GateMap.r_x(θ) * QXZoo.GateMap.r_y(pi/2)
            end
        end
    end

    @testset "Test two-qubit gate values" begin

        @test begin # Individual tests
            QXZoo.GateMap.c_x() == [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]
            QXZoo.GateMap.c_y() == [1 0 0 0; 0 1 0 0; 0 0 0 -1im; 0 0 1im 0]
            QXZoo.GateMap.c_z() == LinearAlgebra.Diagonal([1,1,1,-1])
        end

        @testset "Test rotation gates" begin
            for θ in range(0, 2*pi, step=pi/5)
                @test (QXZoo.GateMap.c_r_x(θ) - (kron(QXZoo.GateMap.p00(), QXZoo.GateMap.I()) + kron(QXZoo.GateMap.p11(), QXZoo.GateMap.r_x(θ)))) ≈ zeros(4,4)

                @test  (QXZoo.GateMap.c_r_y(θ) - (kron(QXZoo.GateMap.p00(), QXZoo.GateMap.I()) + kron(QXZoo.GateMap.p11(), QXZoo.GateMap.r_y(θ)))) ≈ zeros(4,4)

                @test  (QXZoo.GateMap.c_r_z(θ) - (kron(QXZoo.GateMap.p00(), QXZoo.GateMap.I()) + kron(QXZoo.GateMap.p11(), QXZoo.GateMap.r_z(θ)))) ≈ zeros(4,4)

                @test (QXZoo.GateMap.c_r_phase(θ) - (kron(QXZoo.GateMap.p00(), QXZoo.GateMap.I()) + kron(QXZoo.GateMap.p11(), QXZoo.GateMap.r_phase(θ)))) ≈ zeros(4,4)
            end
        end
    end

    @testset "Test custom gates" begin

        @test begin # Individual tests
            gate_func_1q = () -> [0 -1; 1 0].+0im
            q1 = GateMap.create_gate_1q("test_1q", gate_func_1q)
            GateMap.gates[q1]() == gate_func_1q()
            GateMap.gates[GateSymbol(:test_1q, 0, false)]() == gate_func_1q()
        end

        @test begin # Individual tests
            gate_func_1q_p = (a) -> [cos(a) -1; 1 sin(a)].+0im
            q1 = GateMap.create_gate_1q("test_1q_p", gate_func_1q_p)
            GateMap.gates[q1](pi/2) == gate_func_1q_p(pi/2)
        end

    end

end
