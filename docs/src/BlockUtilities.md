# Utility functions for single blocks

These internal functions are the backend of `Z2MatrixBlock`, `Z2RowVecBlock` and `Z2ColVecBlock`. They are unsafe, which means that they assume the blocks are of full size and do not check the validity of the arguments.

```@docs
Z2Algebra.rowvecones
Z2Algebra.colvecones
Z2Algebra.blockones
Z2Algebra.getcolumn
Z2Algebra.getrow
Z2Algebra.column2row
Z2Algebra.transposeblock
Z2Algebra.getcolsum
Z2Algebra.getrowsum
Z2Algebra.getallsum
Z2Algebra.colvecmulrowvec
Z2Algebra.matmulmat
Z2Algebra.matldivmat
Z2Algebra.padidentity
```
