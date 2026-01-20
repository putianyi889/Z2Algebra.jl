# Interface Support

✅ = fully supported

❎ = fall back (no specialized algorithm)

❌ = not supported (returns incorrect types such as `Matrix`, `Vector`, etc.)

❔ = not tested

## Constructor

|Constructor|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|:---:|:---:|:---:|:---:|
|`T(undef,dims)`|✅|✅|✅|
|`T(undef,dims...)`|✅|✅|✅|
|`similar`|✅|✅|✅|
|`T(::AbstractArray)`|✅|✅|✅|
|`rand(Z2Number,dims)`|✅|✅|❌|
|`ones(Z2Number,dims)`|✅|✅|❌|
|`zeros(Z2Number,dims)`|✅|✅|❌|

!!! note "Default constructor for vectors"
    When in ambiguity, `Z2RowVector` is constructed by default. This applies to `similar`, `rand`, `ones`, etc.

## `getindex` and `setindex!`

### `getindex(::Z2Matrix, I, J)`

||Number|Range|Colon|
|:---:|:---:|:---:|:---:|
|Number|✅|❎|✅|
|Range|❌|❎|❎|
|Colon|✅|❎|❎|

## Filling Methods

|Method|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|:---:|:---:|:---:|:---:|
|`rand!`|❔|❔|❔|
|`fill!`|❔|❔|❔|
|`copyto!`|❔|❔|❔|
|`copy`|❔|❔|❔|
