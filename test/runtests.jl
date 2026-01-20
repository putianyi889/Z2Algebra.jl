using Z2Algebra
using Test
using LinearAlgebra

function test_type_value(a, b)
    @test typeof(a) == typeof(b)
    @test a == b
end

function test_validity(a, T, sz)
    @test a isa T
    @test size(a) ≡ sz
    @test Z2Algebra.check_z2array_valid(a) isa Any
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
    @testset "undef constructor (Tuple dims)" begin
        A = Z2Matrix(undef, (13, 19))
        test_validity(A, Z2Matrix{Matrix{Z2Block}}, (13, 19))

        u = Z2ColVector(undef, (13,))
        test_validity(u, Z2ColVector{Vector{Z2Block}}, (13,))

        v = Z2RowVector(undef, (19,))
        test_validity(v, Z2RowVector{Vector{Z2Block}}, (19,))
    end

    @testset "undef constructor (Vararg dims)" begin
        A = Z2Matrix(undef, 13, 19)
        test_validity(A, Z2Matrix{Matrix{Z2Block}}, (13, 19))

        u = Z2ColVector(undef, 13)
        test_validity(u, Z2ColVector{Vector{Z2Block}}, (13,))

        v = Z2RowVector(undef, 19)
        test_validity(v, Z2RowVector{Vector{Z2Block}}, (19,))
    end

    @testset "rand" begin
        A = rand(Z2Number, (13, 19))
        test_validity(A, Z2Matrix{Matrix{Z2Block}}, (13, 19))

        v = rand(Z2Number, (13,))
        test_validity(v, Z2RowVector{Vector{Z2Block}}, (13,))
    end

    @testset "construct from array" begin
        M = rand(Bool, 13, 19)
        A = Z2Matrix(M)
        @test A isa Z2Matrix{Matrix{Z2Block}}
        @test A == M

        V = rand(Bool, 13)
        u = Z2ColVector(V)
        v = Z2RowVector(V)
        @test u isa Z2ColVector{Vector{Z2Block}}
        @test v isa Z2RowVector{Vector{Z2Block}}
        @test u == V == v
    end

    @testset "ones" begin
        A = ones(Z2Number, (13, 19))
        @test A isa Z2Matrix{Matrix{Z2Block}}
        @test A == ones(Bool, 13, 19)

        v = ones(Z2Number, (13,))
        @test v isa Z2RowVector{Vector{Z2Block}}
        @test v == ones(Bool, 13)
    end

    @testset "zeros" begin
        A = zeros(Z2Number, (13, 19))
        @test A isa Z2Matrix{Matrix{Z2Block}}
        @test A == zeros(Bool, 13, 19)

        v = zeros(Z2Number, (13,))
        @test v isa Z2RowVector{Vector{Z2Block}}
        @test v == zeros(Bool, 13)
    end

    @testset "similar" begin
        A = rand(Z2Number, 13, 19)
        u = A[:, 1]
        v = A[1, :]

        # same size
        for B in [A, u, v]
            B1 = similar(B)
            test_validity(B1, typeof(B), size(B))

            B2 = similar(B, Z2Number)
            test_validity(B2, typeof(B), size(B))
        end

        # to matrix
        for C in [A, u, v]
            A1 = similar(C, (19, 13))
            test_validity(A1, Z2Matrix{Matrix{Z2Block}}, (19, 13))

            A2 = similar(C, Z2Number, (19, 13))
            test_validity(A2, Z2Matrix{Matrix{Z2Block}}, (19, 13))
        end

        # from matrix to vector, default to row vector
        v1 = similar(A, (19,))
        test_validity(v1, Z2RowVector{Vector{Z2Block}}, (19,))

        v2 = similar(A, Z2Number, (19,))
        test_validity(v2, Z2RowVector{Vector{Z2Block}}, (19,))

        # from vector to vector
        for D in [u, v]
            D1 = similar(D, (19,))
            test_validity(D1, typeof(D), (19,))

            D2 = similar(D, Z2Number, (19,))
            test_validity(D2, typeof(D), (19,))
        end
    end

    @testset "matrix getindex" begin
        A = rand(Z2Number, 13, 19)
        @test A[9,9] isa Z2Number
        @test A[9,5:10] isa Z2RowVector{Vector{Z2Block}}
        @test A[9,:] isa Z2RowVector{Vector{Z2Block}}
        @test_broken A[5:10,9] isa Z2ColVector{Vector{Z2Block}}
        @test A[5:10,5:10] isa Z2Matrix{Matrix{Z2Block}}
        @test A[5:10,:] isa Z2Matrix{Matrix{Z2Block}}
        @test A[:,9]  isa Z2ColVector{Vector{Z2Block}}
        @test A[:,5:10] isa Z2Matrix{Matrix{Z2Block}}
        @test A[:,:] isa Z2Matrix{Matrix{Z2Block}}
    end
end

include("test_la.jl")

using Documenter

DocMeta.setdocmeta!(Z2Algebra, :DocTestSetup, :(
    using Z2Algebra;
    using Z2Algebra: bitstringblock, TRIU_MASK
); recursive=true)

@testset "Doctest" begin
    doctest(Z2Algebra)
end
