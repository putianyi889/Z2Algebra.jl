using Base: Fix1
using LinearAlgebra: AdjOrTrans
using Base.Broadcast: Broadcasted, DefaultArrayStyle, broadcasted
import Base: copyto!, similar

similar(::Broadcasted{DefaultArrayStyle{2}}, ::Type{Z2Number}, dims) = similar(Z2Matrix, dims)
similar(::Broadcasted{DefaultArrayStyle{1}}, ::Type{Z2Number}, dims) = similar(Z2RowVector, dims)
similar(::Broadcasted{DefaultArrayStyle{1}, <:Any, <:Any, <:Tuple{<:Z2ColVector, <:Z2ColVector}}, ::Type{Z2Number}, dims) = similar(Z2ColVector, dims)

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

"""
    _to_vec_block(dest<:Z2Vector, src<:Z2Vector, v::Z2Block)

Convert a [`Z2Block`](@ref) `v` of a `src` type to a block of `dest` type.
"""
_to_vec_block(::Type{<:Z2RowVector}, ::Type{<:Z2RowVector}, v::Z2Block) = v
_to_vec_block(::Type{<:Z2ColVector}, ::Type{<:Z2ColVector}, v::Z2Block) = v
_to_vec_block(::Type{<:Z2RowVector}, ::Type{<:Z2ColVector}, v::Z2Block) = Z2Block(column2row(v.data))
_to_vec_block(::Type{<:Z2ColVector}, ::Type{<:Z2RowVector}, v::Z2Block) = Z2Block(row2column(v.data))

function copyto!(dest::Z2Matrix, src::Broadcasted{DefaultArrayStyle{2}, <:Any, <:MMOps, Tuple{U,V}}) where {U <: Z2Matrix, V <: Z2Matrix}
    A = src.args[1].blocks
    B = src.args[2].blocks
    copyto!(dest.blocks, broadcasted(_mm_broadcast_op(src.f), A, B))
    return dest
end

function copyto!(dest::Z2Vector, src::Broadcasted{DefaultArrayStyle{1}, <:Any, <:MMOps, Tuple{U,V}}) where {U <: Z2Vector, V <: Z2Vector}
    u = src.args[1].blocks
    v = src.args[2].blocks
    copyto!(dest.blocks, (_mm_broadcast_op(src.f)(_to_vec_block(typeof(dest), U, a), _to_vec_block(typeof(dest), V, b)) for (a, b) in zip(u, v)))
    return dest
end
