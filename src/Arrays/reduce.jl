
import Base: all, any

any(A::Z2Array) = any(any, A.blocks)

function all(A::Z2Matrix)
    return all(all, @view A.blocks[1:end-1,1:end-1]) &&
    all(==(Z2Block(blockgetindex_mask(:,0:A.tailsize[2]))), @view A.blocks[1:end-1,end]) &&
    all(==(Z2Block(blockgetindex_mask[0:A.tailsize[1],:])), @view A.blocks[end,1:end-1]) &&
    all(A.blocks[end,end].data == blockgetindex_mask(0:A.tailsize[1], 0:A.tailsize[2]))
end

function all(A::Z2RowVector)
    return all(==(Z2Block(ROW_MASK)), A.blocks[1:end-1]) &&
    A.blocks[end].data == blockgetindex_mask(0, 0:A.tailsize)
end

function all(A::Z2ColVector)
    return all(==(Z2Block(COL_MASK)), A.blocks[1:end-1]) &&
    A.blocks[end].data == blockgetindex_mask(0:A.tailsize, 0)
end
