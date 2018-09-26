#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 04-2018
# Wave equation on Schwarzschild
#--------------------------------------------------------------------

struct U end
struct V end
struct UV end

#--------------------------------------------------------------------
# Define boundary and the product space
#--------------------------------------------------------------------
P1, P2 = 40, 40
M   = 1.0
SUV = ProductSpace{GaussLobatto{U,P1}, GaussLobatto{V,P2}}

#--------------------------------------------------------------------
# Define derivative and boundary operators
#--------------------------------------------------------------------
𝔹 = boundary(Null, SUV)

#--------------------------------------------------------------------
# Define coordinates and their associated derivatives
#--------------------------------------------------------------------
u = Field(SUV, (u,v)->u/2)
v = Field(SUV, (u,v)->v/2)

t = Field(SUV, (u,v)->find_t_of_uv(u,v, M))
r = Field(SUV, (u,v)->find_r_of_uv(u,v, M))
θ = Field(SUV, (u,v)->pi/2)
ϕ = Field(SUV, (u,v)->0)
⊙ = Field(SUV, (u,v)->0)

𝔻v, 𝔻u = derivative(SUV)

#--------------------------------------------------------------------
# Define metric functions 
#--------------------------------------------------------------------
𝒈uu = 𝒈vv = ⊙
𝒈uv  = -32*(M^3/r)*(exp(r/M))
𝒈θθ  = r^2
𝒈ϕϕ  = (r*sin(θ))^2

det𝒈 = -1024*(M^6)*r^2/exp((2*r)/M)

#--------------------------------------------------------------------
# Set boundary conditions
#--------------------------------------------------------------------
ρ = 0 
𝕤 = exp(-((u^2)/0.1)) 
𝕓 = 𝔹*𝕤

#--------------------------------------------------------------------
# Now construct the operator 
#--------------------------------------------------------------------
𝕃 = (𝒈uu*𝔻u*𝔻u + 𝒈vv*𝔻v*𝔻v + 𝒈uv*𝔻u*𝔻v + 𝒈vu*𝔻v*𝔻u
     + sqrt(1/abs(det𝒈))*(𝔻u*(𝒈uu*sqrt(abs(det𝒈))) + 𝔻v*(𝒈vu*sqrt(abs(det𝒈))))*𝔻u
     + sqrt(1/abs(det𝒈))*(𝔻u*(𝒈uv*sqrt(abs(det𝒈))) + 𝔻v*(𝒈vv*sqrt(abs(det𝒈))))*𝔻v)

#--------------------------------------------------------------------
# Solve the system [also check the condition number and eigen values]
#--------------------------------------------------------------------
𝕨 = solve(𝕃 + 𝔹, ρ + 𝕓) 
drawpatch(𝕨, "plots/schwarzschild")
