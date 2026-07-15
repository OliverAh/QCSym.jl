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
    #@warn "Extracting gates stepwise from gate collection. Number of unique steps: $num_steps, Max step number: $max_step_num. Consider compressing the circuit to reduce the number of steps."
    
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

function _get_num_gates(gcol::GateCollection)
    num_gates = 0
    for (gate_type, gates) in gcol.collections
        num_gates += length(gates)
    end
    return num_gates
end


function _s2g_parametric(s, gate)
    for (_, p) in gate.parameters
        if isequal(p["sym"], s)
            return true
        end
    end
    if SymbolicUtils.is_called_function_symbolic(gate.symbol)
        gs = Symbolics.get_variables(gate.symbol)
        for gsi in gs
            if isequal(gsi, s)
                return true
            end
        end
    end
    return false
end

function s2g(s, gcol::GateCollection)
    g = nothing
    for (_, gates) in gcol.collections
        for gate in gates
            if isequal(gate.symbol, s)
                return gate
            end
            if !isnothing(gate.parameters)
                _s2g_parametric = QCSym.Circuits._s2g_parametric(s, gate)
                if _s2g_parametric
                    return gate
                end
            end

            if !isnothing(gate.gates22_t)
                for (__, g22q) in gate.gates22_t
                    #println("g22q: ", g22q)
                    for g22 in g22q
                        if isequal(g22.symbol, s)
                            return g22
                        end
                        if !isnothing(g22.parameters)
                            _s2g_parametric = QCSym.Circuits._s2g_parametric(s, g22)
                            if _s2g_parametric
                                return g22
                            end
                        end
                    end
                end
            end
            if !isnothing(gate.gates22_c)
                for (__, g22q) in gate.gates22_c
                    for g22 in g22q
                        #println("g22: ", g22.symbol)
                        if isequal(g22.symbol, s)
                            return g22
                        end
                        if !isnothing(g22.parameters)
                            _s2g_parametric = QCSym.Circuits._s2g_parametric(s, g22)
                            if _s2g_parametric
                                return g22
                            end
                        end
                    end
                end
            end
        end
    end
    return g
end