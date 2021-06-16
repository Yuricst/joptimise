# joptimise 
Julia wrapper to ipopt and snopt, parts borrowed from  [Snow.jl](https://github.com/byuflowlab/SNOW.jl) and [SNOPT7.jl](https://github.com/snopt/SNOPT7.jl). 

:large_blue_circle::white_circle::red_circle:

### Dependencies
`Ipopt`, `FiniteDiff`, `SparseArrays`

For using `SNOPT`, users must also have an active license and set as environment variables in `~/.bashrc` (working on WSL):

```bash
export SNOPT_LICENSE="$HOME/path-to/snopt7.lic"
export LD_LIBRARY_PATH="$HOME/path-to/libsnopt7"
```

### Usage
Import module, define objective function which mutates the constraint value `g` and returns the objective value:

```julia
using joptimise

function rosenbrock!(g, x)
    # compute objective
    f = (1 - x[1])^2 + 100*(x[2] - x[1]^2)^2
    # constraint
    g[1] = x[1]^2 + x[2]^2 - 1.0
    return f
end

# initial guess
x0 = [4.0; 4.0]
# bounds on variables
lx = [-5.0; -5.0]
ux = [5.0; 5.0]
# bounds on constriants
lg = [0.0]
ug = [0.0]
# number of constraints
ng = 1
```

then call SNOPT

```julia
sn_options = Dict(
    "Major feasibility tolerance" => 1.e-6,
    "Major optimality tolerance"  => 1.e-6,
    "Minor feasibility tolerance" => 1.e-6,
    "Major iterations limit" => 1000,
    "Major print level" => 1,
)

xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="snopt", options=sn_options);
```

or IPOPT

```julia
ip_options = Dict(
    "max_iter" => 2500,   # 1500 ~ 2500
    "tol" => 1e-6
)

xopt, fopt, info = minimize(rosenbrock!, x0, ng; lx=lx, ux=ux, lg=lg, ug=ug, solver="ipopt", options=ip_options);
```
