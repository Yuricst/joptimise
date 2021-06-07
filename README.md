# joptimise
Julia wrapper to ipopt and snopt


### Dependencies
`Ipopt`, `FiniteDiff`, `SparseArrays`

### Usage
Import module, define objective function which mutates the constraint value `g` and returns the objective value:

```julia
using joptimise

function objective!(g, x)
    # compute objective
    f = objective_value(x)
    # compute n constraint
    g[1] = constraint_1(x)
    g[2] = constraint_2(x)
    # return objective
    return f
end
```

then call minimizer

```julia
ip_options = Dict(
    "max_iter" => 2500,   # 1500 ~ 2500
    "tol" => 1e-6
)
solver = IPOPT(ip_options)
options = OptimOptions(;solver, derivatives=ForwardFD())

xopt, fopt, info = minimize(objective!, x0, ng, lx, ux, lg, ug, options);
```
