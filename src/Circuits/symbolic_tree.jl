function gcol2tree(gcol::GateCollection)
    stepwise_gates = _extract_gates_stepwise(gcol)
    
    steps = sort(collect(keys(stepwise_gates)))
    num_steps = length(steps)

    num_qubits = _get_num_qubits(gcol)
    
    symbolic_steps = Dict{Int, Vector{<:QCSym.Gates.AbstractGate}}()
    println("Converting gate collection to symbolic tree representation...")
    println("   Number of unique steps: $num_steps")
    println("   Number of qubits: $num_qubits")

    U = nothing
    U_intermediate = QCSym.SymbolicUtils.BasicSymbolicImpl.var"typeof(BasicSymbolicImpl)"{QCSym.SymbolicUtils.SymReal}[]
    U_step_mq = Vector{Union{Complex{Symbolics.Num}, Symbolics.Num, QCSym.SymbolicUtils.BasicSymbolicImpl.var"typeof(BasicSymbolicImpl)"{QCSym.SymbolicUtils.SymReal}}}()
    for s in steps
        U_step = nothing
        gates_at_step = stepwise_gates[s]
        symbolic_steps[s] = gates_at_step

        sq_gates = [g for g in gates_at_step if g.num_qubits == 1]
        mq_gates = [g for g in gates_at_step if g.num_qubits == 2]

        sq_gates_sorted = _sort_by_glob_qbit_id(sq_gates)
        vec_filled_sq_gates = Vector{QCSym.Gates.AbstractGate}()
        for i in 1:num_qubits
            push!(vec_filled_sq_gates, QCSym.Gates.I_Gate_Filler(i))
        end
        for sqg in sq_gates_sorted
            qid = sqg.qubits_t[1].index_global
            vec_filled_sq_gates[qid] = sqg
        end

        sqsyms_from_gates = [g.symbol for g in vec_filled_sq_gates]

        U_step_sq = QCSym.:⊗(sqsyms_from_gates...)


        for mqg in mq_gates
           vec_filled_mq_sq_gates_0 = Vector{QCSym.Gates.AbstractGate}()
           vec_filled_mq_sq_gates_1 = Vector{QCSym.Gates.AbstractGate}()
            for i in 1:num_qubits
                push!(vec_filled_mq_sq_gates_0, QCSym.Gates.I_Gate_Filler(i))
                push!(vec_filled_mq_sq_gates_1, QCSym.Gates.I_Gate_Filler(i))
            end
            for (qid, gates) in mqg.gates22_t
                vec_filled_mq_sq_gates_0[qid] = gates[1]
                vec_filled_mq_sq_gates_1[qid] = gates[2]
            end
            for (qid, gates) in mqg.gates22_c
                vec_filled_mq_sq_gates_0[qid] = gates[1]
                vec_filled_mq_sq_gates_1[qid] = gates[2]
            end

            mqsyms_from_gates_0 = [g.symbol for g in vec_filled_mq_sq_gates_0]
            mqsyms_from_gates_1 = [g.symbol for g in vec_filled_mq_sq_gates_1]
            
            U_step_mq = push!(U_step_mq, QCSym.SymbolicUtils.term(+, QCSym.:⊗(mqsyms_from_gates_0...), QCSym.:⊗(mqsyms_from_gates_1...); type=QCSym.SymbolicUtils.SymReal))
        end




        #U_step = U_step_sq
        if !isempty(U_step_sq)
            U_intermediate = push!(U_intermediate, U_step_sq)
        end
        if !isempty(U_step_mq)
            U_intermediate = push!(U_intermediate, U_step_mq...)
        end
    end
    U = QCSym.:⊙(U_intermediate...)
    
    return U
end