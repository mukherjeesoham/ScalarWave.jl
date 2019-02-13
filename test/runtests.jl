#--------------------------------------------------------------------
# Spacetime Discretization methods in Julia
# Soham 01-2018
#--------------------------------------------------------------------

using ScalarWave, Test

libraries = ["BasisTransformation",
             "MinkowskiDistorted",
             "Radial",
             "Ricci",
             "Schwarzschild"]

libraries = ["NonLinSolver"]
libraries = ["Evaluate"]
libraries = ["BasisTransformation"]
libraries = ["PyPlot"]
libraries = ["AMR"]

for file in libraries
    @info "Testing $file"
    include("$(file)Test.jl")
end
