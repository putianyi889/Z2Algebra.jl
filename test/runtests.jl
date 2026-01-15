using Z2Algebra
using Test
using LinearAlgebra

function test_type_value(a, b)
    @test typeof(a) == typeof(b)
    @test a == b
end

@testset "number" begin
    @testset "constructor" begin
        @test Z2Number(0) ≡ Z2Number(false)
        @test Z2Number(1) ≡ Z2Number(true)
        @test Z2Number(2) ≡ Z2Number(false)
        @test Z2Number(3) ≡ Z2Number(true)

        @test Int(Z2Number(false)) ≡ 0
        @test Int(Z2Number(true)) ≡ 1
    end

    @testset "arithmetic" begin
        a = Z2Number(true)
        b = Z2Number(false)

        @test a + a ≡ b
        @test a + b ≡ a
        @test b + a ≡ a
        @test b + b ≡ b

        @test a * a ≡ a
        @test a * b ≡ b
        @test b * a ≡ b
        @test b * b ≡ b

        @test a / a ≡ a
        @test_throws DivideError a / b
        @test b / a ≡ b
        @test_throws DivideError b / b

        @test -a ≡ a
        @test -b ≡ b

        @test a - a ≡ b
        @test a - b ≡ a
        @test b - a ≡ a
        @test b - b ≡ b

        @test inv(a) ≡ a
        @test_throws DivideError inv(b)
    end

    @testset "properties" begin
        a = Z2Number(true)
        b = Z2Number(false)

        @test isone(a)
        @test !isone(b)
        @test !iszero(a)
        @test iszero(b)

        @test isodd(a)
        @test !isodd(b)
        @test !iseven(a)
        @test iseven(b)

        @test isfinite(a)
        @test isfinite(b)
        @test !isinf(a)
        @test !isinf(b)
        @test !isnan(a)
        @test !isnan(b)

        @test !signbit(a)
        @test !signbit(b)
    end

    @testset "comparison" begin
        a = Z2Number(true)
        b = Z2Number(false)
        
        @test b < a
        @test !(a < b)
        @test !(a < a)
        @test !(b < b)
    end
end

@testset "arrays interface" begin
    @testset "undef constructor" begin
        A = Z2Matrix(undef, 13, 19)
        @test A isa Z2Matrix{Matrix{Z2Block}}
        @test size(A) ≡ (13, 19)
        @test Z2Algebra.check_z2array_valid(A) isa Any

        u = Z2ColVector(undef, 13)
        @test u isa Z2ColVector{Vector{Z2Block}}
        @test size(u) ≡ (13,)
        @test Z2Algebra.check_z2array_valid(u) isa Any

        v = Z2RowVector(undef, 19)
        @test v isa Z2RowVector{Vector{Z2Block}}
        @test size(v) ≡ (19,)
        @test Z2Algebra.check_z2array_valid(v) isa Any
    end
end

@testset "matrix" begin
    @testset "basics" begin
        data = rand(Bool, 10, 10)
        A = Z2Matrix(data)
        MA = Matrix(A)

        @test A isa Z2Matrix{Matrix{Z2Block}}
        @test MA isa Matrix{Z2Number}
        @test A == MA == data

        @test one(A) isa Z2Matrix{Matrix{Z2Block}}
        @test one(A) == one(MA)

        @test zero(A) isa Z2Matrix{Matrix{Z2Block}}
        @test zero(A) == zero(MA)

        @test zeros(Z2Number,10,10) isa Z2Matrix{Matrix{Z2Block}}
        @test zeros(Z2Number,10,10) == zero(A)
    end

    @testset "triu and tril" begin
        function test_tri(uplo, A, MA, K)
            if uplo == 'U'
                for k in K
                    T = triu(A, k)
                    @test T isa Z2Matrix
                    @test T == triu(MA, k)
                end
            else
                for k in K
                    T = tril(A, k)
                    @test T isa Z2Matrix
                    @test T == tril(MA, k)
                end
            end
        end

        # Test with random matrix
        A = rand(Z2Number, 35, 55)
        MA = Matrix(A)

        # triu
        @test triu(A) isa Z2Matrix{Matrix{Z2Block}}
        @test triu(A) == triu(MA)
        test_tri('U', A, MA, [0, 1, -1, 8, -8, 9, -9, 100, -100])

        # tril
        @test tril(A) isa Z2Matrix{Matrix{Z2Block}}
        @test tril(A) == tril(MA)
        test_tri('L', A, MA, [0, 1, -1, 8, -8, 9, -9, 100, -100])
    end

    @testset "lu decomposition" begin
        # Test with square matrix
        A = rand(Z2Number, 100, 100)
        while true
            A = rand(Z2Number, 100, 100)
            MA = Matrix(A)

            F = lu(A, check=false)
            @test F isa LinearAlgebra.LU{Z2Number, Z2Matrix{Matrix{Z2Block}}}
            @test F.L * F.U == F.P * A

            @test det(MA) ≡ det(A)
            # @test rank(MA) ≡ rank(A)
            if det(A) != 0 # find a non-singular matrix
                break
            end
            @test_throws SingularException lu(A)
        end

        # Test with non-square matrix
        A_rect = rand(Z2Number, 13, 33)
        F_rect = lu(A_rect, check=false)
        @test F_rect.L * F_rect.U == F_rect.P * A_rect
    end
end

using Documenter

DocMeta.setdocmeta!(Z2Algebra, :DocTestSetup, :(
    using Z2Algebra;
    using Z2Algebra: bitstringblock, TRIU_MASK
); recursive=true)

@testset "Doctest" begin
    doctest(Z2Algebra)
end
