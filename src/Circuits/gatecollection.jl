struct GateCollection
    collections::Dict{Type{<:QCSym.Gates.AbstractGate}, Vector{<:QCSym.Gates.AbstractGate}}
end

function _get_num_qubits(gcol::GateCollection)
    qubits = Set{QCSym.BitsRegs.AbstractBit}()
    for (gate_type, gates) in gcol.collections
        for gate in gates
            for q in gate.qubits_t
                push!(qubits, q)
            end
            if gate.qubits_c !== nothing
                for q in gate.qubits_c
                    push!(qubits, q)
                end
            end
        end
    end
    return length(qubits)
end

function _get_num_steps(gcol::GateCollection)
    steps = Int[]
    for (gate_type, gates) in gcol.collections
        for gate in gates
            push!(steps, gate.step)
        end
    end
    return length(unique(steps))
end

function _get_max_step_number(gcol::GateCollection)
    steps = Int[]
    for (gate_type, gates) in gcol.collections
        for gate in gates
            push!(steps, gate.step)
        end
    end
    return maximum(steps)
end

function _sort_by_step!(gcol::GateCollection)
    for (gate_type, gates) in gcol.collections
        sort!(gates, by = x -> x.step)
    end
end

function _sort_by_step(gcol::GateCollection)
    a = typeof(gcol.collections)
    gcol_out = GateCollection(a((k => sort(v, by = x -> x.step)) for (k,v) in gcol.collections))
    return gcol_out
end


function _extract_gates_stepwise(gcol::GateCollection)
    gcol_sorted_by_steps = _sort_by_step(gcol)
    num_steps = _get_num_steps(gcol)
    max_step_num = _get_max_step_number(gcol)
    @warn "Extracting gates stepwise from gate collection. Number of unique steps: $num_steps, Max step number: $max_step_num. Consider compressing the circuit to reduce the number of steps."
    
    stepwise_gates = Dict{Int, Vector{QCSym.Gates.AbstractGate}}(i => QCSym.Gates.AbstractGate[] for i in 1:max_step_num)
    
    for (gate_type, gates) in gcol_sorted_by_steps.collections
        for gate in gates
            push!(stepwise_gates[gate.step], gate)
        end
    end
    return stepwise_gates
end

function _sort_by_glob_qbit_id(a::Vector{<:QCSym.Gates.AbstractGate})
    sort!(a, by = x -> minimum([q.index_global for q in x.qubits_t]))
end