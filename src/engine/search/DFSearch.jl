"""
    mutable struct DFSearch
        sm::StateManager
        branchingSchema::Function
        onSolutionListeners::Vector{Function}
        searchStatistics::SearchStatistics

        function DFSearch(sm::StateManager, branchingSchema)
            new(sm, branchingSchema, Vector{Function}(), SearchStatistics())
        end
    end

`DFSearch` sturct for the constraint solver
"""
@with_kw mutable struct DFSearch
    sm::StateManager
    branchingSchema::Function
    onSolutionListeners::Vector{Function}
    searchStatistics::SearchStatistics

    function DFSearch(sm::StateManager, branchingSchema)
        new(sm, branchingSchema, Vector{Function}(), SearchStatistics())
    end
end


"""
    setOnSolution(s::DFSearch, onSolution::Function)

Function to set the function that will be called when a solution is found
"""
function addOnSolution(s::DFSearch, onSolution::Function)::Nothing
    push!(s.onSolutionListeners, onSolution)

    return nothing
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
    for f in s.onSolutionListeners
        f()
    end

    return nothing
end


"""
    solve(s::DFSearch)::Nothing

Function to solve the CSP
"""
function solve(s::DFSearch; searchLimit::Function = () -> false)::Nothing
    # withNewState(stateManager(s), () -> begin this was a replication of storage, don't know how impactful it was
    dfs(s, searchLimit = searchLimit)
    ## Mark the search as being completed
    markAsCompleted(s.searchStatistics)
    # end)
end



"""
    dfs(s::DFSearch)::Nothing

Actual search function
"""
function dfs(s::DFSearch; searchLimit::Function = () -> false)::Nothing
    ## Execute the search-limit if met
    if searchLimit()
        throw(DomainError("Search limit met. Searching stopped."))
    end

    ## Get the branches from the branching schema
    branches = s.branchingSchema()

    if length(branches) == 0
        notifySolution(s)
        increaseNumberOfSolutions(s.searchStatistics)
    else
        for branch in branches
            withNewState(stateManager(s), () -> begin
                try
                    ## Increase the number of nodes
                    increaseNumberOfNodes(s.searchStatistics)
                    ## Execute the branch to propagate the constraints, like calling the fixpoint over here
                    branch()
                    ## Recursively call the DFS
                    dfs(s)
                catch e
                    ## Increase the number of failures
                    increaseNumberOfFailures(s.searchStatistics)
                    # println("Failure in search node with error $e")
                    ##throw(e)
                end
            end)
        end
    end
end


"""
    optimize(objective::AbstractObjective, s::DFSearch)::Nothing

Function to optimize the results
"""
function optimize(objective::AbstractObjective, s::DFSearch; searchLimit::Function = () -> false)::Nothing
    addOnSolution(s, () -> tighten(objective))
    ## Run the dfs/solve
    solve(s, searchLimit = searchLimit)

    return nothing
end


"""
    optimizeSubjectTo(objective::AbstractObjective, s::DFSearch;
        searchLimit::Function = () -> false, subjectTo::Function = () -> {})::Nothing

Function `optimizeSubjectTo` to optimize subject to certain limits
"""
function optimizeSubjectTo(objective::AbstractObjective, s::DFSearch;
    searchLimit::Function = () -> false, subjectTo::Function = () -> nothing)::Nothing
    ## Initialize the SearchStatistics
    s.searchStatistics = SearchStatistics()
    try
        ## Function to be called
        subjectTo()
        ## Call the optimize function
        optimize(objective, s, searchLimit = searchLimit)
    catch e
        if contains(string(e), "NoSuchElement")
            throw(e)
        end
        println("Error when running subjective optimization: $e")
        ## throw(e)
        ## Will classify exceptions later
    end
end