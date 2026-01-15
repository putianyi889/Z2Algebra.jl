# A UInt64 represents an 8x8 block of bits in row-major order.
# The least significant bit represents the top-left corner of the block.
# The indexes are zero-based within the block.

const FULL_MASK = 0xffffffffffffffff
const ROW_MASK = 0x00000000000000ff
const COL_MASK = 0x0101010101010101
const DIAG_MASK = 0x8040201008040201
const TRIU_MASK = 0x80c0e0f0f8fcfeff
const TRIL_MASK = 0xff7f3f1f0f070301

"""
    bitstringblock(x::Union{UInt64, Int64})

Convert a 64-bit integer to a block of bits in a human-readable format.

# Example
```jldoctest
julia> bitstringblock(TRIU_MASK) |> print
11111111
01111111
00111111
00011111
00001111
00000111
00000011
00000001
```
"""
function bitstringblock(x::Union{UInt64, Int64})
    str = bitstring(bitreverse(x))
    join((str[i:i+7] for i in 1:8:64), '\n')
end

"""
    rowvecones(len::Integer)::UInt64

Backend for `ones(Z2Number, len)` that yields a row vector. See also [`colvecones`](@ref) and [`blockones`](@ref).
"""
rowvecones(len::Integer) = ROW_MASK >> (8-len)

"""
    colvecones(len::Integer)::UInt64

Backend for `ones(Z2Number, len)` that yields a column vector. See also [`rowvecones`](@ref) and [`blockones`](@ref).
"""
colvecones(len::Integer) = COL_MASK >> 8(8-len)

"""
    blockones(m::Integer, n::Integer)::UInt64

Backend for `ones(Z2Number, m, n)` that yields a block. See also [`rowvecones`](@ref) and [`colvecones`](@ref).
"""
blockones(m::Integer, n::Integer) = colvecones(m) * rowvecones(n)

"""
    blockgetindex_mask(i, j)

Get the mask where the bit(s) at **0-based** position (i, j) in are 1. This function is low-level, and the caller is responsible for bounds checking.

!!! note
    Unlike [`blockgetindex`](@ref), this function does not shift bits to the least significant position.
"""
blockgetindex_mask(i::Integer, j::Integer) = UInt64(0x01) << unsigned(8i + j)
blockgetindex_mask(i::Integer, ::Colon) = ROW_MASK << unsigned(8i)
blockgetindex_mask(::Colon, j::Integer) = COL_MASK << unsigned(j)
blockgetindex_mask(::Colon, ::Colon) = 0xffffffffffffffff
blockgetindex_mask(i::Integer, j::AbstractUnitRange) = ROW_MASK >> unsigned(8 - length(j)) << unsigned(8i + first(j))
blockgetindex_mask(i::AbstractUnitRange, j::Integer) = COL_MASK >> unsigned(8(8 - length(i))) << unsigned(8first(i) + j)
blockgetindex_mask(::Colon, j::AbstractUnitRange) = (COL_MASK * rowvecones(length(j))) << unsigned(first(j))
blockgetindex_mask(i::AbstractUnitRange, ::Colon) = (ROW_MASK * colvecones(length(i))) << unsigned(8first(i))
blockgetindex_mask(i::AbstractUnitRange, j::AbstractUnitRange) = blockones(length(i), length(j)) << unsigned(8first(i) + first(j))

blockgetindex_mask(::Colon, ::Val{p}) where p = blockgetindex_mask(:, p)
blockgetindex_mask(::Val{p}, ::Colon) where p = blockgetindex_mask(p, :)
blockgetindex_mask(::Val{p}, ::Val{q}) where {p,q} = blockgetindex_mask(p, q)

"""
    blockgetindex(x::UInt64, i, j)

Get the bit(s) at **0-based** position (i, j) in the block. This function is low-level, and the caller is responsible for bounds checking.

!!! note
    Unlike [`blockgetindex_mask`](@ref), this function shifts bits to the least significant position.
"""
@inline blockgetindex(x::UInt64, i::Integer, j::Integer) = (x >> unsigned(8i + j)) & UInt64(0x01)
@inline blockgetindex(x::UInt64, i::Integer, ::Colon) = (x >> unsigned(8i)) & ROW_MASK
@inline blockgetindex(x::UInt64, ::Colon, j::Integer) = (x >> unsigned(j)) & COL_MASK
@inline blockgetindex(x::UInt64, ::Colon, ::Colon) = x
@inline blockgetindex(x::UInt64, i::Integer, j::AbstractUnitRange) = (x >> unsigned(8i + first(j))) & (ROW_MASK >> unsigned(8 - length(j)))
@inline blockgetindex(x::UInt64, i::AbstractUnitRange, j::Integer) = (x >> unsigned(j)) & (COL_MASK >> unsigned(8 - length(i)))
@inline blockgetindex(x::UInt64, ::Colon, j::AbstractUnitRange) = (x >> unsigned(first(j))) & (COL_MASK * rowvecones(length(j)))
@inline blockgetindex(x::UInt64, i::AbstractUnitRange, ::Colon) = (x >> unsigned(8first(i))) & (ROW_MASK * colvecones(length(i)))
@inline blockgetindex(x::UInt64, i::AbstractUnitRange, j::AbstractUnitRange) = (x >> unsigned(8first(i) + first(j))) & blockones(length(i), length(j))

