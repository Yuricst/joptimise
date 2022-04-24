"""
run demo example
"""


function rosenbrock!(g, x)
    # compute objective
    f = (1 - x[1])^2 + 100*(x[2] - x[1]^2)^2
    # constraint
    g[1] = x[1]^2 + x[2]^2 - 1.0
    return f
end


"""
    joptimise_rosenbrock(solve_ipopt::Bool=true, solve_snopt::Bool=false)

Run example with rosenbrock function
"""
function joptimise_rosenbrock(solve_ipopt::Bool=true, solve_snopt::Bool=false)
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
    if solve_ipopt == true
        ip_options = Dict(
            "max_iter" => 1000,
            "tol" => 1e-6
        )
        xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="ipopt", options=ip_options, derivatives=ForwardAD());

        println("Done with IPOPT!")
        println(info)
        println(xopt)
    end

    ## run minimizer with SNOPT
    if solve_snopt == true
        sn_options = Dict(
            "Major feasibility tolerance" => 1.e-6,
            "Major optimality tolerance"  => 1.e-6,
            "Minor feasibility tolerance" => 1.e-6,
            "Major iterations limit" => 1000,
            "Major print level" => 1,
            "Print file" => "snopt_test.out",
            "Summary file" => "screen",
        )
        xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="snopt", options=sn_options, derivatives=ForwardAD());

        println("Done with SNOPT!")
        println(info)
        println(xopt)
    end
end
