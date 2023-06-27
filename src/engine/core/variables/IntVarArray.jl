"""
    makeIntVarArray(solver::AbstractSolver, size::Integer, min::Integer, max::Integer)::Vector{IntVar}

Function to create an array of integer variables
"""
function makeIntVarArray(solver::AbstractSolver, size::Integer, min::Integer, max::Integer)::Vector{IntVar}
    varArray = Vector{IntVar}(undef, size)

    for index in 1:size
        varArray[index] = IntVar(solver, min, max)
    end

    return varArray
end