rowgetindex(x::UInt64, i) = blockgetindex(x, 0, i)
colgetindex(x::UInt64, i) = blockgetindex(x, i, 0)

blocksetindex(x::UInt64, v::Bool, i::Integer, j::Integer) = x & ~blockgetindex_mask(i,j) | (v * blockgetindex_mask(i,j))

rowsetindex(x::UInt64, v::Bool, i) = blocksetindex(x, v, 0, i)
colsetindex(x::UInt64, v::Bool, i) = blocksetindex(x, v, i, 0)

tril_mask(k::Integer) = unsigned(signed(TRIL_MASK) >> 8k)
triu_mask(k::Integer) = ~tril_mask(k-one(k))
triu_mask(k::Unsigned) = TRIU_MASK >> 8k

packrow(v::Vararg{Bool,8}) = UInt64(v[1]) | UInt64(v[2]) << 1 | UInt64(v[3]) << 2 | UInt64(v[4]) << 3 | UInt64(v[5]) << 4 | UInt64(v[6]) << 5 | UInt64(v[7]) << 6 | UInt64(v[8]) << 7
packrow(v) = packrow(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
packcolumn(v::Vararg{Bool,8}) = UInt64(v[1]) | UInt64(v[2]) << 8 | UInt64(v[3]) << 16 | UInt64(v[4]) << 24 | UInt64(v[5]) << 32 | UInt64(v[6]) << 40 | UInt64(v[7]) << 48 | UInt64(v[8]) << 56
packcolumn(v) = packcolumn(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])

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

function blockswaprows(x::UInt64, i::Integer, j::Integer)
    rowi = x & blockgetindex_mask(i,:)
    rowj = x & blockgetindex_mask(j,:)
    shift = 8(i-j)
    return x ⊻ rowi ⊻ rowj ⊻ (rowi >> shift) ⊻ (rowj << shift)
end

function blockswaprows(x::UInt64, y::UInt64, i::Integer, j::Integer)
    rowi = x & blockgetindex_mask(i,:)
    rowj = y & blockgetindex_mask(j,:)
    shift = 8(i-j)
    return (x ⊻ rowi ⊻ (rowj << shift), y ⊻ rowj ⊻ (rowi >> shift))
end

"""
    matmulmat(x::UInt64, y::UInt64)::UInt64

Multiplies two blocks.
"""
function matmulmat(x::UInt64, y::UInt64)
    function slice(x::UInt64, y::UInt64, i)
        x = blockgetindex(x, :, i)
        y = blockgetindex(y, i, :)
        return colvecmulrowvec(x, y)
    end
    return slice(x, y, 0) ⊻ slice(x, y, 1) ⊻ slice(x, y, 2) ⊻ slice(x, y, 3) ⊻ slice(x, y, 4) ⊻ slice(x, y, 5) ⊻ slice(x, y, 6) ⊻ slice(x, y, 7)
end

"""
    matmulrowvec(x::UInt64, y::UInt64)::UInt64

Multiplies a block by a row vector.
"""
matmulrowvec(x::UInt64, y::UInt64) = (x & y) ⊻ ((x>>8) & y) ⊻ ((x>>16) & y) ⊻ ((x>>24) & y) ⊻ ((x>>32) & y) ⊻ ((x>>40) & y) ⊻ ((x>>48) & y) ⊻ ((x>>56) & y)

"""
    matmulcolvec(x::UInt64, y::UInt64)::UInt64

Multiplies a block by a column vector.
"""
matmulcolvec(x::UInt64, y::UInt64) = matmulmat(x, y)

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
        x = blockswaprows(x, p, k ÷ 8)
        y = blockswaprows(y, p, k ÷ 8)
        col = repeatcolpartial(x & colmaskexclude(Val(p)), Val(p))
        xrow = repeatrow(blockgetindex(x, p, :))
        yrow = repeatrow(blockgetindex(y, p, :))
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
        # x = x ⊻ (col *)
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

blocktrace(x::UInt64) = isodd(count_ones(x & DIAG_MASK))
