
function _promote_shape_2D(a::Symbolics.Arr{T,2}, b::Symbolics.Arr{T2,2}) where {T, T2}
    sa = size(a)
    sb = size(b)
    return (1:sa[1]*sb[1], 1:sa[2]*sb[2])
end

⊗(a::Symbolics.Arr, b::Symbolics.Arr) = SymbolicUtils.term(⊗, a, b; type=Symbolics.Arr{promote_type(eltype(a), eltype(b)),2}, shape=_promote_shape_2D(a, b))

# import Base.:*
# Base.:*(a::SymbolicUtils.BSImpl.Type, b::SymbolicUtils.BSImpl.Type) = SymbolicUtils.term(*, a, b)
