"""
Derivatives-related functions
"""


## Derivative types
abstract type AbstractDiffMethod end

struct ForwardAD <: AbstractDiffMethod end
struct ReverseAD <: AbstractDiffMethod end
struct RevZyg <: AbstractDiffMethod end  # only used for gradients (not jacobians)
struct ForwardFD <: AbstractDiffMethod end
struct CentralFD <: AbstractDiffMethod end
struct ComplexStep <: AbstractDiffMethod end
struct UserDeriv <: AbstractDiffMethod end   # user-specified derivatives


FD = Union{ForwardFD, CentralFD, ComplexStep}

"""
convert to type used in FiniteDiff package
"""
function finitediff_type(dtype)
    if isa(dtype, ForwardFD)
        fdtype = Val{:forward}
    elseif isa(dtype, CentralFD)
        fdtype = Val{:central}
    elseif isa(dtype, ComplexStep)
        fdtype = Val{:complex}
    end
    return fdtype
end


# internally used cache for gradients and jacobians (separately)
struct GradOrJacCache{T1,T2,T3,T4}
    f!::T1
    work::T2
    cache::T3
    dtype::T4
end


function gradientcache(dtype::FD, func!, nx, ng)

    df = zeros(nx)
    x = zeros(nx)
    fdtype = finitediff_type(dtype)
    cache = FiniteDiff.GradientCache(df, x, fdtype)

    return GradOrJacCache(func!, nothing, cache, dtype)
end


function gradient!(df, x, cache::GradOrJacCache{T1,T2,T3,T4}
    where {T1,T2,T3,T4<:FD})

    FiniteDiff.finite_difference_gradient!(df, cache.f!, x, cache.cache)

    return nothing
end
