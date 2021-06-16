"""
SNOPT wrapper
"""

using Snopt

# abstract type AbstractSolver end
#
# """
#     SNOPT(;options=Dict(), names=Snopt.Names(), warmstart=nothing)
# Use Snopt as the optimizer
# # Arguments
# - `options::Dict`: options for Snopt.  see Snopt docs.
# - `names::Snopt.Names`: custom names for function and variables.
# - `warmstart::Snopt.Start`: a warmstart object (one of the outputs of Snopt.Outputs)
# """
# struct SNOPT{T1,T2,T3} <: AbstractSolver
#     options::T1
#     names::T2
#     warmstart::T3
# end
#
# SNOPT(;options=Dict(), names=Snopt.Names(), warmstart=nothing) = SNOPT(options, names, warmstart)
#

"""
    minimize_solver_specific(solver::SNOPT, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

Minimize function interfacing to snopta() routine

# Arguments
    - `cache::AbstractSolver`: cache created using _create_cache()
"""
function minimize_snopt(options, cache, x0, lx, ux, lg, ug, rows, cols, outputfile)

    # define objective function for SNOPT
    function fsnopt!(g, df, dg, x, deriv)
        f = evaluate!(g, df, dg, x, cache)
        fail = false  # TODO
        # TODO: use deriv
        return f, fail
    end

    # call snopta
    xstar, fstar, info, out = snopta(fsnopt!, x0, lx, ux, lg, ug, rows, cols, options)

    return xstar, fstar, info
end
