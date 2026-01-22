# Broadcast Support

Since the tail blocks are not full, broadcasting over blocks is not correct for general operations.

Block-wise broadcasting works in one of the following cases:
- Case `vvt`. `op.(vec,vec')` if `op(0,a) = op(a,0) = 0`.
- Case `mm`. `op.(mat,mat)` if `op(0,0) = 0`.

Supported `vvt` and `mm` operations are:
```@setup hash575
using Z2Algebra
```
```@repl hash575
Z2Algebra.VVtOps
Z2Algebra.MMOps
```

(TODO) Still, for general operations, there is room for performance improvement since filling a zero matrix can be faster than setting all elements one by one.