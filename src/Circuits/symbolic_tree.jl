function gcol2tree(gcol::GateCollection)
    stepwise_gates = _extract_gates_stepwise(gcol)
    
    steps = sort(collect(keys(stepwise_gates)))
    
    symbolic_steps = Dict{Int, Vector{<:QCSym.Gates.AbstractGate}}()
    println("Converting gate collection to symbolic tree representation...")
    
    for s in steps
        gates_at_step = stepwise_gates[s]
        symbolic_steps[s] = gates_at_step
    end
    
    
    
    
    return symbolic_steps
end