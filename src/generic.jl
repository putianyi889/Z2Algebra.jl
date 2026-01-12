"""
    check_z2array_valid(::Union{Z2RowVector,Z2ColVector,Z2Matrix})

Check if the internal data is consistent. The check should pass unless you use the internal constructors.
"""
check_z2array_valid

size_to_blocksize(n::Integer) = cld(n, 8)
size_to_tailsize(n::Integer) = (n-1) % 8
blocktailsize_to_size(blocksize::Integer, tailsize::Integer) = 8*blocksize-7+tailsize
