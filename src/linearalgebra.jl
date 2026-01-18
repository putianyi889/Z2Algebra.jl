import Base: +, -, *, /, \
import LinearAlgebra: tr, lu!, copytrito!, triu!, tril!
using LinearAlgebra.LAPACK
using LinearAlgebra.BLAS

function +(A::Z2Matrix, B::Z2Matrix)
    Base.promote_shape(A, B)
    return _Z2Matrix(A.blocks + B.blocks, A.tailsize)
end

-(A::Z2Matrix, B::Z2Matrix) = A + B
-(A::Z2Matrix) = A

function *(A::Z2Matrix, B::Z2Matrix)
    LinearAlgebra.matmul_size_check(size(A), size(B))
    return _Z2Matrix(A.blocks * B.blocks, (A.tailsize[1], B.tailsize[2]))
end

function tr(A::Z2Matrix)
    A.tailsize[1] == A.tailsize[2] || throw(DimensionMismatch(lazy"matrix is not square: dimensions are $(size(A))"))
    return tr(tr(A.blocks))
end

include("lu.jl")

function copytrito!(B::Z2Matrix, A::Z2Matrix, uplo::AbstractChar)
    BLAS.chkuplo(uplo)
    m,n = size(A)
    bm, bn = size(A.blocks)
    bd = min(bm, bn)
    A = Base.unalias(B, A)
    if uplo == 'U'
        LAPACK.lacpy_size_check(size(B), (n < m ? n : m, n))
        blockB, blockA = LinearAlgebra.uppertridata(B.blocks), LinearAlgebra.uppertridata(A.blocks)
        for j in 1:bd
            for i in Base.oneto(j-1)
                blockB[i,j] = blockA[i,j]
            end
            blockB[j,j] = triu(blockA[j,j])
        end
        for j in bd+1:bn
            for i in 1:bm
                blockB[i,j] = blockA[i,j]
            end
        end
    else # uplo == 'L'
        LAPACK.lacpy_size_check(size(B), (m, m < n ? m : n))
        blockB, blockA = LinearAlgebra.lowertridata(B.blocks), LinearAlgebra.lowertridata(A.blocks)
        for j in 1:bd
            blockB[j,j] = tril(blockA[j,j])
            for i in j+1:bm
                blockB[i,j] = blockA[i,j]
            end
        end
    end
    return B
end

function triu!(M::Z2Matrix, k::Integer)
    dl, kl = fldmod(k, 8)
    triu!(M.blocks, dl)
    for i in diagind(M.blocks, dl)
        M.blocks[i] = triu(M.blocks[i], kl)
    end
    for i in diagind(M.blocks, dl+1)
        M.blocks[i] = triu(M.blocks[i], kl-8)
    end
    return M
end

function tril!(M::Z2Matrix, k::Integer)
    dl, kl = fldmod(k, 8)
    tril!(M.blocks, dl)
    for i in diagind(M.blocks, dl)
        M.blocks[i] = tril(M.blocks[i], kl)
    end
    for i in diagind(M.blocks, dl+1)
        M.blocks[i] = tril(M.blocks[i], kl-8)
    end
    return M
end
