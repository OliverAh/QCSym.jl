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
            @test_nowarn QCSym.:⊗(gate1, gate2)
        end

        @testset "Kron of gates' symbols" begin
            qc = QCSym.Circuits.QuantumCircuit(name="TestCircuit")
            qreg = QCSym.Circuits.add_qreg(qc, "q_reg_1", 2)
            gate1 = QCSym.Gates.H_Gate
            gate2 = QCSym.Gates.X_Gate
            QCSym.Circuits.add_gate(qc, gate1, qubits_t=[qreg[1]], step=1, is_treat_numeric_only=false)
            QCSym.Circuits.add_gate(qc, gate2, qubits_t=[qreg[2]], step=1, is_treat_numeric_only=false)
            symg1 = qc.gatecollection.collections[gate1][1].symbol
            symg2 = qc.gatecollection.collections[gate2][1].symbol
            @test_nowarn QCSym.:⊗(symg1, symg2)
        end
    end
end
