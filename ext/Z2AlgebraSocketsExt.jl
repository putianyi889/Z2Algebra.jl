module Z2AlgebraSocketsExt

using Z2Algebra, Sockets

Z2Algebra.Z2Number(ip::Sockets.IPAddr) = Z2Number(isodd(ip))

end
