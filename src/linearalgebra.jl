import Base: +, -, *, /, \
import LinearAlgebra: tr, lu!, copytrito!, triu!, tril!
using LinearAlgebra.LAPACK
using LinearAlgebra.BLAS

function +(A::Z2Matrix, B::Z2Matrix)
    Base.promote_shape(A, B)
    return _Z2Matrix(A.blocks + B.blocks, A.tailsize)
end

-(A::Z2Matrix, B::Z2Matrix) = A + B
-(A::Z2Matrix) = A

function *(A::Z2Matrix, B::Z2Matrix)
    LinearAlgebra.matmul_size_check(size(A), size(B))
    return _Z2Matrix(A.blocks * B.blocks, (A.tailsize[1], B.tailsize[2]))
end

function tr(A::Z2Matrix)
    A.tailsize[1] == A.tailsize[2] || throw(DimensionMismatch(lazy"matrix is not square: dimensions are $(size(A))"))
    return tr(tr(A.blocks))
end

include("LinearAlgebra/triangular.jl")
include("LinearAlgebra/lu.jl")

