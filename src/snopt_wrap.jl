"""
SNOPT wrapper
"""


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
        fail = false  # check?
        # potentially provide df if user-defined
        return f, fail
    end

    # call snopta
    xstar, fstar, info, out = snopta(fsnopt!, x0, lx, ux, lg, ug, rows, cols, options)

    return xstar, fstar, info
end
