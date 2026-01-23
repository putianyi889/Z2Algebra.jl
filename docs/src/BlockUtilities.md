# Utility functions for single blocks

These internal functions are the backend of `Z2Block`, `Z2RowVecBlock` and `Z2ColVecBlock`. They are unsafe, which means that they assume the blocks are of full size and do not check the validity of the arguments.

```@docs
Z2Algebra.bitstringblock
Z2Algebra.blockgetindex_mask
Z2Algebra.blockgetindex
Z2Algebra.rowvecones
Z2Algebra.colvecones
Z2Algebra.blockones
Z2Algebra.column2row
Z2Algebra.row2column
Z2Algebra.transposeblock
Z2Algebra.getcolsum
Z2Algebra.getrowsum
Z2Algebra.getallsum
Z2Algebra.colvecmulrowvec
Z2Algebra.matmulmat
Z2Algebra.matmulrowvec
Z2Algebra.matmulcolvec
Z2Algebra.matldivmat
Z2Algebra.padidentity

Z2Algebra._to_vec_block
```
