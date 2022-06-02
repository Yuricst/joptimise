"""
Test using user-defined function
See: http://flow.byu.edu/SNOW.jl/guide.html
"""

#push!(LOAD_PATH,"../src/")
#using joptimise
include("../src/joptimise.jl")


function fitness!(g, df, dg, x)

    # objective
    f = x[1]^2 - 0.5*x[1] - x[2] - 2

    # constraints
    g[1] = x[1]^2 - 4*x[1] + x[2] + 1
    g[2] = 0.5*x[1]^2 + x[2]^2 - x[1] - 4

    # gradient
    df[1] = 2*x[1] - 0.5
    df[2] = -1

    # jacobian
    dg[1, 1] = 2*x[1] - 4
    dg[1, 2] = 1
    dg[2, 1] = x[1] - 1
    dg[2, 2] = 2*x[2]

    return f
end


x0 = [1.0; 1.0]  # starting point
lx = [-5.0, -5]  # lower bounds on x
ux = [5.0, 5]  # upper bounds on x
ng = 2  # number of constraints

lg = -Inf*one(ng)  # lower bounds on g
ug = zeros(ng)  # upper bounds on g

xopt, fopt, info = joptimise.minimize(
    fitness!, x0, ng; 
    lx=lx, ux=ux, lg=lg, ug=ug,
    derivatives=joptimise.UserDeriv(),
);

