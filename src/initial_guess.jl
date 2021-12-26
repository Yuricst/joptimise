"""
	random_initial_guess(lx::Vector,ux::Vector,large_val::Float64=100.0)

Generate random initial guess
"""
function random_initial_guess(lx::Vector,ux::Vector,large_val::Float64=100.0)
	nx = length(lx)
	rand_arr = rand(nx)
	x0 = []
	for i = 1:nx
		if lx[i] == -Inf
			lx_i = -large_val
		else
			lx_i = lx[i]
		end
		if ux[i] == Inf
			ux_i = large_val
		else
			ux_i = ux[i]
		end
		push!(x0, lx_i + rand_arr[i]*(ux_i-lx_i))
	end
	return x0
end