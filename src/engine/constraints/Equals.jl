"""
    @with_kw mutable struct Equal{T} <: AbstractConstraint
        solver::AbstractSolver
        x::AbstractVariable{T}
        y::AbstractVariable{T}
        scheduled::Bool
        state::State

        function Equal{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
            ## Get the solver instance
            solver = Variables.solver(x)
            ## Create a state manager instance
            sm = stateManager(solver)
            ## Create a state instance
            state = makeStateRef(sm, true)
            
            new(solver, x, y, false, state)
        end
    end

`Equal` constraint between variables `x` and `y`
"""
@with_kw mutable struct Equal{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    y::AbstractVariable{T}
    scheduled::Bool
    state::State

    function Equal{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
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
        Variables.fix(c.y, minimum(c.x))
    elseif isFixed(c.y)
        Variables.fix(c.x, minimum(c.y))
    else
        ## Ensure the bounds intersect
        boundsIntersect(c.x, c.y)
        ## Prune the domains of the variables; removing values that are different in either domain
        pruneEquals(c.x, c.y)
        pruneEquals(c.y, c.x)
        
        ## Register the constraints to be propagated as anonymous constraints
        whenDomainChange(c.x, () -> begin
            boundsIntersect(c.x, c.y) ## Ascertain the bounds intersect
            pruneEquals(c.x, c.y)     ## Prune values within the domains that aren't equal
        end)

        whenDomainChange(c.y, () -> begin
            boundsIntersect(c.y, c.x) ## Ascertain the bounds intersect
            pruneEquals(c.y, c.x)     ## Prune values within the domains that aren't equal
        end)
    end

    return nothing
end


"""
    boundsIntersect(x::AbstractVariable{T}, y::AbstractVariable{T})::Nothing where T
    
Ascertain that the bounds of variables `x` and `y` are the same/intersect
"""
function boundsIntersect(x::AbstractVariable{T}, y::AbstractVariable{T})::Nothing where T
    ## Get the maximum and minimim of both variables
    maxMinumimValue = max(minimum(x), minimum(y)) ## The greatest minimum
    minMaximumValue = min(maximum(x), maximum(y)) ## The smallest maximum

    ## Align the bounds
    Variables.removeAbove(x, minMaximumValue)
    Variables.removeBelow(x, maxMinumimValue)
    Variables.removeAbove(y, minMaximumValue)
    Variables.removeBelow(y, maxMinumimValue)

    return nothing
end


"""
    pruneEquals(x::AbstractVariable{T}, y::AbstractVariable{T})::Nothing where T

Function to prune values that aren't the same in the domain of the variables `x` and `y`
"""
function pruneEquals(from::AbstractVariable{T}, to::AbstractVariable{T})::Nothing where T
    ## Vector to hold domain values
    target = Vector{T}()

    ## Fill the target vector
    Variables.fillArray(from, target)

    ## Actual pruning of values that aren't equal
    for value in target
        if !Variables.in(value, from)
            Variables.remove(to, value)
        end
    end

    return nothing
end


"""
    propagate(c::Equal)::Nothing

Function to propagate the `Equal` constraint
"""
function propagate(c::Equal)::Nothing
    _ = c

    return nothing
end