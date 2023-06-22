
"""
    stateManager(s::AbstractSolver)::AbstractDomain

Function to get a solver's StateManager
"""
function stateManager(s::AbstractSolver)::StateManager
    throw(error("function stateManager($s) not implemented"))
end


"""
    setStateManager(s::AbstractSolver, sm::StateManager)::Nothing

Function to set a solver's state manager
"""
function setStateManager(s::AbstractSolver, sm::StateManager)::Nothing
    throw(error("function setStateManager($s, $sm) not implemented"))
end


"""
    post(s::AbstractSolver, c::AbstractConstraint)::Nothing

Function used to post a `constraint` from the `Solver`
"""
function post(s::AbstractSolver, c::AbstractConstraint)::Nothing
    throw(error("function post($s, $c) not implemented"))
end


"""
    propagate(s::AbstractSolver, c::AbstractConstraint)::Nothing

Function used to `propagate` constraints in the `solver`
"""
function propagate(s::AbstractSolver, c::AbstractConstraint)::Nothing
    throw(error("function propagate($s, $c) not implemented"))
end


"""
    propagationQueue(s::AbstractSolver)::Queue{AbstractConstraint}

Function used to get the propagation queue of the constraints posted in the `AbstractSolver`
"""
function propagationQueue(s::AbstractSolver)::Queue{AbstractConstraint}
    throw(error("function propagationQueue($s) not implemented"))
end


"""
    schedule(s::AbstractSolver, c::AbstractConstraint)::Nothing

Function to add constraint `c` to the propagationQueue of the solver for propagation
"""
function schedule(s::AbstractSolver, c::AbstractConstraint)::Nothing
    throw(error("function schedule($s, $c) not implemented"))    
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
    setObjective(s::AbstractSolver, o::AbstractObjective)::AbstractObjective

Function to set the solver's objective
"""
function setObjective(s::AbstractSolver, o::AbstractObjective)::Nothing
    throw(error("function setObjective($s, $o) not implemented"))    
end


"""
    objective(s::AbstractSolver)::AbstractObjective

Function to get the solver's objective
"""
function objective(s::AbstractSolver)::AbstractObjective
    throw(error("function objective($s) not implemented"))    
end


# """
#     maximize(v::AbstractVariable{T})::Objective where T

# Maximize the value of `v`
# """
# function maximize(v::AbstractVariable{T})::AbstractObjective where T <: Number
#     throw(error("function maximize($v) is not implemented"))
# end


# """
#     minimize(v::AbstractVariable{T})::Objective where T

# Minimize the value of `v`
# """
# function minimize(v::AbstractVariable{T})::AbstractObjective where T <: Number
#     throw(error("function minimize($v) is not implemented"))
# end