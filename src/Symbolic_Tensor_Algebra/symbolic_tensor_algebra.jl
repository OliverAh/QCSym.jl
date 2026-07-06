import Base

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

⊗(a::Array{T,2}, b::Array{T2,2}) where {T, T2} = begin
    out_shape = _promote_shape_nD(a, b)
    #out_type = Symbolics.Arr{promote_type(eltype(a), eltype(b)),length(out_shape)}
    out_type = SymbolicUtils.promote_symtype(*, eltype(a), eltype(b))
    return SymbolicUtils.term(⊗, a, b; type=out_type, shape=Tuple(1:o for o in out_shape))
end


⊗(a::QCSym.Gates.AbstractQuantumGate, b::QCSym.Gates.AbstractQuantumGate) = begin
    #out_shape = (a.shape[1]*b.shape[1], a.shape[2]*b.shape[2])
    _1 = length(a.shape[1])*length(b.shape[1])
    _2 = length(a.shape[2])*length(b.shape[2])
    out_shape = SymbolicUtils.ShapeVecT([1:_1,1:_2])
    #SymbolicUtils.term(⊗, a, b; shape=out_shape, type=SymbolicUtils.BasicSymbolicImpl.Term{SymbolicUtils.SymReal})
    SymbolicUtils.term(⊗, a, b; shape=out_shape, type=QCSym.Gates._CMQGate{QCSym.BitsRegs.QBit})
end

function ⊗(xs::AbstractVector{T}) where {T<:QCSym.Gates.AbstractGate}
    isempty(xs) && throw(ArgumentError("⊗ requires at least one matrix/gate"))
    # returned value matches r = SymbolicUtils.@rule  QCSym.:⊗(~~ys) => 1.0
    # Kronecker product of a single factor is the factor itself
    length(xs) == 1 && return only(xs)

    _1 = prod(length(x.shape[1]) for x in xs)
    _2 = prod(length(x.shape[2]) for x in xs)

    out_shape = SymbolicUtils.ShapeVecT([1:_1, 1:_2])

    return SymbolicUtils.term(
        ⊗,
        xs...;
        shape = out_shape,
        type = QCSym.Gates._CMQGate{QCSym.BitsRegs.QBit},
    )
end

⊗(a::SymbolicUtils.BasicSymbolic, b::QCSym.Gates.AbstractQuantumGate) = begin
    println("Ended up here")
    println(a.shape)
    println(b.shape)
    println(QCSym.SymbolicUtils.shape(a))

    _1 = length(a.shape[1])*length(b.shape[1])
    _2 = length(a.shape[2])*length(b.shape[2])
    out_shape = SymbolicUtils.ShapeVecT([1:_1,1:_2])
    #SymbolicUtils.term(⊗, a, b; shape=out_shape, type=SymbolicUtils.BasicSymbolicImpl.Term{SymbolicUtils.SymReal})
    SymbolicUtils.term(⊗, a, b; shape=out_shape, type=QCSym.Gates._CMQGate{QCSym.BitsRegs.Bit})
end

mul(a::SymbolicUtils.BasicSymbolicImpl.var"typeof(BasicSymbolicImpl)"{SymbolicUtils.SymReal}, b::SymbolicUtils.BasicSymbolicImpl.var"typeof(BasicSymbolicImpl)"{SymbolicUtils.SymReal}) = begin
    
    @assert SymbolicUtils.symtype(a) == QCSym.Gates._CMQGate{QCSym.BitsRegs.QBit} || (SymbolicUtils.symtype(a) == QCSym.Gates._CMSMQGate{QCSym.BitsRegs.QBit}) "Gate types must be either _CMQGate or _CMSMQGate for basic multiplication, but got types a $(SymbolicUtils.symtype(a))"
    
    @assert SymbolicUtils.symtype(b) == QCSym.Gates._CMQGate{QCSym.BitsRegs.QBit} || (SymbolicUtils.symtype(b) == QCSym.Gates._CMSMQGate{QCSym.BitsRegs.QBit}) "Gate types must be either _CMQGate or _CMSMQGate for basic multiplication, but got types b $(SymbolicUtils.symtype(b))"
        
    
    @assert a.shape == b.shape "Gate shapes must match for basic multiplication, but got shapes $(a.shape) and $(b.shape)"
    out_shape = SymbolicUtils.promote_shape(*, a.shape, b.shape)
    
    SymbolicUtils.term(mul, a, b; shape=out_shape, type=QCSym.Gates._CMSMQGate{QCSym.BitsRegs.QBit})
    #mul2(a, b)
end

mul(a::AbstractVector{SymbolicUtils.BasicSymbolicImpl.var"typeof(BasicSymbolicImpl)"{SymbolicUtils.SymReal}}) = begin
    
    for i in eachindex(a)
        @assert SymbolicUtils.symtype(a[i]) == QCSym.Gates._CMQGate{QCSym.BitsRegs.QBit} "Gate types must be either _CMQGate for basic multiplication, but got types a[$i] $(SymbolicUtils.symtype(a[i]))"
    end
    for i in eachindex(a)
        @assert a[1].shape == a[i].shape "Gate shapes must match for basic multiplication, but got shapes $(a[1].shape) and $(a[i].shape)"
    end    
    
    out_shape = a[1].shape
    
    SymbolicUtils.term(mul, a...; shape=out_shape, type=QCSym.Gates._CMSMQGate{QCSym.BitsRegs.QBit})
    #mul2(a, b)
end

# Base.:*(a::QCSym.Gates._CMQGate{QCSym.BitsRegs.Bit}, b::QCSym.Gates._CMQGate{QCSym.BitsRegs.Bit}) = begin
#     @assert a.shape == b.shape "Gate shapes must match for basic multiplication, but got shapes $(a.shape) and $(b.shape)"
#     out_shape = SymbolicUtils.promote_shape(*, a.shape, b.shape)
#     SymbolicUtils.term(*, a, b; shape=out_shape, type=QCSym.Gates._CMSMQGate{QCSym.BitsRegs.BitRegister{QCSym.BitsRegs.Bit}})
# end


# for f ∈ [:⊗]
#     @eval begin
#         $f(x::Union{QCSym.SymbolicUtils.Expr, Symbol, QCSym.Gates.AbstractQuantumGate}, y::Number) = Expr(:call, $f, x, y)
#         $f(x::Number, y::Union{QCSym.SymbolicUtils.Expr, Symbol, QCSym.Gates.AbstractQuantumGate}) = Expr(:call, $f, x, y)
#         $f(x::Union{QCSym.SymbolicUtils.Expr, Symbol, QCSym.Gates.AbstractQuantumGate}, y::Union{QCSym.SymbolicUtils.Expr, Symbol, QCSym.Gates.AbstractQuantumGate}) = (Expr(:call, $f, x, y))
#     end
# end
# Base.:*(a::SymbolicUtils.Expr, b::SymbolicUtils.Expr) = SymbolicUtils.Expr(:call, :*, a, b)

#⊗(a::Type{<:QCSym.Gates.AbstractQuantumGate}, b::Type{<:QCSym.Gates.AbstractQuantumGate}) = SymbolicUtils.term(⊗, a, b)




# import Base.:*
# Base.:*(a::SymbolicUtils.BSImpl.Type, b::SymbolicUtils.BSImpl.Type) = SymbolicUtils.term(*, a, b)
