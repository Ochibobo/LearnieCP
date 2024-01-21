"""
    @with_kw mutable struct GreaterOrEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        x::AbstractVariable{T}
        y::AbstractVariable{T}

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function GreaterOrEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
            solver = Variables.solver(x)
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, x, y, active, false)
        end
    end

`GreaterOrEqual` constraint between 2 variables, `x` and `y`. The constraint aims to ensure that `x >= y`.
"""
@with_kw mutable struct GreaterOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    y::AbstractVariable{T}

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function GreaterOrEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
        solver = Variables.solver(x)
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, x, y, active, false)
    end
end


"""
    post(c::GreaterOrEqual)::Nothing

Function to `post` the `GreaterOrEqual` constraint
"""
function post(c::GreaterOrEqual)::Nothing
    propagateOnBoundChange(c.x, c)
    propagateOnBoundChange(c.y, c)

    propagate(c)

    return nothing
end


"""
    propagate(c::GreaterOrEqual)::Nothing

Function to `propagate` the `GreaterOrEqual` constraint
"""
function propagate(c::GreaterOrEqual)::Nothing
    Variables.removeAbove(c.y, minimum(c.x))
    Variables.removeBelow(c.x, maximum(c.y))

    ## Deactivate the constraint if the min(x) >= max(y)
    if minimum(c.x) >= maximum(c.y)
        setValue!(c.active, false)
    end

    return nothing
end


