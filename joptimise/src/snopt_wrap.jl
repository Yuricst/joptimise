"""
SNOPT wrapper
"""

#using ._snopt
# Snopt solver
abstract type AbstractSolver end

"""
    SNOPT(;options=Dict(), names=Snopt.Names(), warmstart=nothing)
Use Snopt as the optimizer
# Arguments
- `options::Dict`: options for Snopt.  see Snopt docs.
- `names::Snopt.Names`: custom names for function and variables.
- `warmstart::Snopt.Start`: a warmstart object (one of the outputs of Snopt.Outputs)
"""
struct SNOPT{T1,T2,T3} <: AbstractSolver
    options::T1
    names::T2
    warmstart::T3
end

SNOPT(;options=Dict(), names=Snopt.Names(), warmstart=nothing) = SNOPT(options, names, warmstart)


"""
    minimize_solver_specific(solver::SNOPT, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

Minimize function interfacing to SNOPT

# Arguments
    - `cache::AbstractSolver`: cache created using _create_cache()
"""
function minimize_snopt(snopt::SNOPT, cache, x0, lx, ux, lg, ug, rows, cols)

    # define objective function for SNOPT
    function fsnopt!(g, df, dg, x, deriv)
        f = evaluate!(g, df, dg, x, cache)
        fail = false  # TODO
        # TODO: use deriv
        return f, fail
    end

    if !isnothing(snopt.warmstart)
        x0 = snopt.warmstart
    end

    return snopta(fsnopt!, x0, lx, ux, lg, ug, rows, cols,
        snopt.options, names=snopt.names)
end
