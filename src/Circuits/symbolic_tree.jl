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
    for s in steps
        U_step = nothing
        gates_at_step = stepwise_gates[s]
        symbolic_steps[s] = gates_at_step

        sq_gates = [g for g in gates_at_step if g.num_qubits == 1]
        mq_gates = [g for g in gates_at_step if g.num_qubits > 1]

        sq_gates_sorted = _sort_by_glob_qbit_id(sq_gates)

        vec_filled_sq_gates = Vector{QCSym.Gates.AbstractGate}()
        for i in 1:num_qubits
            push!(vec_filled_sq_gates, QCSym.Gates.I_Gate_Filler(i))
        end
        for sqg in sq_gates_sorted
            qid = sqg.qubits_t[1].index_global
            vec_filled_sq_gates[qid] = sqg
        end

        U_step_sq = vec_filled_sq_gates[1]
        if num_qubits > 1
            for q in 2:num_qubits
                U_step_sq = QCSym.:⊗(U_step_sq, vec_filled_sq_gates[q])
            end
        end

        println(typeof(U_step_sq))

        U_step = U_step_sq
        println(typeof(U_step))

        println(U_step)
        println(U)





        U = U === nothing ? U_step : QCSym.mul(U_step, U)
    end
    
    return U
end