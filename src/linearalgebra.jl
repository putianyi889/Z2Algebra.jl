import Base: +, -, *, /, \
import LinearAlgebra: dot

unsafe_add(u::Z2RowVecBlock, v::Z2RowVecBlock) = unsafe_Z2RowVecBlock(u.data ⊻ v.data, u.length)
unsafe_add(u::Z2ColVecBlock, v::Z2ColVecBlock) = unsafe_Z2ColVecBlock(u.data ⊻ v.data, u.length)

function +(u::Z2VectorBlock, v::Z2VectorBlock)
    if u.length != v.length
        throw(DimensionMismatch("Cannot add Z2RowVecBlocks of different lengths: $(u.length) and $(v.length)."))
    end
    unsafe_add(u, v)
end

-(u::Z2VectorBlock, v::Z2VectorBlock) = u + v

unsafe_mul(a::Z2MatrixBlock, b::Z2MatrixBlock) = unsafe_Z2MatrixBlock(matmulmat(a.data, b.data), (a.size[1], b.size[2]))

*(u::Z2ColVecBlock, v::Z2RowVecBlock) = unsafe_Z2MatrixBlock(colvecmulrowvec(u.data, v.data), (u.length, v.length))
function *(a::Z2MatrixBlock, b::Z2MatrixBlock)
    LinearAlgebra.matmul_size_check(size(a), size(b))
    unsafe_mul(a, b)
end

dot(u::Z2RowVecBlock, v::Z2RowVecBlock) = Z2Number(rowvecdotrowvec(u.data, v.data))
dot(u::Z2ColVecBlock, v::Z2ColVecBlock) = Z2Number(colvecdotcolvec(u.data, v.data))

unsafe_ldiv(a::Z2MatrixBlock, b::Z2MatrixBlock) = Z2MatrixBlock(matldivmat(a.data, b.data), (a.size[2], b.size[2]))

function \(a::Z2MatrixBlock, b::Z2MatrixBlock)
    m, n = size(a)
    if m != n
        throw(DimensionMismatch("non-square divider is not supported"))
    end
    if m != size(b, 1)
        throw(DimensionMismatch("arguments must have the same number of rows"))
    end
    a_pad = padidentity(a.data, m)
    unsafe_ldiv(a_pad, b)
end
