#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 01-2018
#--------------------------------------------------------------------

function delta{T<:Int}(i::T, j::T)::Float64
	return i==j ? 1 : 0
end

function LinearAlgebra. norm(f::Field{S})::Float64 where {S}
    return norm(vec(f));
end
