"""
"""
@with_kw mutable struct Equal{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    y::AbstractVariable{T}
    scheduled::Bool
    state::State

    function Equal{T}(x::AbstractVariable{T}, y::AbstractVariable{T})
        ## Get the solver instance
        solver = Variables.solver(x)
        ## Create a state manager instance
        sm = stateManager(solver)
        ## Create a state instance
        state = makeStateRef(sm, true)
        
        new(solver, x, y, false, state)
    end
end


"""
    post(c::Equal{T})::Nothing where T

Function to post the `Equal` constraint
"""
function post(c::Equal)::Nothing
    if isFixed(c.x)
        Variables.fix(c.y, Variables.minimum(c.x))
    elseif isFixed(c.y)
        Variables.fix(c.x, Variables.minimum(c.y))
    else
        ## Register the constraints on the variables
        Variables.propagateOnFix(c.x, c)
        Variables.propagateOnFix(c.y, c)
    end
end


"""
    propagate(c::Equal)::Nothing

Function to propagate the `Equal` constraint
"""
function propagate(c::Equal)::Nothing
    _ = c

    return nothing
end