module Z2Algebra

using LinearAlgebra

export Z2Number, Z2RowVecBlock, Z2ColVecBlock, Z2MatrixBlock

include("number.jl")
include("blockutils.jl")
include("vector.jl")
include("matrix.jl")
include("linearalgebra.jl")

end
