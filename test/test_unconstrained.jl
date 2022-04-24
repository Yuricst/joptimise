"""
Test minimize function with no constraints
"""

#push!(LOAD_PATH,"../src/")
using joptimise


function rosenbrock(x)
    f = (1 - x[1])^2 + 100*(x[2] - x[1]^2)^2
    return f
end


function rosenbrock!(g, x)
    # compute objective
    f = rosenbrock(x)
    g[1] = 0.0
    return f
end

# initial guess
x0 = [4.0; 4.0]
# bounds on variables
lx = [-5.0; -5.0]
ux = [5.0; 5.0]
# bounds on constriants
lg = [0.0]
ug = [0.0]
# number of constraints
ng = 1


## run minimizer with IPOPT
ip_options = Dict(
    "max_iter" => 2500,   # 1500 ~ 2500
    "tol" => 1e-6
)

xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="ipopt", options=ip_options, derivatives=ForwardAD());

println("Done with IPOPT!")
println(info)
println(xopt)


## run minimizer with SNOPT
sn_options = Dict(
    "Major feasibility tolerance" => 1.e-6,
    "Major optimality tolerance"  => 1.e-6,
    "Minor feasibility tolerance" => 1.e-6,
    "Major iterations limit" => 1000,
    "Major print level" => 1,
)

xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="snopt", options=sn_options, derivatives=ForwardAD());

println("Done with SNOPT!")
println(info)
println(xopt)
