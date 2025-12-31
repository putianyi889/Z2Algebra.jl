import Base: size, getindex, unsafe_getindex
import Base: *

mutable struct Z2MatrixBlock <: AbstractMatrix{Z2Number}
    data::UInt64
    size::Tuple{Int, Int}
end

function Z2MatrixBlock(A::AbstractMatrix)
    Base.require_one_based_indexing(A)
    if (size(A, 1) > 8) || (size(A, 2) > 8)
        throw(ArgumentError("Dimensions of Z2MatrixBlock cannot exceed 8x8. Got size=$(size(A))."))
    end
    data = zero(UInt64)
    for i in 1:size(A, 1)
        for j in 1:size(A, 2)
            data |= UInt64(Z2Number(A[i, j])) << ((i - 1) * 8 + (j - 1))
        end
    end
    return Z2MatrixBlock(data, size(A))
end

size(M::Z2MatrixBlock) = M.size

@propagate_inbounds function getindex(M::Z2MatrixBlock, i::Integer, j::Integer)
    @boundscheck checkbounds(M, i, j)
    return unsafe_getindex(M, i, j)
end

unsafe_getindex(M::Z2MatrixBlock, i, j) = Z2Number(M.data >> ((i - 1) * 8 + (j - 1)))

*(a::Z2MatrixBlock, b::Z2MatrixBlock) = Z2MatrixBlock(matmulmat(a.data, b.data), (a.size[1], b.size[2]))
