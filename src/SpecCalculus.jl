#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 01-2018
#--------------------------------------------------------------------

function cheb(m::Int, x::Float64)::Float64
    return cos(m*acos(x))
end

function chebx{T<:Int}(i::T, N::T)::Float64
    return cospi((i-1)/N)
end

function chebd{T<:Int}(i::T, j::T, N::T)::Float64
	if i==j==1
		return (2N^2 + 1)/6
	elseif i==j==N+1
		return -(2N^2 + 1)/6
	elseif i==j
		return -chebx(j, N)/(2(1-chebx(j, N)^2))
	else
		ci = (i == 1 || i == N+1) ? 2 : 1
		cj = (j == 1 || j == N+1) ? 2 : 1
		s  = (i + j) % 2 != 0 ? -1 : 1
		return (ci/cj)*(s/(chebx(i,N)-chebx(j,N)))
	end
end

function chebw{T<:Int}(i::T, N::T)::Float64
	W = 0.0
	for j in 1:N+1
		w = (j == 1 ? 1 : (j-1)%2 == 0 ? 2/(1-(j-1)^2): 0)
		l = (i == 1 || i == N+1 ? (1/N)*cospi((i-1)*(j-1)/N) : (2/N)*cospi((i-1)*(j-1)/N))
		W +=  w*l
	end
	return W
end

function chebgrid(N::Int)::Array{Float64,1}
    return Float64[chebx(i,N) for i in 1:N+1]
end

function chebgrid(N::Int, M::Int, loc::Int)::Array{Float64,1}
    return Float64[coordtransL2G(M, loc, chebx(i,N)) for i in 1:N+1]
end

function chebweights(N::Int)::Array{Float64,1}
    return Float64[chebw(i,N) for i in 1:N+1]
end

function vandermonde(N::Int)::Array{Float64,2}
    return Float64[cheb(m,x) for x in chebgrid(N), m in 0:N]
end

function pseudovandermonde(N::Int, collocationpts::Array{Float64, 1})::Array{Float64,2}
    return Float64[cheb(m,x) for x in collocationpts, m in 0:N]
end

function modal2nodal(fmodal::Array{Float64,2})::Array{Float64,2}
    (Mx, My) = size(fmodal) .- 1
    fnodal   = Float64[sum(cheb(m-1,x)*cheb(n-1,y)*fmodal[m,n] for m in 1:Mx+1, n in 1:My+1) for x in chebgrid(Mx), y in chebgrid(My)]
end

function nodal2modal(fnodal::Array{Float64,2})::Array{Float64,2}
    (Nx, Ny) = size(fnodal) .- 1
    invndmx  = inv(vandermonde(Nx))
    invndmy  = inv(vandermonde(Ny))
    fmodal   = Float64[sum(invndmy[n,y]*invndmx[m,x]*fnodal[m,n] for x in 1:Nx+1, y in 1:Ny+1) for m in 1:Nx+1, n in 1:Ny+1] 
end


