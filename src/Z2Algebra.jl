module Z2Algebra

using LinearAlgebra, Random

export Z2Number, Z2RowVector, Z2ColVector, Z2Block, Z2Matrix

include("number.jl")
include("blockutils.jl")
include("block.jl")
include("generic.jl")
include("vector.jl")
include("matrix.jl")
include("linearalgebra.jl")

end
