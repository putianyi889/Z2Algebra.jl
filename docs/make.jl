using Documenter
using Z2Algebra

makedocs(
    sitename = "Z2Algebra",
    format = Documenter.HTML(),
    modules = [Z2Algebra],
    doctest = false
)

deploydocs(
    repo = "github.com/putianyi889/Z2Algebra.jl.git"
)
