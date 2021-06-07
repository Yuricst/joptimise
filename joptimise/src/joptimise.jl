"""
joptimise.jl

Wrapper to ipopt and snopt in julia
"""
module joptimise

using Ipopt
using FiniteDiff
# using ForwardDiff
# using ReverseDiff
using SparseArrays
#using SparseDiffTools
#using Zygote
#using DiffResults
#using Requires

# optimizers
include("minimize.jl")
include("cache.jl")
include("ipopt_wrap.jl")

# exported functions
export minimize
export IPOPT
export OptimOptions

end
