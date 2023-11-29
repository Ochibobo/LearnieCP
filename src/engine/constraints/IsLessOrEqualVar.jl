"""
    @with_kw mutable struct IsLessOrEqualVar{T} <: AbstractConstraint
        solver::AbstractSolver
        b::BoolVar
        x::AbstractVariable{T}
        y::AbstractVariable{T}
        lessOrEqualConstraint::AbstractConstraint
        greaterThanConstraint::AbstractConstraint

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function IsLessOrEqualVar{T}(b::BoolVar, x::AbstractVariable{T}, y::AbstractVariable{T}) where T
            ## Get the solver instance
            solver = solver(x)
            ## Get the state manager instance
            sm = stateManager(solver)

            ## Constraints to be enforced
            lessOrEqualConstraint = LessOrEqual{T}(x, y)
            greaterThanConstraint = LessOrEqual{T}(y + 1, x)

            ## Constraint-wide variable
            active = makeStateRef(sm, true)

            
            new{T}(solver, b, x, y, lessOrEqualConstraint, greaterThanConstraint, active, false)
        end
    end

`IsLessOrEqualVar` constraint to check if variable `x` <= `y`.

`b` is a `BoolVar` that is set to `true` if `x` <= `y`, `false` otherwise.
"""
@with_kw mutable struct IsLessOrEqualVar{T} <: AbstractConstraint
    solver::AbstractSolver
    b::BoolVar
    x::AbstractVariable{T}
    y::AbstractVariable{T}
    lessOrEqualConstraint::AbstractConstraint
    greaterThanConstraint::AbstractConstraint

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function IsLessOrEqualVar{T}(b::BoolVar, x::AbstractVariable{T}, y::AbstractVariable{T}) where T
        ## Get the solver instance
        solver = Variables.solver(x)
        ## Get the state manager instance
        sm = stateManager(solver)

        ## Constraints to be enforced
        lessOrEqualConstraint = LessOrEqual{T}(x, y)
        greaterThanConstraint = LessOrEqual{T}(y + 1, x)

        ## Constraint-wide variable
        active = makeStateRef(sm, true)

        
        new{T}(solver, b, x, y, lessOrEqualConstraint, greaterThanConstraint, active, false)
    end
end


"""
    post(c::IsLessOrEqualVar)::Nothing

Function to `post` the `IsLessOrEqualVar` constraint
"""
function post(c::IsLessOrEqualVar)::Nothing
    propagateOnBoundChange(c.x, c)
    propagateOnBoundChange(c.y, c)
    propagateOnFix(c.b, c)

    ## Initial propagation
    propagate(c)
    
    return nothing
end


"""
    propagate(c::IsLessOrEqualVar)::Nothing

Function to `propagate` the `IsLessOrEqualVar` constraint
"""
function propagate(c::IsLessOrEqualVar)::Nothing
    if Variables.isTrue(c.b)
        ## Ensure that x <= y
        Solver.post(c.solver, c.lessOrEqualConstraint, enforceFixpoint = false)
        ## Deactivate this constraint
        setValue!(c.active, false)
    elseif Variables.isFalse(c.b)
        Solver.post(c.solver, c.greaterThanConstraint, enforceFixpoint = false)
        setValue!(c.active, false)
    else
        if maximum(c.x) <= minimum(c.y)
            ## Mark `b` as being true
            Variables.fix(c.b, true)
            ## Deactivate the constraint
            setValue!(c.active, false)
        elseif minimum(c.x) > maximum(c.y)
            ## Mark `b` as false
            Variables.fix(c.b, false)
            setValue!(c.active, false)
        end
    end
    
    return nothing
end