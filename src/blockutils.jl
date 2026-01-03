# A UInt64 represents an 8x8 block of bits in row-major order.
# The least significant bit represents the top-left corner of the block.
# The indexes are zero-based within the block.

const ROW_MASK = UInt64(0xff)
const COL_MASK = UInt64(0x0101010101010101)

"""
    rowvecones(len::Integer)::UInt64

Backend for `ones(Z2Number, len)` that yields a row vector. See also [`colvecones`](@ref) and [`blockones`](@ref).
"""
rowvecones(len::Integer) = ROW_MASK >> (8-len)

"""
    colvecones(len::Integer)::UInt64

Backend for `ones(Z2Number, len)` that yields a column vector. See also [`rowvecones`](@ref) and [`blockones`](@ref).
"""
colvecones(len::Integer) = COL_MASK << 8(8-len)

"""
    blockones(m::Integer, n::Integer)::UInt64

Backend for `ones(Z2Number, m, n)` that yields a block. See also [`rowvecones`](@ref) and [`colvecones`](@ref).
"""
blockones(m::Integer, n::Integer) = colvecones(m) * rowvecones(n)

"""
    getcolumn(x::UInt64, i::Integer)::UInt64

Returns the column at index `i` of the block `x`. The result is stored in the first column of the returned block.
"""
getcolumn(x::UInt64, i::Integer) = (x >> i) & COL_MASK

"""
    getrow(x::UInt64, i::Integer)::UInt64

Returns the row at index `i` of the block `x`. The result is stored in the first row of the returned block.
"""
getrow(x::UInt64, i::Integer) = (x >> 8i) & ROW_MASK

repeatcolumn(x::UInt64) = x * ROW_MASK

repeatrow(x::UInt64) = x * COL_MASK

"""
    column2row(x::UInt64)::UInt64

Transposes the block where only the first column is nonzero.
"""
column2row(x::UInt64) = (x | (x >> 7) | (x >> 14) | (x >> 21) | (x >> 28) | (x >> 35) | (x >> 42) | (x >> 49)) & ROW_MASK


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
    return x & ROW_MASK
end

"""
    getrowsum(x::UInt64)::UInt64

Calculates the sum of each row and returns it in the first column of the returned block.
"""
function getrowsum(x::UInt64)
    x = x ⊻ (x >> 4)
    x = x ⊻ (x >> 2)
    x = x ⊻ (x >> 1)
    return x & COL_MASK
end

"""
    getallsum(x::UInt64)::UInt64

Calculates the sum of all bits in the block and returns it in the top-left bit of the returned block.
"""
getallsum(x::UInt64) = UInt64(isodd(count_ones(x)))

"""
    colvecmulrowvec(x::UInt64, y::UInt64)::UInt64

Calculates the product of a column vector and a row vector.
"""
colvecmulrowvec(x::UInt64, y::UInt64) = x * y

function rowvecmulcolvec(x::UInt64, y::UInt64)
    return (x & y) ⊻ (x>>1 & y>>8) ⊻ (x>>2 & y>>16) ⊻ (x>>3 & y>>24) ⊻ (x>>4 & y>>32) ⊻ (x>>5 & y>>40) ⊻ (x>>6 & y>>48) ⊻ (x>>7 & y>>56) & UInt64(0x01)
end
rowvecdotrowvec(x::UInt64, y::UInt64) = isodd(count_ones(x & y))
colvecdotcolvec(x::UInt64, y::UInt64) = isodd(count_ones(x & y))

function swaprows(x::UInt64, i::Integer, j::Integer)
    rowi = x & (ROW_MASK << 8i)
    rowj = x & (ROW_MASK << 8j)
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

"""
    matldivmat(x::UInt64, y::UInt64)::UInt64

Left divides two blocks.
"""
function matldivmat(x::UInt64, y::UInt64)
    colmask(::Val{p}) where p = COL_MASK << p
    colmaskexclude(::Val{p}) where p = colmask(Val(p)) & ~(ROW_MASK << 8p)
    repeatrowpartial(x::UInt64, ::Val{p}) where p = (x & (ROW_MASK << 2p)) * (COL_MASK >> 2p)
    repeatcolpartial(x::UInt64, ::Val{p}) where p = x * (ROW_MASK >> p)

    @inline function dostep(x::UInt64, y::UInt64, ::Val{p}) where p
        col = x & colmask(Val(p)) & (0xffffffffffffffff << 8p)
        iszero(col) && throw(SingularException(p))
        k = trailing_zeros(col)
        x = swaprows(x, p, k ÷ 8)
        y = swaprows(y, p, k ÷ 8)
        col = repeatcolpartial(x & colmaskexclude(Val(p)), Val(p))
        xrow = repeatrow(getrow(x, p))
        yrow = repeatrow(getrow(y, p))
        x ⊻= col & xrow
        y ⊻= col & yrow
        return x, y
    end

    x, y = dostep(x, y, Val(0))
    x, y = dostep(x, y, Val(1))
    x, y = dostep(x, y, Val(2))
    x, y = dostep(x, y, Val(3))
    x, y = dostep(x, y, Val(4))
    x, y = dostep(x, y, Val(5))
    x, y = dostep(x, y, Val(6))
    x, y = dostep(x, y, Val(7))
    return y
end

function matrank(x::UInt64)
    rk = 0
    @inline function dostep(::Val{p}) where p
        col = x & (COL_MASK << p)
        rk += !iszero(col)
        k = trailing_zeros(col) ÷ 8
        x = x ⊻ (col *)
    end

    dostep(Val(0))
    dostep(Val(1))
    dostep(Val(2))
    dostep(Val(3))
    dostep(Val(4))
    dostep(Val(5))
    dostep(Val(6))
    dostep(Val(7))
    return rk
end

function matdet(x::UInt64)
end

"""
    padidentity(x::UInt64, p)::UInt64

Assuming `x` is a square block, pad an identity matrix to the bottomright to form an 8x8 block. `p` is the size of `x`.
"""
padidentity(x::UInt64, p) = x | (0x8040201008040201 << 9p)
