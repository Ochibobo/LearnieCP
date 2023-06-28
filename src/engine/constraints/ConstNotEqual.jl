"""
NotEqual constraint for constants
"""
@with_kw mutable struct ConstNotEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    v::T
    active::State
    isScheduled::Bool

    function ConstNotEqual{T}(x::AbstractVariable{T}, v::T) where T
        _solver = Variables.solver(x)
        ## Get the solver's state manager
        sm = stateManager(_solver)
        ## Create an instance of the active state
        active = makeStateRef(sm, true)
        ## Return a new instance of the ConstNotEqual
        new{T}(_solver, x, v, active, false)
    end
end


"""
    solver(c::ConstNotEqual)::AbstractSolver

Get `ConstNotEqual` constraint associated solver
"""
# function solver(c::ConstNotEqual)::AbstractSolver
#     return c.solver
# end


"""
    post(c::ConstNotEqual)::Nothing

Function to remove the value `v` from the variable
"""
function post(c::ConstNotEqual)::Nothing
    ## remove the value `v` from the variable
    Variables.remove(c.x, c.v)

    return nothing
end


"""
    propagate(c::ConstNotEqual)::Nothing

Function to propagate the `ConstNotEqual` constraint
"""
function propagate(c::ConstNotEqual)::Nothing
    _ = c
    
    return nothing
end



"""
    schedule(c::ConstNotEqual, scheduled::Bool)::Nothing

Function to schedule `ConstNotEqual` constraint
"""
# function schedule(c::ConstNotEqual, scheduled::Bool)::Nothing
#     c.scheduled = scheduled
# end


"""
    isScheduled(c::ConstNotEqual)::Bool

Function to check whether `ConstNotEqual` is currently scheduled for propagation
"""
# function isScheduled(c::ConstNotEqual)::Bool
#     return c.scheduled 
# end


"""
    activate(c::ConstNotEqual, active::Bool)::Nothing

Function used to mark a constraint as being active
"""
# function activate(c::ConstNotEqual, active::Bool)::Nothing
#     setValue!(c.active, active)
# end


"""
    isActive(c::ConstNotEqual)::Bool

Function to check if a constraint is currently active or not
"""
# function isActive(c::ConstNotEqual)::Bool
#     value(c.active)
# end
