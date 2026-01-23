
Base.BigInt(a::Z2Number) = BigInt(a.value)
Base.Bool(a::Z2Number) = a.value
Base.Integer(a::Z2Number) = a

Z2Number(x::Enum{T}) where {T<:Integer} = Z2Number(isodd(x))
Z2Number(x::BigFloat) = Z2Number(isodd(x))
Z2Number(x::Rational) = Z2Number(isodd(x))
Z2Number(x::Base.TwicePrecision) = Z2Number(isodd(x))
Z2Number(z::Complex) = Z2Number(isodd(z))
Z2Number(x::AbstractChar) = Z2Number(isodd(x))
