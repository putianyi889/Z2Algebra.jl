import Base: size, getindex, @propagate_inbounds, copy, setindex!
import Random: rand, rand!

struct Z2RowVector{B<:AbstractVector{Z2Block}} <: AbstractVector{Z2Number}
    blocks::B
    tailsize::Int

    global _Z2RowVector(blocks::AbstractVector{Z2Block}, tailsize::Int) = new{typeof(blocks)}(blocks, tailsize)
end

struct Z2ColVector{B<:AbstractVector{Z2Block}} <: AbstractVector{Z2Number}
    blocks::B
    tailsize::Int

    global _Z2ColVector(blocks::AbstractVector{Z2Block}, tailsize::Int) = new{typeof(blocks)}(blocks, tailsize)
end

function tailmask!(v::Z2RowVector)
    for i in 1:length(v.blocks)-1
        v.blocks[i] = Z2Block(v.blocks[i].data & ROW_MASK)
    end
    v.blocks[end] = v.blocks[end][0,0:v.tailsize]
end

function tailmask!(v::Z2ColVector)
    for i in 1:length(v.blocks)-1
        v.blocks[i] = Z2Block(v.blocks[i].data & COL_MASK)
    end
    v.blocks[end] = v.blocks[end][0:v.tailsize,0]
end

function Z2RowVector(v::AbstractVector)
    Base.require_one_based_indexing(v)
    blocks = zeros(Z2Block, size_to_blocksize(length(v)))
    tailsize = size_to_tailsize(length(v))
    for i in 1:length(blocks)-1
        blocks[i] = Z2Block(packrow((isodd(v[8i+k]) for k in -7:0)...))
    end
    blocks[end] = Z2Block(packrow((isodd(v[end+k]) for k in -tailsize:0)..., zeros(Bool, 7-tailsize)...))
    return _Z2RowVector(blocks, tailsize)
end

function Z2ColVector(v::AbstractVector)
    Base.require_one_based_indexing(v)
    blocks = zeros(Z2Block, size_to_blocksize(length(v)))
    tailsize = size_to_tailsize(length(v))
    for i in 1:length(blocks)-1
        blocks[i] = Z2Block(packcolumn((isodd(v[8i+k]) for k in -7:0)...))
    end
    blocks[end] = Z2Block(packcolumn((isodd(v[end+k]) for k in -tailsize:0)..., zeros(Bool, 7-tailsize)...))
    return _Z2ColVector(blocks, tailsize)
end

function Z2RowVector(::UndefInitializer, dims::Dims{1})
    blocks = Vector{Z2Block}(undef, size_to_blocksize(dims[1]))
    tailsize = size_to_tailsize(dims[1])
    v = _Z2RowVector(blocks, tailsize)
    tailmask!(v)
    return v
end

function Z2ColVector(::UndefInitializer, dims::Dims{1})
    blocks = Vector{Z2Block}(undef, size_to_blocksize(dims[1]))
    tailsize = size_to_tailsize(dims[1])
    v = _Z2ColVector(blocks, tailsize)
    tailmask!(v)
    return v
end

Z2RowVector(::UndefInitializer, m::Integer) = Z2RowVector(undef, (m,))
Z2ColVector(::UndefInitializer, m::Integer) = Z2ColVector(undef, (m,))

function check_z2array_valid(v::Z2RowVector)
    for i in 1:length(v.blocks)-1
        @assert v.blocks[i].data <= ROW_MASK
    end
    @assert v.blocks[end].data & (ROW_MASK << 1 << v.tailsize) == 0
end

function check_z2array_valid(v::Z2ColVector)
    for i in 1:length(v.blocks)-1
        @assert iszero(v.blocks[i].data & ~COL_MASK)
    end
    @assert iszero(v.blocks[end].data & (COL_MASK << 8 << 8v.tailsize))
end

size(v::Z2RowVector) = (blocktailsize_to_size(length(v.blocks), v.tailsize), )
size(v::Z2ColVector) = (blocktailsize_to_size(length(v.blocks), v.tailsize), )

@propagate_inbounds function getindex(v::Z2RowVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return Z2Number(rowgetindex(v.blocks[size_to_blocksize(i)].data, size_to_tailsize(i)))
end

@propagate_inbounds function getindex(v::Z2ColVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return Z2Number(colgetindex(v.blocks[size_to_blocksize(i)].data, size_to_tailsize(i)))
end

@propagate_inbounds function setindex!(v::Z2RowVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.blocks[size_to_blocksize(i)] = rowsetindex(v.blocks[size_to_blocksize(i)].data, isodd(x), size_to_tailsize(i))
    return isodd(x)
end

@propagate_inbounds function setindex!(v::Z2ColVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.blocks[size_to_blocksize(i)] = colsetindex(v.blocks[size_to_blocksize(i)].data, isodd(x), size_to_tailsize(i))
    return isodd(x)
end

rand(r::AbstractRNG, ::Type{Z2Number}, dims::Dims{1}) = rand!(r, Z2RowVector(undef, dims), Z2Number)

function rand!(r::AbstractRNG, A::Z2RowVector, ::Type{Z2Number})
    rand!(r, A.blocks)
    tailmask!(A)
    return A
end
