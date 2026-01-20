import LinearAlgebra: copytrito!, triu!, tril!, istriu, istril

function istriu(A::Z2Matrix, k::Integer)
    dl, kl = fldmod(k, 8)
    !istriu(A.blocks, dl) && return false
    for i in diagind(A.blocks, dl)
        !istriu(A.blocks[i], kl) && return false
    end
    for i in diagind(A.blocks, dl+1)
        !istriu(A.blocks[i], kl-8) && return false
    end
    return true
end

function istril(A::Z2Matrix, k::Integer)
    dl, kl = fldmod(k, 8)
    !istril(A.blocks, dl+1) && return false
    for i in diagind(A.blocks, dl)
        !istril(A.blocks[i], kl) && return false
    end
    for i in diagind(A.blocks, dl+1)
        !istril(A.blocks[i], kl-8) && return false
    end
    return true
end

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
