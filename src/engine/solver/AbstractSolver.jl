"""
    abstract type AbstractSolver end

Interface definition of a solver
"""
abstract type AbstractSolver end


"""
    stateManager(s::AbstractSolver)::AbstractDomain

Function to get a solver's StateManager
"""
function stateManager(s::AbstractSolver)::AbstractDomain
    throw(error("function stateManager($s) not implemented"))
end


"""
    post(s::AbstractSolver, c::AbstractConstraint)::Nothing

Function used to register a `constraint` to the `Solver`
"""
function post(s::AbstractSolver, c::AbstractConstraint)::Nothing
    throw(error("function post($s, $c) not implemented"))
end


"""
    fixPoint(s::AbstractSolver)::Nothing

Function used to repeatedly perform the search
"""
function fixPoint(s::AbstractSolver)::Nothing
    throw(error("function fixPoint($s) not implemented"))
end


"""
    onFixPoint(s::AbstractSolver,procedure::Function)::Nothing

Procedure called each time the `fixPoint` is executed
"""
function onFixPoint(s::AbstractSolver, procedure::Function)::Nothing
    throw(error("function onFixPoint($s, $procedure) not implemented"))
end


"""
    maximize(v::AbstractVariable{T})::Objective where T

Maximize the value of `v`
"""
function maximize(v::AbstractVariable{T})::AbstractObjective where T
    throw(error("function maximize($v) is not implemented"))
end


"""
    minimize(v::AbstractVariable{T})::Objective where T

Minimize the value of `v`
"""
function minimize(v::AbstractVariable{T})::AbstractObjective where T
    throw(error("function minimize($v) is not implemented"))
end