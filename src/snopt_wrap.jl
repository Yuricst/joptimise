"""
SNOPT wrapper
"""


"""
    minimize_solver_specific(solver::SNOPT, cache, x0, lx, ux, lg, ug, rows, cols,
        outputfile::Bool, lencw::Int=500)

Minimize function interfacing to snopta() routine

# Arguments
    - `cache::AbstractSolver`: cache created using _create_cache()
"""
function minimize_snopt(options, cache, x0, lx, ux, lg, ug, rows, cols,
            outputfile::Bool, lencw::Int=500)

    # define objective function for SNOPT
    function fsnopt!(g, df, dg, x, deriv)
        f = evaluate!(g, df, dg, x, cache)
        fail = false  # check?
        # potentially provide df if user-defined
        return f, fail
    end

    # call snopta
    start = ColdStart(x0, length(lg)+1)
    xstar, fstar, info, out = snopta(fsnopt!, start, lx, ux, lg, ug, rows, cols;
                                    options=options, lencw=lencw)
    return xstar, fstar, info
end
