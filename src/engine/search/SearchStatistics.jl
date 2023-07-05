"""
    mutable struct SearchStatistics
        numberOfSolutions::Integer  = 0
        numberOfFailures::Integer   = 0
        numberOfNodes::Integer      = 0
        completed::Bool             = false
    end

Struct that captures the different search statistics during the dfs search
"""
@with_kw mutable struct SearchStatistics
    numberOfSolutions::Integer  = 0
    numberOfFailures::Integer   = 0
    numberOfNodes::Integer      = 0
    completed::Bool             = false
end


"""
    increaseNumberOfSolutions(s::SearchStatistics)::Nothing

Function to increase the number of solutions found
"""
function increaseNumberOfSolutions(s::SearchStatistics)::Nothing
    s.numberOfSolutions += 1
    return nothing
end


"""
    increaseNumberOfFailures(s::SearchStatistics)::Nothing

Function to increase the number of failures found
"""
function increaseNumberOfFailures(s::SearchStatistics)::Nothing
    s.numberOfFailures += 1
    return nothing
end


"""
    increaseNumberOfNodes(s::SearchStatistics)::Nothing

Function to increase the number of nodes traversed
"""
function increaseNumberOfNodes(s::SearchStatistics)::Nothing
    s.numberOfNodes += 1
    return nothing
end


"""
    markAsCompleted(s::SearchStatistics)::Nothing

Function to mark the search as being completed
"""
function markAsCompleted(s::SearchStatistics)::Nothing
    s.completed = true
    return nothing    
end


"""
    numberOfSolutions(s::SearchStatistics)::Integer

Function to get the number of solutions found
"""
function numberOfSolutions(s::SearchStatistics)::Integer
    return s.numberOfSolutions
end


"""
    numberOfFailures(s::SearchStatistics)::Integer

Function to get the number of failures encountered during search
"""
function numberOfFailures(s::SearchStatistics)::Integer
    return s.numberOfFailures
end


"""
    numberOfNodes(s::SearchStatistics)::Integer

Function to return the number of nodes traversed during search
"""
function numberOfNodes(s::SearchStatistics)::Integer
    return s.numberOfNodes
end


"""
    isCompleted(s::SearchStatistics)::Bool

Function to return whether the search was completed or not
"""
function isCompleted(s::SearchStatistics)::Bool
    return s.completed
end
