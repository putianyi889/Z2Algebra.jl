import Base: +, -, *, /, one, zero, isone, iszero, isodd, iseven, isfinite, isinf, isnan, inv, signbit, <
import Base: promote_rule, show, rand

struct Z2Number <: Integer
    value::Bool
end

Z2Number(x::Integer) = Z2Number(isodd(x))
(::Type{T})(a::Z2Number) where {T<:Integer} = T(a.value)
Z2Number(x::Z2Number) = x

promote_rule(::Type{Z2Number}, ::Type{T}) where {T<:Integer} = Z2Number
show(io::IO, a::Z2Number) = print(io, "ℤ₂(", a.value ? "1" : "0", ")")

+(a::Z2Number, b::Z2Number) = Z2Number(a.value ⊻ b.value)
-(a::Z2Number, b::Z2Number) = a + b
-(a::Z2Number) = a
*(a::Z2Number, b::Z2Number) = Z2Number(a.value & b.value)
function /(a::Z2Number, b::Z2Number)
    if b.value
        return a
    else
        throw(DivideError())
    end
end
function inv(a::Z2Number)
    if a.value
        return a
    else
        throw(DivideError())
    end
end

one(::Type{Z2Number}) = Z2Number(true)
zero(::Type{Z2Number}) = Z2Number(false)
signbit(::Z2Number) = false
<(a::Z2Number, b::Z2Number) = (!a.value) & b.value

isone(a::Z2Number) = a.value
iszero(a::Z2Number) = !a.value
isodd(a::Z2Number) = a.value
iseven(a::Z2Number) = !a.value
isfinite(::Z2Number) = true
isinf(::Z2Number) = false
isnan(::Z2Number) = false

rand(rng::Random.AbstractRNG, ::Random.SamplerType{Z2Number}) = Z2Number(rand(rng, Random.SamplerType{Bool}()))
