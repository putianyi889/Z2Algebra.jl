using Base: Fix1
using LinearAlgebra: AdjOrTrans
using Base.Broadcast: Broadcasted, DefaultArrayStyle, broadcasted
import Base: copyto!, similar

similar(::Broadcasted{DefaultArrayStyle{2}}, ::Type{Z2Number}, dims) = similar(Z2Matrix, dims)

#=
Since the tail blocks are not full, broadcasting over blocks is not correct for general operations.

Block-wise broadcasting works in one of the following cases:
- Case `vvt`. `op.(vec,vec')` if `op(0,a) = op(a,0) = 0`. For example, multiplication.
- Case `mm`. `op.(mat,mat)` and `op.(vec,vec)` if `op(0,0) = 0`. For example, addition and multiplication.

(TODO) Still, for general operations, there is room for performance improvement since filling a zero matrix can be faster than setting all elements one by one.
=#

### Cast vvt
const VVtOps = Union{typeof(*), typeof(&)}

_vvt_broadcast_block(::typeof(*), ::Type{<:Z2ColVector}, ::Type{<:Z2RowVector}, a::Z2Block, b::Z2Block) = Z2Block(colvecmulrowvec(a.data, b.data))
_vvt_broadcast_block(::typeof(*), ::Type{<:Z2RowVector}, ::Type{<:Z2ColVector}, a::Z2Block, b::Z2Block) = Z2Block(transposeblock(colvecmulrowvec(b.data, a.data)))
_vvt_broadcast_block(::typeof(*), ::Type{<:Z2RowVector}, ::Type{<:Z2RowVector}, a::Z2Block, b::Z2Block) = Z2Block(colvecmulrowvec(row2column(a.data), b.data))
_vvt_broadcast_block(::typeof(*), ::Type{<:Z2ColVector}, ::Type{<:Z2ColVector}, a::Z2Block, b::Z2Block) = Z2Block(colvecmulrowvec(a.data, column2row(b.data)))
_vvt_broadcast_block(::typeof(&), U, V, a::Z2Block, b::Z2Block) = _vvt_broadcast_block(*, U, V, a, b)

function copyto!(dest::Z2Matrix, src::Broadcasted{DefaultArrayStyle{2}, <:Any, <:VVtOps, <:Tuple{U,<:AdjOrTrans{Z2Number,V}}}) where {U<:Z2Vector, V<:Z2Vector}
    u = src.args[1].blocks
    v = src.args[2].parent.blocks
    copyto!(dest.blocks, (_vvt_broadcast_block(src.f, U, V, a, b) for a in u, b in v))
    return dest
end

### Case mm
const MMOps = Union{typeof(+), typeof(-), typeof(*)}

_mm_broadcast_op(::typeof(+)) = (+)
_mm_broadcast_op(::typeof(-)) = (+)
_mm_broadcast_op(::typeof(*)) = (&)

function copyto!(dest::Z2Matrix, src::Broadcasted{DefaultArrayStyle{2}, <:Any, <:MMOps, Tuple{U,V}}) where {U <: Z2Matrix, V <: Z2Matrix}
    A = src.args[1].blocks
    B = src.args[2].blocks
    copyto!(dest.blocks, broadcasted(_mm_broadcast_op(src.f), A, B))
    return dest
end
