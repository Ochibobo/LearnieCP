"""
    @with_kw mutable struct LessOrEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        x::AbstractVariable{T}
        y::AbstractVariable{T}

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function LessOrEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
            ## Get the solver instance
            solver = Variables.solver(x)
            ## Retrieve the state manager
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, x, y, active, false)
        end
    end

`LessOrEqual` constraint between 2 variables, `x` and `y`. The constraint aims to ensure that `x <= y`.
"""
@with_kw mutable struct LessOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    y::AbstractVariable{T}

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function LessOrEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
        ## Get the solver instance
        solver = Variables.solver(x)
        ## Retrieve the state manager
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, x, y, active, false)
    end
end


"""
    post(c::LessOrEqual)::Nothing

Function to `post` the `LessOrEqual` constraint
"""
function post(c::LessOrEqual)::Nothing
    propagateOnBoundChange(c.x, c)
    propagateOnBoundChange(c.y, c)

    propagate(c)

    return nothing
end


"""
    propagate(c::LessOrEqual)::Nothing

Function to `propagate` the `LessOrEqual` constraint
"""
function propagate(c::LessOrEqual)::Nothing
    Variables.removeAbove(c.x, maximum(c.y))
    Variables.removeBelow(c.y, minimum(c.x))

    if maximum(c.x) <=  minimum(c.y)
        setValue!(c.active, false)
    end

    return nothing
end
