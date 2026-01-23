# Linear Algebra Support

✅ = fully supported

❎ = fall back (no specialized algorithm)

❌ = not supported (returns incorrect types such as `Matrix`, `Vector`, etc.)

❔ = not tested

## Properties
|Method|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|:-:|:-:|:-:|:-:|
|`istriu`|✅|||
|`istril`|✅|||
|`ishermitian`, `issymmetric`|✅|||

## Constructors

|Method|Status|
|:-:|:-:|
|`copytrito!`|✅|
|`triu!`|✅|
|`tril!`|✅|
|`triu`|✅|
|`tril`|✅|

## Arithmetic

!!! note
    Addition and subtraction, as well as `vec * vec'`, fall back to [Broadcast Support](@ref).

|Operation|Status|
|:-:|:-:|
|`mat + mat`|✅|
|`mat - mat`|✅|
|`-mat`|✅|
|`mat * mat`|✅|
|`mat * transmat`|❎|
|`mat * rowvec`|❎|
|`mat * colvec`|❎|
|`mat' * mat`|❎|
|`mat' * rowvec`|❎|
|`mat' * colvec`|❎|
|`rowvec ⋅ rowvec`|❎|
|`rowvec ⋅ colvec`|❎|
|`colvec ⋅ rowvec`|❎|
|`mat \ mat`|❎|
|`mat \ rowvec`|❎|
|`mat \ colvec`|❌|
