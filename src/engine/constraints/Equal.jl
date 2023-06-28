"""
    mutable struct Equal{T} <: AbstractConstraint
        solver::AbstractSolver
        variable::AbstractVariable{T}
        value::T
        active::State{Bool}
        scheduled::Bool

        function Equal{T}(solver::AbstractSolver, variable::AbstractVariable{T}, value::T) where T
            ## Get the solver's state manager
            sm = stateManager(solver)
            ## Create an active state instance
            active = makeStateRef(sm, true)
            ## Return a new instance of Equal
            new(solver, variable, value, active, false)
        end
    end

`Equal` constraint that makes sure that variable `variable` matches value `v`
"""
@with_kw mutable struct Equal{T} <: AbstractConstraint
    solver::AbstractSolver
    variable::AbstractVariable{T}
    value::T
    active::State
    scheduled::Bool

    function Equal{T}(variable::AbstractVariable{T}, value::T) where T
        _solver = Variables.solver(variable)
        ## Get the solver's state manager
        sm = stateManager(_solver)
        ## Create an active state instance
        active = makeStateRef(sm, true)
        ## Return a new instance of Equal
        new(_solver, variable, value, active, false)
    end
end


"""
    solver(c::Equal)::AbstractSolver

Get `Equal` constraint associated solver
"""
function solver(c::Equal)::AbstractSolver
    return c.solver
end


"""
    post(c::Equal{T})::Nothing where T

Register the constraint to the variable
"""
function post(c::Equal{T})::Nothing where T
    fix(c.variable, c.value)
end

"""
    propagate(c::Equal{T})::Nothing where T

`Equal` propagation function
"""
function propagate(c::Equal{T})::Nothing where T
    _ = c
    nothing
end


"""
    schedule(c::Equal, scheduled::Bool)::Nothing

Function to schedule `Equal` constraint
"""
function schedule(c::Equal, scheduled::Bool)::Nothing
    c.scheduled = scheduled
end


"""
    isScheduled(c::Equal)::Bool

Function to check whether `Equal` is currently scheduled for propagation
"""
function isScheduled(c::Equal)::Bool
    return c.scheduled 
end


"""
    activate(c::Equal, active::Bool)::Nothing

Function used to mark a constraint as being active
"""
function activate(c::Equal, active::Bool)::Nothing
    setValue!(c.active, active)
end


"""
    isActive(c::Equal)::Bool

Function to check if a constraint is currently active or not
"""
function isActive(c::Equal)::Bool
    value(c.active)
end



