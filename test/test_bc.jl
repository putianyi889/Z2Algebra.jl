
@testset "broadcast" begin
    @testset "vec & adjvec" begin
        u1 = rand(Z2Number, 13)
        u2 = rand(Z2Number, 19)
        v1 = Z2ColVector(rand(Z2Number, 13))
        v2 = Z2ColVector(rand(Z2Number, 19))

        A1 = u1 .+ v2'
        @test A1 isa Z2Matrix{Matrix{Z2Block}}
        @test A1 == Vector(u1) .+ Vector(v2)'

        A2 = u1 .+ u2'
        @test A2 isa Z2Matrix{Matrix{Z2Block}}
        @test A2 == Vector(u1) .+ Vector(u2)'

        A3 = v1 .+ v2'
        @test A3 isa Z2Matrix{Matrix{Z2Block}}
        @test A3 == Vector(v1) .+ Vector(v2)'

        A4 = v1 .+ u2'
        @test A4 isa Z2Matrix{Matrix{Z2Block}}
        @test A4 == Vector(v1) .+ Vector(u2)'

        B1 = u1 .* v2'
        @test B1 isa Z2Matrix{Matrix{Z2Block}}
        @test B1 == Vector(u1) .* Vector(v2)'

        B2 = u1 .* u2'
        @test B2 isa Z2Matrix{Matrix{Z2Block}}
        @test B2 == Vector(u1) .* Vector(u2)'

        B3 = v1 .* v2'
        @test B3 isa Z2Matrix{Matrix{Z2Block}}
        @test B3 == Vector(v1) .* Vector(v2)'

        B4 = v1 .* u2'
        @test B4 isa Z2Matrix{Matrix{Z2Block}}
        @test B4 == Vector(v1) .* Vector(u2)'
    end

    @testset "mat & mat" begin
        A = rand(Z2Number, 13, 19)
        B = rand(Z2Number, 13, 19)

        C1 = A .+ B
        @test C1 isa Z2Matrix{Matrix{Z2Block}}
        @test C1 == Matrix(A) .+ Matrix(B)

        C2 = A .* B
        @test C2 isa Z2Matrix{Matrix{Z2Block}}
        @test C2 == Matrix(A) .* Matrix(B)
    end
end