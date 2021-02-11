
@testset "Test QFT module" begin
    @testset "Test forward QFT" begin
        num_qubits = 5
        num_gates = num_qubits*(num_qubits+1)/2
        cct1 = QXZoo.Circuit.Circ(num_qubits)
        cct2 = QXZoo.Circuit.Circ(num_qubits)
        QXZoo.QFT.apply_qft!(cct1, collect(1:num_qubits))

        cct2 << DefaultGates.h(1)
        cct2 << DefaultGates.c_r_phase(1, 2, π/2)
        cct2 << DefaultGates.c_r_phase(1, 3, π/4)
        cct2 << DefaultGates.c_r_phase(1, 4, π/8)
        cct2 << DefaultGates.c_r_phase(1, 5, π/16)
        cct2 << DefaultGates.h(2)
        cct2 << DefaultGates.c_r_phase(2, 3, π/2)
        cct2 << DefaultGates.c_r_phase(2, 4, π/4)
        cct2 << DefaultGates.c_r_phase(2, 5, π/8)
        cct2 << DefaultGates.h(3)
        cct2 << DefaultGates.c_r_phase(3, 4, π/2)
        cct2 << DefaultGates.c_r_phase(3, 5, π/4)
        cct2 << DefaultGates.h(4)
        cct2 << DefaultGates.c_r_phase(4, 5, π/2)
        cct2 << DefaultGates.h(5)
        cct2 << CompositeGates.swap(1,5)
        cct2 << CompositeGates.swap(2,4)

        num_swaps = Int(floor(num_qubits/2))
        @test cct1.circ_ops.len == num_gates + num_swaps
        
        @test cct1.gate_set == cct2.gate_set

        h1 = cct1.circ_ops.head
        h2 = cct2.circ_ops.head
        for i in 1:cct1.circ_ops.len
            @test h1.data === h2.data
            h1 = h1.next
            h2 = h2.next
        end
    end
    @testset "Test inverse QFT" begin
        num_qubits = 5
        num_gates = num_qubits*(num_qubits+1)/2

        cct1 = QXZoo.Circuit.Circ(num_qubits)
        cct2 = QXZoo.Circuit.Circ(num_qubits)

        QXZoo.QFT.apply_iqft!(cct1, collect(1:num_qubits))

        cct2 << CompositeGates.swap(2,4)
        cct2 << CompositeGates.swap(1,5)

        cct2 << DefaultGates.h(5)
        cct2 << DefaultGates.c_r_phase(4, 5, -π/2)
        cct2 << DefaultGates.h(4)
        cct2 << DefaultGates.c_r_phase(3, 5, -π/4)
        cct2 << DefaultGates.c_r_phase(3, 4, -π/2)
        cct2 << DefaultGates.h(3)
        cct2 << DefaultGates.c_r_phase(2, 5, -π/8)
        cct2 << DefaultGates.c_r_phase(2, 4, -π/4)
        cct2 << DefaultGates.c_r_phase(2, 3, -π/2)
        cct2 << DefaultGates.h(2)
        cct2 << DefaultGates.c_r_phase(1, 5, -π/16)
        cct2 << DefaultGates.c_r_phase(1, 4, -π/8)
        cct2 << DefaultGates.c_r_phase(1, 3, -π/4)
        cct2 << DefaultGates.c_r_phase(1, 2, -π/2)
        cct2 << DefaultGates.h(1)

        num_swaps = Int(floor(num_qubits/2))
        @test cct1.circ_ops.len == num_gates + num_swaps
        
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