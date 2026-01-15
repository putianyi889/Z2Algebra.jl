"""
    check_z2array_valid(::Union{Z2RowVector,Z2ColVector,Z2Matrix})

Check if the internal data is consistent. The check should pass unless you use the internal constructors.
"""
check_z2array_valid

size_to_blocksize(n::Integer) = cld(n, 8)
size_to_tailsize(n::Integer) = (n-1) % 8
blocktailsize_to_size(blocksize::Integer, tailsize::Integer) = 8*blocksize-7+tailsize

function tailmask!(blocks::AbstractMatrix{Z2Block}, tailsize::Dims{2})
    for i in axes(blocks, 1)
        blocks[i,end] = blocks[i,end][:,0:tailsize[2]]
    end
    for j in axes(blocks, 2)
        blocks[end,j] = blocks[end,j][0:tailsize[1],:]
    end
end
