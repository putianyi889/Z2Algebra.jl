using Documenter
using Z2Algebra

makedocs(
    sitename = "Z2Algebra",
    format = Documenter.HTML(),
    modules = [Z2Algebra],
    doctest = false
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
