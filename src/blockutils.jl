# A UInt64 represents an 8x8 block of bits in row-major order.
# The least significant bit represents the top-left corner of the block.
# The indexes are zero-based within the block.

"""
    getcolumn(x::UInt64, i::Integer)::UInt64

Returns the column at index `i` of the block `x`. The result is stored in the first column of the returned block. Cost: 2 ops.
"""
getcolumn(x::UInt64, i::Integer) = (x >> i) & 0x0101010101010101

"""
    getrow(x::UInt64, i::Integer)::UInt64

Returns the row at index `i` of the block `x`. The result is stored in the first row of the returned block. Cost: 3 ops.
"""
getrow(x::UInt64, i::Integer) = (x >> (i * 8)) & UInt64(0xff)

repeatcolumn(x::UInt64) = x * UInt64(0xff)

repeatrow(x::UInt64) = x * 0x0101010101010101

"""
    column2row(x::UInt64)::UInt64

Transposes the block where only the first column is nonzero.
"""
column2row(x::UInt64) = (x | (x >> 7) | (x >> 14) | (x >> 21) | (x >> 28) | (x >> 35) | (x >> 42) | (x >> 49)) & UInt64(0xff)


"""
    transposeblock(x::UInt64)::UInt64

Transposes the block.
"""
function transposeblock(x::UInt64)
    x = (x & 0xf0f0f0f00f0f0f0f) | ((x & 0x0f0f0f0f00000000) >> 28) | ((x & 0x00000000f0f0f0f0) << 28)
    x = (x & 0xcccc3333cccc3333) | ((x & 0x3333000033330000) >> 14) | ((x & 0x0000cccc0000cccc) << 14)
    x = (x & 0xaa55aa55aa55aa55) | ((x & 0x5500550055005500) >> 7) | ((x & 0x00aa00aa00aa00aa) << 7)
    return x
end

"""
    getcolsum(x::UInt64)::UInt64

Calculates the sum of each column and returns it in the first row of the returned block.
"""
function getcolsum(x::UInt64)
    x ⊻= x >> 32
    x ⊻= x >> 16
    x ⊻= x >> 8
    return x & UInt64(0xff)
end

"""
    getrowsum(x::UInt64)::UInt64

Calculates the sum of each row and returns it in the first column of the returned block.
"""
function getrowsum(x::UInt64)
    x = x ⊻ (x >> 4)
    x = x ⊻ (x >> 2)
    x = x ⊻ (x >> 1)
    return x & 0x0101010101010101
end

"""
    getallsum(x::UInt64)::UInt64

Calculates the sum of all bits in the block and returns it in the top-left bit of the returned block.
"""
getallsum(x::UInt64) = UInt64(isodd(count_ones(x)))

function colvecmulrowvec(x::UInt64, y::UInt64)
    x = repeatcolumn(x)
    y = repeatrow(y)
    return x & y
end

function rowvecmulcolvec(x::UInt64, y::UInt64)
    return (x & y) ⊻ (x>>1 & y>>8) ⊻ (x>>2 & y>>16) ⊻ (x>>3 & y>>24) ⊻ (x>>4 & y>>32) ⊻ (x>>5 & y>>40) ⊻ (x>>6 & y>>48) ⊻ (x>>7 & y>>56) & UInt64(0x01)
end

function swaprows(x::UInt64, i::Integer, j::Integer)
    rowi = x & (UInt64(0xff) << (i * 8))
    rowj = x & (UInt64(0xff) << (j * 8))
    return x ⊻ rowi ⊻ rowj ⊻ (rowi >> ((i - j) * 8)) ⊻ (rowj << ((i - j) * 8))
end

"""
    matmulmat(x::UInt64, y::UInt64)::UInt64

Multiplies two blocks.
"""
function matmulmat(x::UInt64, y::UInt64)
    function slice(x::UInt64, y::UInt64, i)
        x = getcolumn(x, i)
        y = getrow(y, i)
        return colvecmulrowvec(x, y)
    end
    return slice(x, y, 0) ⊻ slice(x, y, 1) ⊻ slice(x, y, 2) ⊻ slice(x, y, 3) ⊻ slice(x, y, 4) ⊻ slice(x, y, 5) ⊻ slice(x, y, 6) ⊻ slice(x, y, 7)
end
