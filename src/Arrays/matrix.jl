import Base: size, getindex, isbitstype, one, similar, copymutable, zeros, ones
import LinearAlgebra: norm, copy_similar
import Random: rand, rand!

struct Z2Matrix{B<:AbstractMatrix{Z2Block}} <: AbstractMatrix{Z2Number}
    blocks::B
    tailsize::Tuple{Int,Int}

    global _Z2Matrix(blocks::AbstractMatrix{Z2Block}, tailsize::Tuple{Int,Int}) = new{typeof(blocks)}(blocks, tailsize)
end

function _check_z2matrix(blocks, tailsize)
    @assert 0 <= tailsize[1] <= 7
    @assert 0 <= tailsize[2] <= 7
    
    lastcolumn_mask = blockgetindex_mask(:, tailsize[2]+1:7)
    for i in size(blocks,1)
        @assert iszero(blocks[i,end].data & lastcolumn_mask)
    end

    lastrow_mask = blockgetindex_mask(tailsize[1]+1:7, :)
    for i in size(blocks,2)
        @assert iszero(blocks[end,i].data & lastrow_mask)
    end
end

function Z2Matrix{B}(blocks::B, tailsize::Tuple{<:Integer,<:Integer}=(8,8)) where B<:AbstractMatrix{Z2Block}
    tailsize = (Int(tailsize[1]), Int(tailsize[2]))
    _check_z2matrix(blocks, tailsize)
    return _Z2Matrix(blocks, tailsize)
end
Z2Matrix(blocks::AbstractMatrix{Z2Block}, tailsize::Tuple{<:Integer,<:Integer}=(7,7)) = Z2Matrix{typeof(blocks)}(blocks, tailsize)

size(A::Z2Matrix) = (blocktailsize_to_size(size(A.blocks,1), A.tailsize[1]), blocktailsize_to_size(size(A.blocks,2), A.tailsize[2]))

# Can specialize on matrix types with certain layouts
function Z2Matrix(A::AbstractMatrix{<:Number})
    Base.require_one_based_indexing(A)
    blocksize = map(size_to_blocksize, size(A))
    blocks = zeros(Z2Block, blocksize)
    for ind in eachindex(IndexCartesian(), A)
        blockind = map(size_to_blocksize, ind.I)
        blocks[blockind...] = blocks[blockind...] + Z2Block(isodd(A[ind]) * blockgetindex_mask((ind[1]-1)%8, (ind[2]-1)%8))
    end
    return _Z2Matrix(blocks, map(size_to_tailsize, size(A)))
end

function Z2Matrix(::UndefInitializer, dims::Dims{2})
    blocks = Matrix{Z2Block}(undef, map(size_to_blocksize, dims))
    tailsize = map(size_to_tailsize, dims)
    return tailmask!(_Z2Matrix(blocks, tailsize))
end
Z2Matrix(::UndefInitializer, m::Integer, n::Integer) = Z2Matrix(undef, (m,n))

check_z2array_valid(M::Z2Matrix) = _check_z2matrix(M.blocks, M.tailsize)

function tailmask!(::Type{<:Z2Matrix}, blocks::AbstractMatrix{Z2Block}, tailsize::Dims{2})
    for i in axes(blocks, 1)
        blocks[i,end] = blocks[i,end][:,0:tailsize[2]]
    end
    for j in axes(blocks, 2)
        blocks[end,j] = blocks[end,j][0:tailsize[1],:]
    end
end

@propagate_inbounds function getindex(M::Z2Matrix, i::Integer, j::Integer)
    @boundscheck checkbounds(M, i, j)
    return M.blocks[size_to_blocksize(i), size_to_blocksize(j)][size_to_tailsize(i), size_to_tailsize(j)]
end

@propagate_inbounds function getindex(M::Z2Matrix, i::Integer, ::Colon)
    @boundscheck checkbounds(M, i, :)
    return _Z2RowVector(map(b -> b[size_to_tailsize(i), :], M.blocks[size_to_blocksize(i), :]), M.tailsize[2])
end

@propagate_inbounds function getindex(M::Z2Matrix, ::Colon, j::Integer)
    @boundscheck checkbounds(M, :, j)
    return _Z2ColVector(map(b -> b[:, size_to_tailsize(j)], M.blocks[:, size_to_blocksize(j)]), M.tailsize[1])
end

@propagate_inbounds function setindex!(M::Z2Matrix, v::Z2Number, i::Integer, j::Integer)
    @boundscheck checkbounds(M, i, j)
    blocki = size_to_blocksize(i)
    blockj = size_to_blocksize(j)
    M.blocks[blocki, blockj] = setindex(M.blocks[blocki, blockj], v, size_to_tailsize(i), size_to_tailsize(j))
end


copy_similar(A::Z2Matrix, ::Type{Z2Number}) = copymutable(A)
copymutable(A::Z2Matrix) = _Z2Matrix(copymutable(A.blocks), A.tailsize)

# not the most performant
function one(A::Z2Matrix)
    A.tailsize[1] == A.tailsize[2] || throw(DimensionMismatch("multiplicative identity defined only for square matrices"))
    ret = _Z2Matrix(one(A.blocks), A.tailsize)
    ts = A.tailsize[1]
    ret.blocks[end,end] = ret.blocks[end,end][0:ts,0:ts]
    return ret
end

zeros(::Type{Z2Number}, dims::Dims{2}) = _Z2Matrix(zeros(Z2Block, map(size_to_blocksize, dims)), map(size_to_tailsize, dims))
function ones(::Type{Z2Number}, dims::Dims{2})
    A = _Z2Matrix(fill(Z2Block(FULL_MASK), map(size_to_blocksize, dims)), map(size_to_tailsize, dims))
    tailmask!(A)
    return A
end

rand(r::AbstractRNG, ::Type{Z2Number}, dims::Dims{2}) = rand!(r, Z2Matrix(undef, dims), Z2Number)

function rand!(r::AbstractRNG, A::Z2Matrix, ::Type{Z2Number})
    rand!(r, A.blocks)
    tailmask!(A)
    return A
end
