"""
Ipopt wrapper
"""


"""
    minimize_solver_specific(solver::IPOPT, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

Minimize function interfacing to IPOPT

# Arguments
    - `cache`: cache created using _create_cache()

Nanami's Function = {red wine + accounting + driving + Bay Area + singing + eating out + coffee + pesto genovese + strawberry + mango + cinnamon roll + french toast + Korean food^(Faily and Friednds)}
The most difficult function on the planet
"""
function minimize_ipopt(options, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

    # initialize
    nx = length(x0)
    ng = length(lg)

    # initialize data for caching results since ipopt separates functions out
    xlast = 2*x0
    f = 0.0
    g = zeros(ng)
    df = zeros(nx)
    dg = zeros(length(rows))

    function ipcon(x, g)  # ipopt calls this function first
        f = evaluate!(g, df, dg, x, cache)
        xlast = x
        return nothing
    end

    function ipobj(x)
        if !isequal(x, xlast)
            f = func!(g, x)
        end
        return f
    end

    function ipgrad_obj(x, grad)
        if !isequal(x, xlast)
            f = evaluate!(g, df, dg, x, cache)
            xlast = x
        end
        grad[:] = df
        return nothing
    end

    function ipjac_con(x, mode, r, c, values)
        if mode == :Structure
            r[:] = rows
            c[:] = cols
        else
            if !isequal(x, xlast)
                f = evaluate!(g, df, dg, x, cache)
                xlast = x
            end
            values[:] = dg
        end
        return nothing
    end

    nzJ = length(rows)
    nH = 1  # irrelevant for quasi-newton
    prob = Ipopt.createProblem(nx, lx, ux, ng, lg, ug, nzJ, nH,
        ipobj, ipcon, ipgrad_obj, ipjac_con)

    # set Ipopt options
    Ipopt.addOption(prob, "hessian_approximation", "limited-memory")
    for (key, value) in options
        Ipopt.addOption(prob, key, value)
    end

    # open output file
    if outputfile==true
        # initialize options
        filename = "ipopt.out"
        print_level = 5
        if haskey(options, "output_file")
            filename = options["output_file"]
        end
        if haskey(options, "print_level")
            print_level = options["print_level"]
        end
        # create Ipopt output file
        Ipopt.openOutputFile(prob, filename, print_level)
    end

    # solve problem
    prob.x = x0
    status = solveProblem(prob)

    # return xstar, fstar, info
    xstar = prob.x
    fstar = prob.obj_val
    info  = Ipopt.ApplicationReturnStatus[status]
    return xstar, fstar, info
end
