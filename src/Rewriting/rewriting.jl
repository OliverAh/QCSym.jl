# r2 = SymbolicUtils.@rule (~a ⊗ ~b)*(~c ⊗ ~d) => (~a*~c) ⊗ (~b*~d)
# r3 = SymbolicUtils.@rule ((~a+~b) ⊗ ~c)*(~d ⊗ ~e) => ((~a+~b)*~d) ⊗ (~c*~e)

r = SymbolicUtils.@rule (~a::isa(a,QCSym.Gates.H_Gate) ⊗ ~b::isa(b,QCSym.Gates.H_Gate)) => 1.0