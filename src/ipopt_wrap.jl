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


"""
    process_ipopt_out(filename::String)

Process ipopt output file
"""
function process_ipopt_out(filename::String)
    # get lines
    lines = []
    open(filename) do f
        # read till end of file
        while ! eof(f)
            # read a new / next line for every iteration
            line = readline(f)
            push!(lines, line)
        end
    end
    # process
    nlines = length(lines)
    exit_message = lines[nlines][7:end]
    # handle invalid nlp case
    if cmp(exit_message, "Invalid number in NLP function or derivative detected.")==0
        n_iter = 0
        for line in lines
            if startswith(line, "Number of Iterations....:")
                n_iter = parse(Int64, line[26:end])
            end
        end
        objective = NaN
    else
        n_iter = parse(Int64, lines[nlines-20][26:end])
        objective = parse(Float64, lines[end-17][53:end])
    end
    res = Dict(
        "n_iter" => n_iter,
        "n_obj_func_eval" =>  parse(Int64, lines[nlines-10][56:end]),
        "n_obj_grad_eval" =>  parse(Int64, lines[nlines-9][56:end]),
        "n_neqc_eval" =>      parse(Int64, lines[nlines-8][56:end]),
        "n_nieqc_eval" =>     parse(Int64, lines[nlines-7][56:end]),
        "n_neqc_jac_eval" =>  parse(Int64, lines[nlines-6][56:end]),
        "n_nieqc_jac_eval" => parse(Int64, lines[nlines-5][56:end]),
        "n_lagrange_hessian" => parse(Int64, lines[nlines-4][56:end]),
        "t_cpu_sec_ipopt" => parse(Float64, lines[nlines-3][56:end]),
        "t_cpu_sec_nlp"   => parse(Float64, lines[nlines-2][56:end]),
        "EXIT"   => exit_message,
        "t_cpu" => parse(Float64, lines[nlines-2][56:end])+parse(Float64, lines[nlines-3][56:end]),
        "objective" => objective,
    )
    return lines, res
end
