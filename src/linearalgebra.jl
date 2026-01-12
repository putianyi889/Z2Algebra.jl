import Base: +, -, *, /, \
import LinearAlgebra: tr, lu!

function +(A::Z2Matrix, B::Z2Matrix)
    Base.promote_shape(A, B)
    return _Z2Matrix(A.blocks + B.blocks, A.tailsize)
end

-(A::Z2Matrix, B::Z2Matrix) = A + B

function *(A::Z2Matrix, B::Z2Matrix)
    LinearAlgebra.matmul_size_check(size(A), size(B))
    return _Z2Matrix(A.blocks * B.blocks, (A.tailsize[1], B.tailsize[2]))
end

function tr(A::Z2Matrix)
    A.tailsize[1] == A.tailsize[2] || throw(DimensionMismatch(lazy"matrix is not square: dimensions are $(size(A))"))
    return tr(tr(A.blocks))
end

include("lu.jl")

function _find_first_nonzero_in_column(blocks, blockcol, col)
    for blockrow in axes(blocks, 1)
        row = trailing_zeros(blocks[blockrow, blockcol][:,col].data) ÷ 8
        if row < 8
            return (blockrow, row)
        end
    end
    return (0, 0)
end

function _swap_pivot_row!(blocks, blockcol, col, blockrow, row)
    # blockcol and col: column of the pivot, also destination of the swap.
    # blockrow and row: row of the pivot, also source of the swap.
    shift = 8(col - row)
    maskdest = blockgetindex_mask(col, col:7)
    masksrc = blockgetindex_mask(row, col:7)
    if blockcol == blockrow # swap within one block
        if iszero(shift)
            return
        end
        blocks[blockcol, blockrow] = LUutils.blockswaprows(blocks[blockcol,blockrow], maskdest, masksrc, shift)

        maskdest = blockgetindex_mask(col, :)
        masksrc = blockgetindex_mask(row, :)
        for _blockcol in blockcol+1:size(blocks,2)
            blocks[blockcol,_blockcol] = LUutils.blockswaprows(blocks[blockcol,_blockcol], maskdest, masksrc, shift)
        end
    else # swap between two blocks
        blocks[blockcol,blockcol], blocks[blockrow,blockcol] = LUutils.blockswaprows(blocks[blockcol,blockcol], blocks[blockrow,blockcol], maskdest, masksrc, shift)

        maskdest = blockgetindex_mask(col, :)
        masksrc = blockgetindex_mask(row, :)
        for _blockcol in blockcol+1:size(blocks,2)
            blocks[blockcol,_blockcol], blocks[blockrow,blockcol] = LUutils.blockswaprows(blocks[blockcol,_blockcol], blocks[blockrow,_blockcol], maskdest, masksrc, shift)
        end
    end
end


function lu!(A::Z2Matrix, pivot::Union{RowMaximum,NoPivot,RowNonZero} = RowNonZero(); check = true, allowsingular = false)
    if pivot === NoPivot()
        throw(ArgumentError("NoPivot() is currently not supported for Z2Matrix"))
    end

    ipiv = collect(1:8*size(A.blocks,1))
    info = 0

    colbuffer = Vector{UInt64}(undef, size(A.blocks,1))
    for blockcol in axes(A.blocks, 2)
        for col in 0:7
            (blockrow, row) = LUutils.find_first_nonzero(A.blocks, blockcol, col)

            if iszero(blockrow)
                if iszero(info)
                    info = blocktailsize_to_size(blockcol, col)
                end
                continue # no pivot in this column
            end

            LUutils.swaprows!(A.blocks, blockcol, col, blockrow, row)

            ipiv[blocktailsize_to_size(blockcol, col)] = blocktailsize_to_size(blockrow, row)

            LUutils.eliminate_rows_first!(A.blocks, blockcol, col, colbuffer)
        end
    end
    if info > size(A,1)
        info = 0
    end
    resize!(ipiv, size(A,1))
    check && LinearAlgebra._check_lu_success(info, allowsingular)

    return LU(A, ipiv, info)
end
