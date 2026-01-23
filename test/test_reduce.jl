
@testset "reduce" begin
    @testset "all, any" begin
        A = rand(Z2Number, (13, 19))
        u = rand(Z2Number, (13,))
        v = Z2ColVector(rand(Z2Number, (19,)))

        @test !all(A)
        @test any(A)
        @test !all(u)
        @test any(u)
        @test !all(v)
        @test any(v)

        @test all(ones(Z2Number, (13, 19)))
        @test all(ones(Z2Number, (13,)))
        @test all(Z2ColVector(ones(Z2Number, (19,))))

        @test !any(zeros(Z2Number, (13, 19)))
        @test !any(zeros(Z2Number, (13,)))
        @test !any(Z2ColVector(zeros(Z2Number, (19,))))
    end    
end
