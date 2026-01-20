import Base: +, -, *
import Base: getindex, isbitstype, eltype, iszero, isone, zero, one, size, axes
import Random: rand, rand!
import LinearAlgebra: Matrix, tr, triu, tril, istriu, istril, transpose, adjoint

struct Z2Block
    data::UInt64
end
eltype(::Type{Z2Block}) = Z2Number
axes(::Z2Block) = (0:7, 0:7)
function axes(A::Z2Block, d)
    @inline
    d::Integer <= 2 ? axes(A)[d] : OneTo(1)
end

Matrix(x::Z2Block) = [x[i, j] for i in 0:7, j in 0:7]

zero(::Type{Z2Block}) = Z2Block(0x0000000000000000)
one(::Type{Z2Block}) = Z2Block(0x8040201008040201)
zero(::Z2Block) = zero(Z2Block)
one(::Z2Block) = one(Z2Block)

iszero(a::Z2Block) = a.data == 0x0000000000000000
isone(a::Z2Block) = a.data == 0x8040201008040201

-(a::Z2Block) = a

+(a::Z2Block, b::Z2Block) = Z2Block(a.data ⊻ b.data)
-(a::Z2Block, b::Z2Block) = a + b
*(a::Z2Block, b::Z2Block) = Z2Block(matmulmat(a.data, b.data))

getindex(a::Z2Block, i::Integer, j::Integer) = Z2Number(blockgetindex(a.data, i, j))
getindex(a::Z2Block, I, J) = Z2Block(blockgetindex(a.data, I, J))

setindex(a::Z2Block, v::Z2Number, i::Integer, j::Integer) = Z2Block(blocksetindex(a.data, v.value, i, j))

rand(rng::Random.AbstractRNG, ::Random.SamplerType{Z2Block}) = Z2Block(rand(rng, Random.SamplerType{UInt64}()))

tr(a::Z2Block) = Z2Number(blocktrace(a.data))

triu(a::Z2Block) = Z2Block(a.data & TRIU_MASK)
tril(a::Z2Block) = Z2Block(a.data & TRIL_MASK)

triu(a::Z2Block, k::Integer) = Z2Block(a.data & triu_mask(k))
tril(a::Z2Block, k::Integer) = Z2Block(a.data & tril_mask(k))

istriu(a::Z2Block, k::Integer) = iszero(a.data & ~triu_mask(k))
istril(a::Z2Block, k::Integer) = iszero(a.data & ~tril_mask(k))

function rand!(r::AbstractRNG, A::AbstractArray{Z2Block}, ::Type{Z2Block})
    _A = reinterpret(UInt64, A)
    rand!(r, _A)
    return A
end

transpose(a::Z2Block) = Z2Block(transposeblock(a.data))
adjoint(a::Z2Block) = transpose(a)
