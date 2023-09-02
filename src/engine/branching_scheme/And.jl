"""
    and(branches::Vararg)::Vector

Function used to combine mutliple branching schemes and return them to the search function
"""
function And(branches::Vararg{Function})::Function
    _branches = collect(branches)
    for branchOptions in _branches
        if(!isempty(branchOptions()))
            return branchOptions
        end
    end

    return () -> []
end