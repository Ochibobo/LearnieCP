"""
DFS Search of the constraint solver
"""
@with_kw mutable struct DFSearch
    sm::StateManager
    branchingSchema::Vector{Function}
    onSolution::Function

    function DFSearch(sm::StateManager, branchingSchema::Vector{Function})
        new(sm, branchingSchema, begin end)
    end
end


"""
    setOnSolution(s::DFSearch, onSolution::Function)

Function to set the function that will be called when a solution is found
"""
function setOnSolution(s::DFSearch, onSolution::Function)
    s.onSolution = onSolution
end

"""
    stateManager(s::DFSearch)::StateManager

Function to get the search state manager
"""
function stateManager(s::DFSearch)::StateManager
    return s.sm
end


"""
    notifySolution(s::DFSearch)::Nothing

Function to be called to print the solution to standard output. 
"""
function notifySolution(s::DFSearch)::Nothing
    s.onSolution()
end


"""
    solve(s::DFSearch)::Nothing

Function to solve the CSP
"""
function solve(s::DFSearch)::Nothing
    withNewState(stateManager(s), begin
        dfs(s)
    end)
end


"""
    dfs(s::DFSearch)::Nothing

Actual search function
"""
function dfs(s::DFSearch)::Nothing
    branches = s.branchingSchema

    if length(branches) == 0
        notifySolution(s)
    else
        for branch in branches
            withNewState(stateManager(s), begin
                try
                    ## Execute the branch
                    branch()
                    ## Recursively call the DFS
                    dfs(s)
                catch e
                    println("Failure in search node")
                end
            end)
        end
    end
end