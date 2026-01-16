
function similar(A::Z2Array, ::Type{Z2Number}, dims::Dims{2})
    blocks = similar(A.blocks, map(size_to_blocksize, dims))
    tailsize = map(size_to_tailsize, dims)
    A = _Z2Matrix(blocks, tailsize)
    return tailmask!(A)
end

function similar(A::Z2Array, ::Type{Z2Number}, dims::Dims{1})
    blocks = similar(A.blocks, size_to_blocksize(dims[1]))
    tailsize = size_to_tailsize(dims[1])
    A = _Z2RowVector(blocks, tailsize)
    return tailmask!(A)
end

function similar(v::Z2ColVector, ::Type{Z2Number}, dims::Dims{1})
    blocks = similar(v.blocks, size_to_blocksize(dims[1]))
    tailsize = size_to_tailsize(dims[1])
    A = _Z2ColVector(blocks, tailsize)
    return tailmask!(A)
end
