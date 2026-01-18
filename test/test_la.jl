
@testset "addition" begin
    @testset "matrix" begin
        A = rand(Z2Number, 13, 19)
        B = rand(Z2Number, 13, 19)
        C = A + B

        @test C isa Z2Matrix{Matrix{Z2Block}}
        @test C == Matrix(A) + Matrix(B)

        D = A - B
        @test D isa Z2Matrix{Matrix{Z2Block}}
        @test D == Matrix(A) - Matrix(B)

        E = -A
        @test E isa Z2Matrix{Matrix{Z2Block}}
        @test E == -Matrix(A)
    end
end
@testset "multiplication" begin
    A = rand(Z2Number, 13, 19)
    B = rand(Z2Number, 19, 23)
    u = rand(Z2Number, 19)
    v = Z2ColVector(rand(Z2Number, 19))

    @testset "matrix matrix" begin
        AB = A * B
        @test AB isa Z2Matrix{Matrix{Z2Block}}
        @test AB == Matrix(A) * Matrix(B)

        AAt = A * transpose(A)
        @test AAt isa Z2Matrix{Matrix{Z2Block}}
        @test AAt == Matrix(A) * transpose(Matrix(A))

        AtA = transpose(A) * A
        @test AtA isa Z2Matrix{Matrix{Z2Block}}
        @test AtA == transpose(Matrix(A)) * Matrix(A)
    end

    @testset "matrix vector" begin
        Au = A * u
        @test Au isa Z2RowVector{Vector{Z2Block}}
        @test Au == Matrix(A) * Vector(u)

        Av = A * v
        @test Av isa Z2ColVector{Vector{Z2Block}}
        @test Av == Matrix(A) * Vector(v)

        Btu = transpose(B) * u
        @test Btu isa Z2RowVector{Vector{Z2Block}}
        @test Btu == transpose(Matrix(B)) * Vector(u)

        Btv = transpose(B) * v
        @test Btv isa Z2ColVector{Vector{Z2Block}}
        @test Btv == transpose(Matrix(B)) * Vector(v)
    end
end
