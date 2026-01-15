# Interface Support
✅ = fully supported
❎ = fall back
❌ = not supported
❔ = not tested

## Constructor

|Constructor|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|:---:|:---:|:---:|:---:|
|`T(undef,dims)`|✅|✅|✅|
|`T(undef,dims...)`|✅|✅|✅|
|`T(::AbstractArray)`|✅|✅|✅|
|`rand(Z2Number,dims)`|✅|✅|❌|
|`rand(Z2Number,dims...)`|✅|✅|❌|
|`ones(Z2Number,dims)`|✅|❌|❌|
|`ones(Z2Number,dims...)`|✅|❌|❌|
|`zeros(Z2Number,dims)`|✅|❌|❌|
|`zeros(Z2Number,dims...)`|✅|❌|❌|

## `getindex` and `setindex!`

### `getindex(::Z2Matrix, I, J)`

||Number|Range|Colon|
|:---:|:---:|:---:|:---:|
|Number|✅|❌|✅|
|Range|❌|❎|❎|
|Colon|✅|❎|❎|

## Filling Methods

|Method|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|:---:|:---:|:---:|:---:|
|`rand!`|❔|❔|❔|
|`fill!`|❔|❔|❔|
|`copyto!`|❔|❔|❔|
