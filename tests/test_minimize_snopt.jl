"""
Test minimize 2
"""

push!(LOAD_PATH,"../joptimise/src/")
using joptimise

#
# function rosenbrock(g, df, dg, x, deriv)
#     f = (1 - x[1])^2 + 100*(x[2] - x[1]^2)^2
#     fail = false
#
#     # if deriv
#     #     df[1] = -2*(1 - x[1]) + 200*(x[2] - x[1]^2)*-2*x[1]
#     #     df[2] = 200*(x[2] - x[1]^2)
#     # end
#
#     return f, fail
# end

function rosenbrock(x)
    f = (1 - x[1])^2 + 100*(x[2] - x[1]^2)^2
    return f
end


function rosenbrock!(g, x)
    # compute objective
    f = rosenbrock(x)
    # upper bounds as constraint
    g[1] = x[1]^2 + x[2]^2 - 1.0
    return f
end



x0 = [4.0; 4.0]
lx = [-5.0; -5.0]
ux = [5.0; 5.0]
lg = [0.0]
ug = [0.0]
ng = 1


## run minimizer with IPOPT
# ip_options = Dict(
#     "max_iter" => 2500,   # 1500 ~ 2500
#     "tol" => 1e-6
# )
#
# #xopt, fopt, info, out = Snopt.snopta(rosenbrock, x0, lx, ux, lg, ug, rows, cols, options)
# xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug,
# solver="ipopt", options=ip_options);
#
# println("Done with IPOPT!")
# println(info)
# println(xopt)


## run minimizer with SNOPT
sn_options = Dict(
    "Major feasibility tolerance" => 1.e-6,
    "Major optimality tolerance"  => 1.e-6,
    "Minor feasibility tolerance" => 1.e-6,
    "Major iterations limit" => 1000,
    "Major print level" => 1,
)

xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug,
solver="snopt", options=sn_options);

println("Done with SNOPT!")
println(info)
println(xopt)
