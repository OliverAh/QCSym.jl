
function _promote_shape_nD(a::Symbolics.Arr{T}, b::Symbolics.Arr{T2}) where {T, T2}
    sizea = size(a)
    sizeb = size(b)
    dimsa = length(sizea)
    dimsb = length(sizeb)
    dimsout, dimsother, sizesmore = dimsa>=dimsb ? (dimsa, dimsb, sizea) : (dimsb, dimsa, sizeb)

    sout = zeros(Int, dimsout)
    for i in 1:dimsother
        sout[i] = sizea[i] * sizeb[i]
    end
    for i in dimsout-dimsother+1:dimsout
        sout[i] = sizesmore[i]
    end

    return Tuple(sout)
end

⊗(a::Symbolics.Arr{T}, b::Symbolics.Arr{T2}) where {T, T2} = begin
    out_shape = _promote_shape_nD(a, b)
    #out_type = Symbolics.Arr{promote_type(eltype(a), eltype(b)),length(out_shape)}
    out_type = SymbolicUtils.promote_symtype(*, eltype(a), eltype(b))
    return SymbolicUtils.term(⊗, a, b; type=out_type, shape=Tuple(1:o for o in out_shape))
end

⊗(a<:QCSym.Gates.AbstractQuantumGate, b<:QCSym.Gates.AbstractQuantumGate) = SymbolicUtils.term(⊗, a, b)



# import Base.:*
# Base.:*(a::SymbolicUtils.BSImpl.Type, b::SymbolicUtils.BSImpl.Type) = SymbolicUtils.term(*, a, b)
