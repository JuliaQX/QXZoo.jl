
@testset "Test RQC module" begin
    @testset "Test 2D indexing" begin
        @testset "2D -> 1D Rectangular (5x7)" begin
            x_dim = 5
            y_dim = 7
            Av=Vector(1:x_dim*y_dim)
            A = reshape(Av, (x_dim,y_dim))
            for j in 1:x_dim
                for i in 1:y_dim
                    @test Av[QXZoo.RQC.lin_idx(i, j, x_dim)] == A[j,i]
                end
            end
        end
        @testset "2D -> 1D Square even (4x4)" begin
            x_dim = 4
            y_dim = 4
            Av=Vector(1:x_dim*y_dim)
            A = reshape(Av, (x_dim,y_dim))
            for j in 1:x_dim
                for i in 1:y_dim
                    @test Av[QXZoo.RQC.lin_idx(i, j, x_dim)] == A[j,i]
                end
            end
        end
        @testset "2D -> 1D Square odd (5x5)" begin
            x_dim = 5
            y_dim = 5
            Av=Vector(1:x_dim*y_dim)
            A = reshape(Av, (x_dim,y_dim))
            for j in 1:x_dim
                for i in 1:y_dim
                    @test Av[QXZoo.RQC.lin_idx(i, j, x_dim)] == A[j,i]
                end
            end
        end

        @testset "1D -> 2D Rectangular (5x7)" begin
            x_dim = 5
            y_dim = 7
            Av=Vector(1:x_dim*y_dim)
            A = reshape(Av, (x_dim,y_dim))
            for i in 1:x_dim*y_dim
                @test Av[i] == A[QXZoo.RQC.grid_idx(i, x_dim)...]
            end
        end
    end

    @testset "RQC struct" begin
        xdim=4
        ydim=5
        rqc_ds = QXZoo.RQC.RQC_DS(xdim, ydim)
        
        @test rqc_ds.circ.num_qubits == xdim*ydim

        @test rqc_ds.single_qubit_gates[1] == GateSymbol(:z, 2, false)
        @test rqc_ds.single_qubit_gates[2] == GateSymbol(:x, 1, false)
        @test rqc_ds.single_qubit_gates[3] == GateSymbol(:y, 1, false)

        for i in 1:xdim*ydim
            @test rqc_ds.next_gate[i] == -1
        end
    end

    @testset "RQC random gate" begin
        # Need a better test-cases here; difficult due to stochastic nature of RQC
        xdim=4
        ydim=5
        depth = 6

        rqc_ds = QXZoo.RQC.RQC_DS(xdim, ydim)
        rqc = QXZoo.RQC.create_RQC(xdim, ydim, depth)
        
        @test rqc.gate_set == Set((GateSymbol(:z, 2, false), GateSymbol(:x, 1, false), GateSymbol(:y, 1, false), GateSymbol(:c_z, 0, false), GateSymbol(:h, 0, false)))

    end
end