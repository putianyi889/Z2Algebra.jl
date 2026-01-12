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

@testset "matrix" begin
    @testset "square" begin
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
    end
end
