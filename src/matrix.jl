import Base: size, getindex, unsafe_getindex
import Base: ones, zeros

"""
    Z2MatrixBlock(A::AbstractMatrix)
    Z2MatrixBlock(data::UInt64, size::Tuple{Int, Int})
    unsafe_Z2MatrixBlock(data::UInt64, size::Tuple{Int, Int})

A block of a Z2 matrix stored as an `UInt64` in the row-major order. The lowest bit represents the top-left entry. The unsafe version is slightly faster as it doesn't apply a mask to the data. See also [`Z2RowVecBlock`](@ref) and [`Z2ColVecBlock`](@ref).
"""
mutable struct Z2MatrixBlock <: AbstractMatrix{Z2Number}
    data::UInt64
    size::Tuple{Int, Int}

    global unsafe_Z2MatrixBlock(data::UInt64, size::Tuple{Int, Int}) = new(data, size)
    Z2MatrixBlock(data::UInt64, size::Tuple{Int, Int}) = unsafe_Z2MatrixBlock(data & blockones(size[1], size[2]), size)
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
    return unsafe_Z2MatrixBlock(data, size(A))
end

size(M::Z2MatrixBlock) = M.size

@propagate_inbounds function getindex(M::Z2MatrixBlock, i::Integer, j::Integer)
    @boundscheck checkbounds(M, i, j)
    return unsafe_getindex(M, i, j)
end

unsafe_getindex(M::Z2MatrixBlock, i, j) = Z2Number(M.data >> ((i - 1) * 8 + (j - 1)))

function ones(::Type{Z2Number}, dims::Dims{2})
    if dims[1] > 8 || dims[2] > 8
        throw(ArgumentError("Dimensions of Z2MatrixBlock cannot exceed 8x8. Got size=$(dims)."))
    end
    return unsafe_Z2MatrixBlock(blockones(dims...), dims)
end
