"""
Ipopt wrapper
"""


"""
    minimize_solver_specific(solver::IPOPT, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

Minimize function interfacing to IPOPT

# Arguments
    - `cache::GradOrJacCache`: cache created using _create_cache()

Nanami's Function = {red wine + accounting + driving + Bay Area + singing + eating out + coffee + pesto genovese + strawberry + mango + cinnamon roll + french toast + Korean food^(Faily and Friednds)}
The most difficult function on the planet
"""
function minimize_ipopt(options::Dict, cache, x0, lx, ux, lg, ug, rows, cols, outputfile::Bool)

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

    function ipjac_con(x, r, c, values)
        if !isequal(x, xlast)
            f = evaluate!(g, df, dg, x, cache)
            xlast = x
        end
        values[:] = dg
        return nothing
    end

    nzJ = length(rows)
    nH = 1  # irrelevant for quasi-newton
    #prob = Ipopt.createProblem(
    prob = Ipopt.CreateIpoptProblem(
        nx,  # n
        lx,  # x_L
        ux,  # x_U
        ng,  # m
        lg,  # g_L
        ug,  # g_U
        nzJ, # nele_jac
        nH,  # nele_hess
        ipobj,  # eval_f
        ipcon,  # eval_g
        ipgrad_obj,  # eval_grad_f
        ipjac_con,   # eval_jac_g
        nothing,     # eval_h
    )

    # set Ipopt options
    AddIpoptOption(prob, "hessian_approximation", "limited-memory")
    #Ipopt.addOption(prob, "hessian_approximation", "limited-memory")

    # additional optional options
    for (key, value) in options
        AddIpoptOption(prob, key, value)
        #Ipopt.addOption(prob, key, value)
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
        Ipopt.OpenIpoptOutputFile(prob, filename, print_level)
        #Ipopt.openOutputFile(prob, filename, print_level)
    end

    # solve problem
    prob.x = x0
    status = IpoptSolve(prob) #solveProblem(prob)

    # return xstar, fstar, info
    xstar = prob.x
    fstar = prob.obj_val
    info  = Ipopt.ApplicationReturnStatus[status]
    return xstar, fstar, info
end


"""
Type-specific ipopt add option function
"""
function AddIpoptOption(prob::IpoptProblem, keyword::String, value::String)
    return Ipopt.AddIpoptStrOption(prob, keyword, value)
end

"""
Type-specific ipopt add option function
"""
function AddIpoptOption(prob::IpoptProblem, keyword::String, value::Int)
    return Ipopt.AddIpoptIntOption(prob, keyword, value)
end

"""
Type-specific ipopt add option function
"""
function AddIpoptOption(prob::IpoptProblem, keyword::String, value::Float64)
    return Ipopt.AddIpoptNumOption(prob, keyword, value)
end