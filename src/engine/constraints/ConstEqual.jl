"""
    mutable struct ConstEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        variable::AbstractVariable{T}
        value::T
        active::State{Bool}
        scheduled::Bool

        function ConstEqual{T}(solver::AbstractSolver, variable::AbstractVariable{T}, value::T) where T
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
@with_kw mutable struct ConstEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    variable::AbstractVariable{T}
    value::T
    active::State
    scheduled::Bool

    function ConstEqual{T}(variable::AbstractVariable{T}, value::T) where T
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
    post(c::ConstEqual{T})::Nothing where T

Register the constraint to the variable
"""
function post(c::ConstEqual{T})::Nothing where T
    fix(c.variable, c.value)
end

"""
    propagate(c::ConstEqual{T})::Nothing where T

`Equal` propagation function
"""
function propagate(c::ConstEqual{T})::Nothing where T
    _ = c
    nothing
end
