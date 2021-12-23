"""
Create docs

See: https://juliadocs.github.io/Documenter.jl/stable/man/guide/
- https://juliadocs.github.io/Documenter.jl/stable/showcase/#Warning-admonition
"""

using Documenter

#push!(LOAD_PATH,"../src/")
#using joptimise
include("../src/joptimise.jl")

# module to make docs
makedocs(
	modules  = [joptimise],
    format   = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"),
	#format = :html,
	sitename = "joptimise.jl",
	pages = [
		"Home" => "index.md",
		"Examples" => "examples.md",
		"API" => "api.md",
	],
	assets=[
        "assets/logo.png",
    ],
)


deploydocs(
    repo   = "https://github.com/Yuricst/joptimise",
    target = "build",
    deps   = nothing,
    make   = nothing,
    push_preview = true
)
