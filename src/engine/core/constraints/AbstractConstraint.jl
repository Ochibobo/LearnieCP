"""
    post(c::Constraint)::Nothing

Function `post` of an `AbstractConstraint`. It links the constraint with its variables & performs the initial propagation.
"""
function post(c::AbstractConstraint)::Nothing
    throw(error("function post($c) is not implemented"))
end


"""
    propagate(c::Constraint)::Nothing

Function `propagate` of an `AbstractConstraint`. It applies the filtering algorithm.
"""
function propagate(c::AbstractConstraint)::Nothing
    throw(error("function propagate($c) is not implemented"))    
end


"""
    schedule(c::AbstractConstraint, scheduled::Bool)::Nothing

Function to schedule a constraint in the propagation queue. Also prevents repeated scheduling of a constraint that's still scheduled
"""
function schedule(c::AbstractConstraint, scheduled::Bool)::Nothing
    throw(error("function schedule($c, $scheduled) is not implemented"))
end


"""
    isScheduled(c::AbstractConstraint)::Bool

Function to check whether the constraint is currently scheduled for propagation
"""
function isScheduled(c::AbstractConstraint)::Bool
    throw(error("function isScheduled($c) is not implemented"))    
end


"""
    activate(c::AbstractConstraint, active::State{Bool})::Nothing

Function used to mark a constraint as being active
"""
function activate(c::AbstractConstraint, active::State{Bool})::Nothing
    throw(error("function activate($c, $active) is not implemented"))
end


"""
    isActive(c::AbstractConstraint)::Bool

Function to check if a constraint is currently active or not
"""
function isActive(c::AbstractConstraint)::Bool
    throw(error("function isActive($c) is not implemented"))
end


"""
    solver(c::AbstractConstraint)::AbstractSolver

Get a constraint's associated solver
"""
function solver(c::AbstractConstraint)::AbstractSolver
    throw(error("function solver($c) is not implemented"))
end