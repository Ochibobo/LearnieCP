"""
    @with_kw mutable struct ConstLessOrEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        x::AbstractVariable{T}
        v::T

        active::State
        scheduled::Bool

        function ConstLessOrEqual{T}(x::AbstractVariable{T}, v::T) where T
            solver = Variables.solver(x)
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, x, v, active, false)
        end
    end

`ConstLessOrEqual` constraint to ensure values in the variable `v` are less than or equal to the constant value `v`
"""
@with_kw mutable struct ConstLessOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    v::T

    active::State
    scheduled::Bool

    function ConstLessOrEqual{T}(x::AbstractVariable{T}, v::T) where T
        solver = Variables.solver(x)
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, x, v, active, false)
    end
end


"""
    post(c::ConstLessOrEqual)::Nothing

Function to `post` the `ConstLessOrEqual` constraint
"""
function post(c::ConstLessOrEqual)::Nothing
    Variables.removeAbove(c.x, c.v)

    return nothing
end


"""
    propagate(c::ConstLessOrEqual)::Nothing

Function to `propagate` the `ConstLessOrEqual` constraint
"""
function propagate(c::ConstLessOrEqual)::Nothing
    _ = c

    return nothing
end