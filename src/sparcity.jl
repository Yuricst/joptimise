"""
Sparcity of functions
"""


abstract type AbstractSparsityPattern end

struct DensePattern <: AbstractSparsityPattern end

struct SparsePattern{TI} <: AbstractSparsityPattern
    rows::Vector{TI}
    cols::Vector{TI}
end


"""
    SparsePattern(A::SparseMatrixCSC)
construct sparse pattern from representative sparse matrix
# Arguments
- `A::SparseMatrixCSC`: sparse jacobian
"""
function SparsePattern(A::SparseMatrixCSC)
    rows, cols, _ = findnz(A)
    return SparsePattern(rows, cols)
end


"""
    SparsePattern(A::Matrix)
construct sparse pattern from representative matrix
# Arguments
- `A::Matrix`: sparse jacobian
"""
function SparsePattern(A::Matrix)
    return SparsePattern(sparse(A))
end


"""
    SparsePattern(::FD, func!, ng, x1, x2, x3)
detect sparsity pattern by computing derivatives (using finite differencing)
at three different locations. Entries that are zero at all three
spots are assumed to always be zero.
# Arguments
- `func!::Function`: function of form f = func!(g, x)
- `ng::Int`: number of constraints
- `x1,x2,x3::Vector{Float}`:: three input vectors.
"""
function SparsePattern(dtype::FD, func!, ng, x1, x2, x3)

    fdtype = finitediff_type(dtype)
    cache = FiniteDiff.JacobianCache(x1, zeros(ng), fdtype)

    nx = length(x1)
    J1 = zeros(ng, nx)
    J2 = zeros(ng, nx)
    J3 = zeros(ng, nx)
    FiniteDiff.finite_difference_jacobian!(J1, func!, x1, cache)
    FiniteDiff.finite_difference_jacobian!(J2, func!, x2, cache)
    FiniteDiff.finite_difference_jacobian!(J3, func!, x3, cache)

    @. J1 = abs(J1) + abs(J2) + abs(J3)
    Jsp = sparse(J1)

    return SparsePattern(Jsp)
end


#  used internally to get rows and cols for dense jacobian
function _get_sparsity(::DensePattern, nx, nf)
    len = nf*nx
    rows = [i for i = 1:nf, j = 1:nx][:]
    cols = [j for i = 1:nf, j = 1:nx][:]
    return rows, cols
end

#  used internally to get rows and cols for sparse jacobian
_get_sparsity(sp::SparsePattern, nx, nf) = sp.rows, sp.cols
