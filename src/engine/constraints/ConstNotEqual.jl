"""
NotEqual constraint for constants
"""
@with_kw mutable struct ConstNotEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    v::T
    active::State
    isScheduled::Bool

    function ConstNotEqual{T}(x::AbstractVariable{T}, v::T) where T
        _solver = Variables.solver(x)
        ## Get the solver's state manager
        sm = stateManager(_solver)
        ## Create an instance of the active state
        active = makeStateRef(sm, true)
        ## Return a new instance of the ConstNotEqual
        new{T}(_solver, x, v, active, false)
    end
end


"""
    post(c::ConstNotEqual)::Nothing

Function to remove the value `v` from the variable
"""
function post(c::ConstNotEqual)::Nothing
    ## remove the value `v` from the variable
    Variables.remove(c.x, c.v)

    return nothing
end


"""
    propagate(c::ConstNotEqual)::Nothing

Function to propagate the `ConstNotEqual` constraint
"""
function propagate(c::ConstNotEqual)::Nothing
    _ = c
    
    return nothing
end

