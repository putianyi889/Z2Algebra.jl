"""
    check_z2array_valid(::Union{Z2RowVector,Z2ColVector,Z2Matrix})

Check if the internal data is consistent. The check should pass unless you use the internal constructors.
"""
check_z2array_valid

size_to_blocksize(n::Integer) = cld(n, 8)
size_to_tailsize(n::Integer) = (n-1) % 8
blocktailsize_to_size(blocksize::Integer, tailsize::Integer) = 8*blocksize-7+tailsize

"""
    tailmask!(::T) -> T
    tailmask!(T, blocks, tailsize)

Make a Z2Array valid by masking the blocks with tailsize information.
"""
function tailmask!(A)
    tailmask!(typeof(A), A.blocks, A.tailsize)
    return A
end

include("Arrays/vector.jl")
include("Arrays/matrix.jl")

const Z2Array = Union{Z2RowVector,Z2ColVector,Z2Matrix}

include("Arrays/similar.jl")
include("Arrays/fill.jl")
include("Arrays/broadcast.jl")
