# Z2Algebra.jl

There are packages for general finite fields, such as [GaloisFields.jl](https://github.com/tkluck/GaloisFields.jl) and [FiniteFields.jl](https://github.com/jmichel7/FiniteFields.jl), or even more general algebraic structures, such as [AbstractAlgebra.jl](https://github.com/Nemocas/AbstractAlgebra.jl) and its downstreams. However, since a ``\mathbb{Z}_2`` number can be represented by a single bit, compact storage and fast algorithms can be specialized for this field. This package is an exploration of this idea.

## `Z2Number`
A `Z2Number <: Integer` is a wrapper around a `Bool`.

**Supported interface**

|Category|Methods|
|---|---|
|Arithmetic|`+`, `-`, `*`, `/`, `inv`|
|Property|`iszero`, `isone`, `isodd`, `iseven`, `isfinite`, `isinf`, `isnan`|
|Literal zero and one|`zero`, `one`|
|Comparison|`<`, `signbit`|

## `Z2Block`
`Z2Block` is a mini 8x8 matrix of `Z2Number`, stored in one `UInt64`. `Z2Block` is not a subtype of `AbstractMatrix`, but rather a backend of [`Z2Matrix` and `Z2Vector`](#Z2Matrix-and-Z2Vector).
the bits are arranged in a row-major order, while the lowest bit corresponds to the top-left corner.
```@setup example1
using Z2Algebra
```
```@repl example1
B = Z2Block(0x80402010080402ff)
A = Matrix(B)
```

The index of `Z2Block` is 0-based.
```@repl example1
axes(B)
```

## `Z2Matrix` and `Z2Vector`
A matrix on ``\mathbb{Z}_2`` is partitioned into a matrix of 8x8 `Z2Block`s, where the last row and column may be incomplete and marked by `tailsize` ranged among `0:7`. 
```julia
struct Z2Matrix{B<:AbstractMatrix{Z2Block}} <: AbstractMatrix{Z2Number}
    blocks::B
    tailsize::Tuple{Int,Int}
end
```
Unlike [BlockArrays.jl](https://github.com/JuliaArrays/BlockArrays.jl), blocking of `Z2Matrix` is just a memory layout rather than algebraic concept. Nevertheless, algebra of `Z2Matrix` can exploit the blocking structure to some extent.

`Z2Vector` is stored in the same way as `Z2Matrix`, but each `Z2Block` only has the first row or column.
```julia
struct Z2RowVector{B<:AbstractVector{Z2Block}} <: AbstractVector{Z2Number}
    blocks::B
    tailsize::Int
end

struct Z2ColVector{B<:AbstractVector{Z2Block}} <: AbstractVector{Z2Number}
    blocks::B
    tailsize::Int
end
```

!!! tip "Row vector and column vector"
    Since block transposition is non-trivial, we keep both structures for performance. In-memory transposition only happens when converting between these two types.
    ```@setup example2
    using Z2Algebra
    ```
    ```@repl example2
    A = Z2Matrix(Matrix(Z2Block(0x80402010080402ff)))
    A[1,:]
    A[1,:].blocks
    A[:,3]
    A[:,3].blocks
    ```

**Supported interface**

|Method|`Z2Matrix`|`Z2RowVector`|`Z2ColVector`|
|------|----------|-------------|-------------|
|`size`|✅|✅|✅|
|`similar`|✅|❌|❌|
|`copymutable`, `copy`|✅|❌|❌|

## Specialized linear algebra routines
While Julia's generic routines can already handle linear algebra with `Z2Number` provided, they are not optimized for `Z2Matrix` and `Z2Vector` layouts. Here list some routines that have been specialized.

|Routine|Types|Downstreams|
|-------|-----|-----------|
|`*`|`Z2Matrix`||
|`tr`|`Z2Matrix`||
|`lu!`|`Z2Matrix`|`\`, `det`, `rank`, `inv`|
|`copytrito!`, `triu!`, `tril!`|`Z2Matrix`|`triu`, `tril`|
