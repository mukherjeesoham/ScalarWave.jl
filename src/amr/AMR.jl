#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 02-2019
#--------------------------------------------------------------------

function refine(u::Field{S}) where {S<:GaussLobatto{Tag, N, max, min}} where {Tag, N, max, min}
    SL = GaussLobatto{Tag, N, max, (max + min)/2} 
    SR = GaussLobatto{Tag, N, (max + min)/2, min} 
    uL = Field(SL, x->u(x))
    uR = Field(SR, x->u(x))
    return Dict{Array{Int64,1}, Union{Field, Dict}}([1]=>uL, [2]=>uR)
end

function coarsen(uL::Field{SL}, uR::Field{SR}) where {SL<:GaussLobatto{Tag, N, max, mid}, 
                                                      SR<:GaussLobatto{Tag, N, mid, min}} where {Tag, N, max, min, mid}
    S = GaussLobatto{Tag, N, max, min}
    u = Field(S, x->0)
    for i in 1:N+1
        coord = collocation(S, i)
        if coord in SL
            u.value[i] = uL(coord)
        elseif coord in SR
            u.value[i] = uR(coord)
        else
            @warn "Interpolating at an invalid point"
        end
    end
    return u
end

function refine(u::Field{S}) where {S<:ProductSpace{GaussLobatto{TagV, NV, maxV, minV}, 
                                                    GaussLobatto{TagU, NU, maxU, minU}}} where {TagV, NV, maxV, minV, 
                                                                                                TagU, NU, maxU, minU}

    SLL = ProductSpace{GaussLobatto{TagV, NV, maxV, (maxV + minV)/2},
                       GaussLobatto{TagU, NU, maxU, (maxU + minU)/2}}

    SRR = ProductSpace{GaussLobatto{TagV, NV, (maxV + minV)/2, minV}, 
                       GaussLobatto{TagU, NU, (maxU + minU)/2, minU}} 

    SLR = ProductSpace{GaussLobatto{TagV, NV, (maxV + minV)/2, minV},
                       GaussLobatto{TagU, NU, maxU, (maxU + minU)/2}}

    SRL = ProductSpace{GaussLobatto{TagV, NV, maxV, (maxV + minV)/2}, 
                       GaussLobatto{TagU, NU, (maxU + minU)/2, minU}} 

    uLL = Field(SLL, (x,y)->u(x,y))
    uRR = Field(SRR, (x,y)->u(x,y))
    uRL = Field(SRL, (x,y)->u(x,y))
    uLR = Field(SLR, (x,y)->u(x,y))

    return Dict{Array{Int64,1}, Union{Field, Dict}}([1,1]=>uLL, [1,2]=>uLR, 
                                                    [2,1]=>uRL, [2,2]=>uRR)
end


