import Base: zeros, ones, fill!

zeros(::Type{Z2Number}, dims::Dims{2}) = _Z2Matrix(zeros(Z2Block, map(size_to_blocksize, dims)), map(size_to_tailsize, dims))
zeros(::Type{Z2Number}, dims::Dims{1}) = _Z2RowVector(zeros(Z2Block, size_to_blocksize(dims[1])), size_to_tailsize(dims[1]))

function ones(::Type{Z2Number}, dims::Dims{2})
    A = _Z2Matrix(fill(Z2Block(FULL_MASK), map(size_to_blocksize, dims)), map(size_to_tailsize, dims))
    return tailmask!(A)
end
function ones(::Type{Z2Number}, dims::Dims{1})
    A = _Z2RowVector(fill(Z2Block(FULL_MASK), size_to_blocksize(dims[1])), size_to_tailsize(dims[1]))
    return tailmask!(A)
end

function fill!(A::Z2Matrix, v)
    vT = convert(Z2Number, v)
    if iszero(vT)
        fill!(A.blocks, zero(Z2Block))
        return A
    else
        fill!((@view A.blocks[1:end-1,1:end-1]), Z2Block(FULL_MASK))
        fill!((@view A.blocks[1:end-1,end]), Z2Block(blockgetindex_mask(:,0:A.tailsize[2])))
        fill!((@view A.blocks[end,1:end-1]), Z2Block(blockgetindex_mask(0:A.tailsize[1],:)))
        A.blocks[end,end] = Z2Block(blockgetindex_mask(0:A.tailsize[1],0:A.tailsize[2]))
        return tailmask!(A)
    end
end

function fill!(A::Z2RowVector, v)
    vT = convert(Z2Number, v)
    if iszero(vT)
        fill!(A.blocks, zero(Z2Block))
    else
        fill!((@view A.blocks[1:end-1]), Z2Block(ROW_MASK))
        A.blocks[end] = Z2Block(blockgetindex_mask(0,0:A.tailsize))
    end
    return A
end

function fill!(A::Z2ColVector, v)
    vT = convert(Z2Number, v)
    if iszero(vT)
        fill!(A.blocks, zero(Z2Block))
    else
        fill!((@view A.blocks[1:end-1]), Z2Block(COL_MASK))
        A.blocks[end] = Z2Block(blockgetindex_mask(0:A.tailsize,0))
    end
    return A
end
