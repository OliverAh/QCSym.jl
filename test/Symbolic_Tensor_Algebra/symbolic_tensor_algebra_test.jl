using Test

import Symbolics
#import SymbolicUtils
import QCSym


@testset verbose=true "Symbolic Tensor Algebra Tests" begin
    println("Running symbolic tensor algebra tests...")
    
    @testset verbose=true "Kronecker defined" begin
        @testset "Symbolic arrays" begin
            a, b = Symbolics.@variables a[1:2], b[1:2,1:2]
            @test_nowarn QCSym.:⊗(a, b)
        end

        @testset "QCSym gates" begin
            gate1 = QCSym.Gates.H_Gate
            gate2 = QCSym.Gates.X_Gate
            @test_throws MethodError QCSym.:⊗(gate1, gate2)
        end
    end
end
