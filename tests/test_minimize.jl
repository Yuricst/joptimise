"""
Test optimization
"""


push!(LOAD_PATH,"../joptimise/src/")
using joptimise


function rastrigin(x)
    A = 10
    n = length(x)
    f = A*n
    for i = 1:n
        f += x[i]^2 - A*cos(2π*x[i])
    end
    return f
end


function rastrigin!(g, x)
    # compute objective
    f = rastrigin(x)
    # upper bounds as constraint
    g[1] = x[1] - 5.12
    g[2] = x[2] - 5.12
    # lower bounds as constraint
    g[3] = -5.12 - x[1]
    g[4] = -5.12 - x[2]
    return f
end


x0 = [-1, 0.1]
ng = 4   # number of constraints
#rastrigin!(zeros(ng), x0)

# bounds
lx = [-5.0, -5.0]
ux = [5.0, 5.0]
lg = -Inf*ones(ng);
ug = zeros(ng);

ip_options = Dict(
    "max_iter" => 2500,   # 1500 ~ 2500
    "tol" => 1e-6
)
solver = IPOPT(ip_options)
options = OptimOptions(;solver, derivatives=joptimise.ForwardFD())

# run minimizer
xopt, fopt, info = minimize(rastrigin!, x0, ng, lx, ux, lg, ug, options);

println("Done!")
