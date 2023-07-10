using Parameters

"""
    struct ConstraintClosure <: AbstractConstraint
        sm::StateManager
        filteringFunction::Function
        scheduled::Bool
        state::State

        function ConstraintClosure(sm::AbstractSolver, fn)
            state = makeStateRef(sm, true)

            new(sm, fn, false, state)
        end
    end

`ConstraintClosure` used to store anonymous functions to be executed upon propagation
"""
@with_kw struct ConstraintClosure <: AbstractConstraint
    solver::AbstractSolver
    filteringFunction::Function
    scheduled::Bool
    state::State

    function ConstraintClosure(solver::AbstractSolver, fn::Function)
        sm = stateManager(solver)
        state = makeStateRef(sm, true)

        new(solver, fn, false, state)
    end
end


"""
    post(c::ConstraintClosure)::Nothing

Function to post a `ConstraintClosure`
"""
function post(c::ConstraintClosure)::Nothing
    _ = c

    return nothing
end


"""
    propagate(c::ConstraintClosure)::Nothing

Function to propagate a `ConstraintClosure`
"""
function propagate(c::ConstraintClosure)::Nothing
    ## Execute the filtering function
    c.filteringFunction()

    return nothing
end

