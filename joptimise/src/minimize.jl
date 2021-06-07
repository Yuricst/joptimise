"""
Wrapper for minimization function
"""


# optimizer options
struct OptimOptions{T1,T2,T3}
    sparsity::T1  # AbstractSparsityPattern
    derivatives::T2  # AbstractDiffMethod
    solver::T3  # AbstractSolver
end

# function to default optimization options
OptimOptions(; sparsity=DensePattern(), derivatives=ForwardFD(), solver=IPOPT()) = OptimOptions(sparsity, derivatives, solver)


## Minimization function
# resize bounds if float is passed
function _resize_bounds(lx, nx)
    if length(lx) == 1 && nx > 1
        lx = lx*ones(nx)
    end
    return lx
end


"""
    minimize(func!, x0, ng, lx=-Inf, ux=Inf, lg=-Inf, ug=0.0, options=OptimOptions(), outputfile=false)

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
    - lg (Array): lower bound on constraints
    - ux (Array): upper bound on x
    - options (OptimOptions): options constructed
    - ug (Array): upper bound on constraints
    - outputfile (boolean): whether to create output file

# Returns
    - (tuple): xstar, fstar, info
"""
function minimize(func!, x0, ng, lx=-Inf, ux=Inf, lg=-Inf, ug=0.0, options=OptimOptions(), outputfile=false)

    # initialize number of decision variables
    nx = length(x0)

    # resize bounds if input length is 1
    lx = _resize_bounds(lx, nx)
    ux = _resize_bounds(ux, nx)
    lg = _resize_bounds(lg, ng)
    ug = _resize_bounds(ug, ng)

    # create cache
    cache = _create_cache(options.sparsity, options.derivatives, func!, nx, ng)

    # determine sparsity pattern
    rows, cols = _get_sparsity(options.sparsity, nx, ng)

    # returns xopt, fopt, info, out
    xstar, fstar, info = minimize_solver_specific(options.solver, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)
    return xstar, fstar, info
end
