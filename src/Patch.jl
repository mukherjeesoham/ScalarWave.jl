#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 01-2018
#--------------------------------------------------------------------

struct Patch
    loc::Array{Int,1}
    value::Array{Float64,2}
end

struct Boundary
    kind::Symbol
    value::Array{Float64,1}
end

function getPB(patch::Patch, s::Symbol)::Boundary
    if s==:R
        boundary = Boundary(:R, patch.value[end, :])
    elseif s==:C
        boundary = Boundary(:C, patch.value[:, end])
    else 
        error("Unknown symbol passed")
    end
    return boundary
end

function calcPatch(loc::Array{Int,1}, bnd0::Boundary, bnd1::Boundary, operator::Array{Float64, 4})::Patch
    N = size(operator)[1] - 1
    B = zeros(N+1, N+1)
    if bnd0.value[1] != bnd1.value[1]
        error("Inconsistent boundary conditions.")
    else
        B[1, :] = bnd0.value
        B[:, 1] = bnd1.value
    end
    return Patch(loc, shapeB(reshapeA(operator) \ reshapeB(B))) 
end

# XXX: Need to generalize these for more than one dimension. Implement index-wise multiplication
function pushforward(patch::Patch, M::Int)::Dict{Array{Float64,1}, Patch}
    # Go from N modes in the entire patch to N modes in each subpatch
    N  = size(patch.value) - 1
    xg = Float64[chebx(i,N) for i in 1:N+1]
    vx = vy = vandermonde(N, xg)
    dbase = Dict()
    for k in 1:M, l in 1:M
        loc = [k,l] 
        xp = Float64[coordtrans(M, [chebx(i,N),chebx(1,N)], loc)[1] for i in 1:N+1] 
        yp = Float64[coordtrans(M, [chebx(1,N),chebx(j,N)], loc)[2] for j in 1:N+1]
        px = vandermonde(N, xp) 
        py = vandermonde(N, yp)
        fgrid  = patch.value
        fpatch = px*inv(vx)*fgrid*inv(vy')*py'
        dbase[loc] = Patch(loc, fpatch) 
    end
    return dbase
end

# XXX: Need to generalize this to more dimensions.
# Can you do the restriction patch-wise?
function pullback(dbase::Dict{Array{Int, 1}, Patch}, M::Int)::Patch
    # Go from N modes in each patch to N modes in the entire patch
    fcpatches = zeros((N+1)*M, (N+1)*M)
    cPx = zeros((N+1)*M, (N+1)*M)
    cPy = zeros((N+1)*M, (N+1)*M)
    xg  = Float64[chebx(i,N) for i in 1:N+1]
    vx  = vy = vandermonde(N, xg)
    for i in 1:M, j in 1:M
        li = 1+(i-1)*(N+1)
        lj = 1+(j-1)*(N+1)
        loc = [i,j]
        xp = Float64[coordtrans(M, [chebx(i,N),chebx(1,N)], loc)[1] for i in 1:N+1]
        yp = Float64[coordtrans(M, [chebx(1,N),chebx(j,N)], loc)[2] for j in 1:N+1]
        px = vandermonde(N, xp)
        py = vandermonde(N, yp)
        cPx[li:li+N, lj:lj+N]   = px*inv(vx) 
        cPy[li:li+N, lj:lj+N]   = inv(vy')*py'
        fgrid[li:li+N, lj:lj+N] = dbase[loc]   
    end
    fglobalgrid = pinv(cPx)*fgrid*pinv(cPy)
    return Patch([1,1], fglobalgrid) 
end
