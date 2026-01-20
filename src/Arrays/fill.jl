import Base: zeros, ones

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
