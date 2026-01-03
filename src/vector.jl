import Base: size, getindex, unsafe_getindex, @propagate_inbounds, copy, unsafe_setindex!, setindex!

"""
    Z2RowVecBlock(v::AbstractVector)
    Z2RowVecBlock(data::UInt64, length::Int)
    unsafe_Z2RowVecBlock(data::UInt64, length::Int)

A block of a Z2 vector stored as the first row of [`Z2MatrixBlock`](@ref). The unsafe version is slightly faster as it doesn't apply a mask to the data. See also [`Z2ColVecBlock`](@ref).
"""
mutable struct Z2RowVecBlock <: AbstractVector{Z2Number}
    data::UInt64
    length::Int

    global unsafe_Z2RowVecBlock(data::UInt64, length::Int) = new(data, length)
    Z2RowVecBlock(data::UInt64, length::Int) = unsafe_Z2RowVecBlock(data & (COL_MASK >> (8-length)), length)
end

"""
    Z2ColVecBlock(v::AbstractVector)
    Z2ColVecBlock(data::UInt64, length::Int)
    unsafe_Z2ColVecBlock(data::UInt64, length::Int)

A block of a Z2 vector stored as the first column of [`Z2MatrixBlock`](@ref). The unsafe version is slightly faster as it doesn't apply a mask to the data. See also [`Z2RowVecBlock`](@ref).
"""
mutable struct Z2ColVecBlock <: AbstractVector{Z2Number}
    data::UInt64
    length::Int

    global unsafe_Z2ColVecBlock(data::UInt64, length::Int) = new(data, length)
    Z2ColVecBlock(data::UInt64, length::Int) = unsafe_Z2ColVecBlock(data & (ROW_MASK >> 8(8-length)), length)
end

const Z2VectorBlock = Union{Z2RowVecBlock, Z2ColVecBlock}

function Z2RowVecBlock(v::AbstractVector)
    Base.require_one_based_indexing(v)
    if (length(v) > 8)
        throw(ArgumentError("Length of Z2RowVecBlock cannot exceed 8. Got length=$(length(v))."))
    end
    data = zero(UInt64)
    for i in eachindex(v)
        data |= UInt64(Z2Number(v[i])) << (i - 1)
    end
    return unsafe_Z2RowVecBlock(data, length(v))
end

function Z2ColVecBlock(v::AbstractVector)
    Base.require_one_based_indexing(v)
    if (length(v) > 8)
        throw(ArgumentError("Length of Z2ColVecBlock cannot exceed 8. Got length=$(length(v))."))
    end
    data = zero(UInt64)
    for i in eachindex(v)
        data |= UInt64(Z2Number(v[i])) << ((i - 1) * 8)
    end
    return unsafe_Z2ColVecBlock(data, length(v))
end

size(v::Z2VectorBlock) = (v.length,)

copy(v::Z2RowVecBlock) = unsafe_Z2RowVecBlock(v.data, v.length)
copy(v::Z2ColVecBlock) = unsafe_Z2ColVecBlock(v.data, v.length)

unsafe_getindex(v::Z2RowVecBlock, i) = Z2Number(v.data >> (i - 1))
unsafe_getindex(v::Z2ColVecBlock, i) = Z2Number(v.data >> ((i - 1) * 8))

function unsafe_setindex!(v::Z2RowVecBlock, x::Z2Number, i)
    v.data = (v.data & ~(UInt64(1) << (i - 1))) | (UInt64(x) << (i - 1))
    return x
end

function unsafe_setindex!(v::Z2ColVecBlock, x::Z2Number, i)
    v.data = (v.data & ~(UInt64(1) << ((i - 1) * 8))) | (UInt64(x) << ((i - 1) * 8))
    return x
end

getindex(v::Z2VectorBlock, ::Colon) = copy(v)

@propagate_inbounds function getindex(v::Z2VectorBlock, i::Integer)
    @boundscheck checkbounds(v, i)
    return unsafe_getindex(v, i)
end

@propagate_inbounds function setindex!(v::Z2VectorBlock, x, i::Integer)
    @boundscheck checkbounds(v, i)
    return unsafe_setindex!(v, Z2Number(x), i)
end

