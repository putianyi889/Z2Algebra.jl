
@testset "triangular" begin
    A = rand(Z2Number, 13, 19)
    M = Matrix(A)

    @testset "triu" begin
        U1 = triu(A)
        @test U1 isa Z2Matrix{Matrix{Z2Block}}
        @test U1 == triu(M)
        @test istriu(U1)

        U2 = triu(A, 1)
        @test U2 isa Z2Matrix{Matrix{Z2Block}}
        @test U2 == triu(M, 1)
        @test istriu(U2, 1)

        U3 = triu(A, -1)
        @test U3 isa Z2Matrix{Matrix{Z2Block}}
        @test U3 == triu(M, -1)
        @test istriu(U3, -1)
    end

    @testset "tril" begin
        L1 = tril(A)
        @test L1 isa Z2Matrix{Matrix{Z2Block}}
        @test L1 == tril(M)
        @test istril(L1)

        L2 = tril(A, 1)
        @test L2 isa Z2Matrix{Matrix{Z2Block}}
        @test L2 == tril(M, 1)
        @test istril(L2, 1)

        L3 = tril(A, -1)
        @test L3 isa Z2Matrix{Matrix{Z2Block}}
        @test L3 == tril(M, -1)
        @test istril(L3, -1)
    end

    @testset "tril!, triu!, copytrito!" begin
        M = rand(Z2Number, 13, 13)
        tril!(M)
        L = LowerTriangular(ones(Z2Number, 13, 13))
        copytrito!(M, L, 'L')
        @test M == L

        M = rand(Z2Number, 13, 13)
        triu!(M)
        U = UpperTriangular(ones(Z2Number, 13, 13))
        copytrito!(M, U, 'U')
        @test M == U
    end
end

@testset "symmetric" begin
    @testset "issymmetric" begin
        A = rand(Z2Number, 13, 13)
        @test issymmetric(A) == issymmetric(Matrix(A))

        S = Z2Matrix(Symmetric(A))
        @test issymmetric(S)
    end
end

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

    @testset "dot" begin
        @test u ⋅ u ≡ Vector(u) ⋅ Vector(u)
        @test u ⋅ v ≡ Vector(u) ⋅ Vector(v)
        @test v ⋅ u ≡ Vector(v) ⋅ Vector(u)
        @test v ⋅ v ≡ Vector(v) ⋅ Vector(v)
    end
end

@testset "division" begin
    A = rand(Z2Number, 13, 13)
    while iszero(det(A))
        A = rand(Z2Number, 13, 13)
    end

    B = rand(Z2Number, 13, 7)
    u = rand(Z2Number, 13)
    v = Z2ColVector(rand(Z2Number, 13))

    @testset "matrix" begin
        X = A \ B
        @test X isa Z2Matrix{Matrix{Z2Block}}
        @test A * X == B

        invA = inv(A)
        @test invA isa Z2Matrix{Matrix{Z2Block}}
        @test invA * A == one(A)
    end

    @testset "vector" begin
        x = A \ u
        @test x isa Z2RowVector{Vector{Z2Block}}
        @test A * x == u

        y = A \ v
        @test_broken y isa Z2ColVector{Vector{Z2Block}}
        @test A * y == v
    end
end
