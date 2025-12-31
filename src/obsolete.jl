# Obsolete algorithms for blockutils.jl
# Although they have less bitwise operations, they are usually slower due to lack of parallelism.

function column2row(x::UInt64)
    x |= x >> 7
    x |= x >> 14
    x |= x >> 28
    return x & UInt64(0xff)
end

function repeatcolumn(x::UInt64)
    x |= x << 1
    x |= x << 2
    x |= x << 4
    return x
end

function repeaterow(x::UInt64)
    x |= x << 8
    x |= x << 16
    x |= x << 32
    return x
end

function matmulmat(x::UInt64, y::UInt64)
    function level3(x::UInt64, y::UInt64)
        x1 = x & 0xaaaaaaaaaaaaaaaa
        x1 |= x1 >> 1
        y1 = y & 0xff00ff00ff00ff00
        y1 |= y1 >> 8
        z1 = x1 & y1
        x2 = x & 0x5555555555555555
        x2 |= x2 << 1
        y2 = y & 0x00ff00ff00ff00ff
        y2 |= y2 << 8
        z2 = x2 & y2
        return z1 ⊻ z2
    end

    function level2(x::UInt64, y::UInt64)
        x1 = x & 0xcccccccccccccccc
        x1 |= x1 >> 2
        y1 = y & 0xffff0000ffff0000
        y1 |= y1 >> 16
        z1 = level3(x1, y1)
        x2 = x & 0x3333333333333333
        x2 |= x2 << 2
        y2 = y & 0x0000ffff0000ffff
        y2 |= y2 << 16
        z2 = level3(x2, y2)
        return z1 ⊻ z2
    end

    function level1(x::UInt64, y::UInt64)
        x1 = x & 0xf0f0f0f0f0f0f0f0
        x1 |= x1 >> 4
        y1 = y & 0xffffffff00000000
        y1 |= y1 >> 32
        z1 = level2(x1, y1)
        x2 = x & 0x0f0f0f0f0f0f0f0f
        x2 |= x2 << 4
        y2 = y & 0x00000000ffffffff
        y2 |= y2 << 32
        z2 = level2(x2, y2)
        return z1 ⊻ z2
    end

    return level1(x, y)
end