"""
Wrapper for minimization function
"""


## Minimization function
"""
Method to resize bounds if float is passed
"""
function _resize_bounds(lx, nx)
    if length(lx) == 1 && nx > 1
        lx = lx*ones(nx)
    end
    return lx
end


"""
    minimize(func!, x0, ng; kwargs...)

Minimize function, common interface to IPOPT and SNOPT

    Objective function structure:

        function func!(g, x)
            <modify g>
            return <objective value>
        end

# Arguments
    - func! (funciton): fitness function
    - x0 (Array): initial guess
    - ng (Float): number of constraints
    - lx (Array): lower bound on x
    - ux (Array): upper bound on x
    - lg (Array): lower bound on constraints
    - ug (Array): upper bound on constraints
    - solver
    - options (Dict): options constructed
    - sparsity
    - derivatives
    - outputfile (boolean): whether to create output file

# Returns
    - (tuple): xstar, fstar, info
"""
function minimize(func!, x0, ng; kwargs...)
    #, lx=-Inf, ux=Inf, lg=-Inf, ug=0.0, options=OptimOptions(), outputfile=false)
    # unpack values
    lx = _assign_from_kwargs(Dict(kwargs), :lx, -Inf)
    ux = _assign_from_kwargs(Dict(kwargs), :ux, Inf)
    lg = _assign_from_kwargs(Dict(kwargs), :lg, -Inf)
    ug = _assign_from_kwargs(Dict(kwargs), :ug, 0.0)
    solver      = _assign_from_kwargs(Dict(kwargs), :solver, "ipopt")
    options     = _assign_from_kwargs(Dict(kwargs), :options,  Dict())
    sparsity    = _assign_from_kwargs(Dict(kwargs), :sparsity, DensePattern())
    derivatives = _assign_from_kwargs(Dict(kwargs), :derivatives, ForwardFD())
    outputfile  = _assign_from_kwargs(Dict(kwargs), :outputfile, false)

    # initialize number of decision variables
    nx = length(x0)

    # resize bounds if input length is 1
    lx = _resize_bounds(lx, nx)
    ux = _resize_bounds(ux, nx)
    lg = _resize_bounds(lg, ng)
    ug = _resize_bounds(ug, ng)

    # create cache
    cache = _create_cache(sparsity, derivatives, func!, nx, ng)

    # determine sparsity pattern
    rows, cols = _get_sparsity(sparsity, nx, ng)

    if cmp(solver, "ipopt") == 0
        xstar, fstar, info = minimize_ipopt(options, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)
    elseif cmp(solver, "snopt") == 0
        xstar, fstar, info = minimize_snopt(options, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)
    end
    return xstar, fstar, info
end


"""
    _assign_from_kwargs(keyargs::Dict, keyname, default)

Utility to unpack kwargs
"""
function _assign_from_kwargs(keyargs::Dict, keyname, default)
    if haskey(keyargs, keyname)==true
        var = keyargs[keyname]
    else
        var = default
    end
    return var
end
