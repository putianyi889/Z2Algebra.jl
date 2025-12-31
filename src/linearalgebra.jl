import Base: +, -, *, /
import Base: transpose

unsafe_add(u::Z2RowVecBlock, v::Z2RowVecBlock) = Z2RowVecBlock(u.data ⊻ v.data, u.length)
unsafe_add(u::Z2ColVecBlock, v::Z2ColVecBlock) = Z2ColVecBlock(u.data ⊻ v.data, u.length)

function +(u::Z2VectorBlock, v::Z2VectorBlock)
    if u.length != v.length
        throw(DimensionMismatch("Cannot add Z2RowVecBlocks of different lengths: $(u.length) and $(v.length)."))
    end
    unsafe_add(u, v)
end

-(u::Z2VectorBlock, v::Z2VectorBlock) = u + v

*(u::Z2ColVecBlock, v::Z2RowVecBlock) = Z2MatrixBlock(colvecmulrowvec(u.data, v.data), (u.length, v.length))
