"""
    and(branches::Vararg)::Vector

Function used to combine mutliple branching schemes and return them to the search function
"""
function and(branches::Vararg)::Vector
    for branchOptions in branches
        if(!isempty(branchOptions))
            return branchOptions
        end
    end

    return []
end