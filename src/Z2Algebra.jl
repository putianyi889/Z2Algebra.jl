module Z2Algebra

using LinearAlgebra, Random

export Z2Number, Z2RowVector, Z2ColVector, Z2Block, Z2Matrix

include("number.jl")
include("blockutils.jl")
include("block.jl")
include("arrays.jl")
include("linearalgebra.jl")

include("ambiguities.jl")

end
