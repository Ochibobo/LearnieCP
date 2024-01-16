"""
    @with_kw mutable struct ConstGreaterOrEqual{T} <: AbstractVariable
        solver::AbstractSolver
        x::AbstractVariable{T}
        c::T

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function ConstGreaterOrEqual{T}(x::AbstractVariable{T}, c::T) where T
            solver = Variables.solver(x)
            ## Get the state manager instance
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, x, c, active, false)
        end
    end

`ConstGreaterOrEqual` constraint to ensure values in the variable `v` are greater than or equal to the constant value `c`
"""
@with_kw mutable struct ConstGreaterOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    c::T

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function ConstGreaterOrEqual{T}(x::AbstractVariable{T}, c::T) where T
        solver = Variables.solver(x)
        ## Get the state manager instance
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, x, c, active, false)
    end
end


"""
    post(c::ConstGreaterOrEqual)::Nothing

Function used to `post` the `ConstGreaterOrEqual` constraint
"""
function post(c::ConstGreaterOrEqual)::Nothing
    Variables.removeBelow(c.x, c.c)

    return nothing
end


"""
    propagate(c::ConstGreaterOrEqual)::Nothing

Function to `propagate` the `ConstGreaterOrEqual` constraint
"""
function propagate(c::ConstGreaterOrEqual)::Nothing
    - = c

    return nothing
end