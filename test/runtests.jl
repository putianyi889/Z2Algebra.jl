using Z2Algebra
using Test
using LinearAlgebra

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
    end
end

@testset "vector" begin
    @testset "constructor" begin
        v = Z2RowVecBlock(0b10110, 5)
        u = Z2ColVecBlock(0x0100010100, 5)

        @test v isa Z2RowVecBlock
        @test u isa Z2ColVecBlock

        @test eltype(v) ≡ eltype(u) ≡ Z2Number

        @test v == [Z2Number(false), Z2Number(true), Z2Number(true), Z2Number(false), Z2Number(true)]
        @test u == [Z2Number(false), Z2Number(true), Z2Number(true), Z2Number(false), Z2Number(true)]

        @test u == v

        @test v == Z2RowVecBlock([0, 1, 1, 0, 1]) == Z2ColVecBlock([0, 1, 1, 0, 1]) == u
        @test v == Z2RowVecBlock(v) == Z2ColVecBlock(v)
        @test u == Z2RowVecBlock(u) == Z2ColVecBlock(u)
    end

    @testset "basics" begin
        data = [0, 1, 1, 0, 1]
        v = Z2RowVecBlock(data)
        u = Z2ColVecBlock(data)

        @test v == data == u

        @test v[:] isa Z2RowVecBlock
        @test u[:] isa Z2ColVecBlock

        @test v[:] == v
        @test u[:] == u

        v[1] = 1
        u[1] = 1
        data[1] = 1
        @test v == data == u

        v[2] = 0
        u[2] = 0
        data[2] = 0
        @test v == data == u
    end

    @testset "arithmetic" begin
        v1 = Z2RowVecBlock([0, 1, 1, 0, 1])
        v2 = Z2RowVecBlock([1, 0, 1, 1, 0])
        u1 = Z2ColVecBlock([0, 1, 1, 0, 1])
        u2 = Z2ColVecBlock([1, 0, 1, 1, 0])

        @test v1 + v2 == Z2RowVecBlock([1, 1, 0, 1, 1])
        @test u1 + u2 == Z2ColVecBlock([1, 1, 0, 1, 1])

        @test v1 - v2 == Z2RowVecBlock([1, 1, 0, 1, 1])
        @test u1 - u2 == Z2ColVecBlock([1, 1, 0, 1, 1])

        @test u1 * v2 isa Z2MatrixBlock
        @test u1 * v2 == [
            0 0 0 0 0;
            1 0 1 1 0;
            1 0 1 1 0;
            0 0 0 0 0;
            1 0 1 1 0;
        ]
    end
end

@testset "matrix" begin
    @testset "constructor" begin
        M = Z2MatrixBlock(0x0123456789abcdef, (8, 8))
        @test M isa Z2MatrixBlock
        @test eltype(M) ≡ Z2Number
        @test M == Z2MatrixBlock([
            1 1 1 1 0 1 1 1;
            1 0 1 1 0 0 1 1;
            1 1 0 1 0 1 0 1;
            1 0 0 1 0 0 0 1;
            1 1 1 0 0 1 1 0;
            1 0 1 0 0 0 1 0;
            1 1 0 0 0 1 0 0;
            1 0 0 0 0 0 0 0;
        ])
    end
end

@testset "algebra" begin
    @testset "multiplication" begin
        v1 = Z2RowVecBlock([0, 1, 1, 0, 1])
        v2 = Z2RowVecBlock([1, 0, 1, 1, 0])
        u1 = Z2ColVecBlock([0, 1, 1, 0, 1])
        u2 = Z2ColVecBlock([1, 0, 1, 1, 0])

        @test u1 * v2 isa Z2MatrixBlock
        @test u1 * v2 == [
            0 0 0 0 0;
            1 0 1 1 0;
            1 0 1 1 0;
            0 0 0 0 0;
            1 0 1 1 0;
        ]

        @test dot(u1, u2) ≡ Z2Number(true)
        @test dot(v1, v2) ≡ Z2Number(true)
    end
end
