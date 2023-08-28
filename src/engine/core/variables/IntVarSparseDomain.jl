"""
    makeIntVarWithSparseDomain(solver::AbstractSolver, values::Vector{Integer})::AbstractVariable{Integer}

Function to create an `IntVar` with a sparse domain
"""
function makeIntVarWithSparseDomain(solver::AbstractSolver, values::Vector{E})::AbstractVariable{E} where {E <: Integer}
    vMin = minimum(values)
    vMax = maximum(values)

    v = IntVar(solver, vMin, vMax)

    ## Collect the domain
    vals = collect(vMin:vMax)

    ## Remove all values not present in the passed set
    for entry in vals
        if !in(entry, values)
            remove(v, entry)
        end
    end

    return v
end