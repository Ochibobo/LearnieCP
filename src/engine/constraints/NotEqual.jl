"""
    mutable struct NotEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        x::AbstractVariable{T}
        y::AbstractVariable{T}
        c::T
        active::State{Bool}
        scheduled::Bool

        ## x != y + c, where c != 0:
        function NotEqual{T}(solver::AbstractSolver, x::AbstractVariable{T}, y::AbstractVariable{T}, c::T) where T
            ## Get the solver's state manager
            sm = stateManager(solver)
            ## Create a new instance of the active state variable
            active = makeStateRef(sm, true)
            ## Return a new instance of `NotEqual`
            new(solver, x, y, c, active, false)
        end

        ## x != y, where c = 0
        function NotEqual{T}(solver::AbstractSolver, x::AbstractVariable{T}, y::AbstractVariable{T})
            NotEqual{T}(solver, x, y, 0)
        end
    end

`NotEqual` constraint between variables `x` and `y` domains
"""
@with_kw mutable struct NotEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    y::AbstractVariable{T}
    c::T
    active::State
    scheduled::Bool

    ## x != y + c, where c != 0:
    function NotEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}, c::T) where T
        _solver = Variables.solver(x)
        ## Get the solver's state manager
        sm = stateManager(_solver)
        ## Create a new instance of the active state variable
        active = makeStateRef(sm, true)
        ## Return a new instance of `NotEqual`
        new(_solver, x, y, c, active, false)
    end

    ## x != y, where c = 0
    function NotEqual{T}(x::AbstractVariable{T}, y::AbstractVariable{T}) where T
        NotEqual{T}(x, y, 0)
    end
end


"""
    post(c::NotEqual)::Nothing

Function to register the `NotEqual` constraint to the variable
"""
function post(c::NotEqual{T})::Nothing where T
    if isFixed(c.x)
        Variables.remove(c.y, minimum(c.x) - c.c)
    elseif isFixed(c.y)
        Variables.remove(c.x, minimum(c.y) + c.c)
    else
        propagateOnFix(c.x, c)
        propagateOnFix(c.y, c)
    end

    return nothing
end


"""
    propagate(c::NotEqual)::Nothing

`NotEqual` propagation function
"""
function propagate(c::NotEqual{T})::Nothing where T
    if isFixed(c.x)
        Variables.remove(c.y, minimum(c.x) - c.c)
    else
        Variables.remove(c.x, minimum(c.y) + c.c)
    end

    ## Deactivate this constraint
    activate(c, false)
    
    return nothing
end

