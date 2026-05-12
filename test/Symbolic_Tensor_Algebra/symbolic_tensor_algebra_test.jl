using Test

import Symbolics
#import SymbolicUtils
import QCSym


@testset verbose=true "Symbolic Tensor Algebra Tests" begin
    println("Running symbolic tensor algebra tests...")
    
    @testset verbose=true "Kronecker defined" begin
        @testset  begin
            a, b = Symbolics.@variables a[1:2], b[1:2,1:2]
            @test_nowarn QCSym.:⊗(a, b)
        end
    end
end
