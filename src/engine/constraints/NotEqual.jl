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
    function NotEqual{T}(solver::AbstractSolver, x::AbstractVariable{T}, y::AbstractVariable{T}) where T
        NotEqual{T}(solver, x, y, 0)
    end
end


"""
    solver(c::NotEqual)::AbstractSolver

Get `NotEqual` constraint associated solver
"""
function solver(c::NotEqual)::AbstractSolver
    return c.solver
end


"""
    post(c::NotEqual)::Nothing

Function to register the `NotEqual` constraint to the variable
"""
function post(c::NotEqual)::Nothing
    if isFixed(c.x)
        remove(y, min(c.x) + c.c)
    elseif isFixed(c.y)
        remove(x, min(c.y) + c.c)
    else
        propagateOnBind(c.x, c)
        propagateOnBind(c.y, c)
    end

    return nothing
end


"""
    propagate(c::NotEqual)::Nothing

`NotEqual` propagation function
"""
function propagate(c::NotEqual)::Nothing
    if isFixed(c.x)
        remove(y, min(c.x) + c.c)
    else
        remove(x, min(c.y) + c.c)
    end

    ## Deactivate this constraint
    activate(c, false)
    
    return nothing
end


"""
    schedule(c::NotEqual, scheduled::Bool)::Nothing

Function to schedule `NotEqual` constraint
"""
function schedule(c::NotEqual, scheduled::Bool)::Nothing
    c.scheduled = scheduled
end


"""
    isScheduled(c::NotEqual)::Bool

Function to check whether `NotEqual` is currently scheduled for propagation
"""
function isScheduled(c::NotEqual)::Bool
    return c.scheduled 
end


"""
    activate(c::NotEqual, active::Bool)::Nothing

Function used to mark a constraint as being active
"""
function activate(c::NotEqual, active::Bool)::Nothing
    setValue(c.active, active)
end


"""
    isActive(c::NotEqual)::Bool

Function to check if a constraint is currently active or not
"""
function isActive(c::NotEqual)::Bool
    value(c.active)
end

