"""

`Or` logical constraint for a vector of `BoolVar`. 
"""
@with_kw mutable struct Or <: AbstractConstraint
    solver::AbstractSolver
    bVars::Vector{BoolVar}
    
    ## Watch variables
    wL::State
    wR::State

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function Or(bVars::Vector{BoolVar})
        isempty(bVars) && throw(DomainError("bVars cannot be an empty vector"))

        solver = Variables.solver(bVars[1])
        sm = stateManager(solver)

        wL = makeStateRef(sm, 1)
        wR = makeStateRef(sm, length(bVars))

        active = makeStateRef(sm, true)

        new(solver, bVars, wL, wR, active, false)
    end
end


"""
    post(c::Or)::Nothing

Function to `post` the `Or` constraint
"""
function post(c::Or)::Nothing
    propagate(c)
end


"""
    propagate(c::Or)::Nothing

Function to `propagate` the `Or` constraint
"""
function propagate(c::Or)::Nothing
    ## Get the value of the left watcher state variable
    idx = value(c.wL)

    ## Continuously loop through the boolvar vector from left to right
    while idx <= length(c.bVars) && Variables.isFixed(c.bVars[idx])
        if Variables.isTrue(c.bVars[idx])
            ## Deactivate the constraint
            setValue!(c.active, false)

            return nothing
        end

        idx += 1
    end

    ## Update the value of the left watcher state variable
    setValue!(c.wL, idx)

    idx = value(c.wR)

    while idx > 0 && Variables.isFixed(c.bVars[idx]) && idx >= value(c.wL)
        if Variables.isTrue(c.bVars[idx])
            ## Deactivate the constraint
            setValue!(c.active, false)

            return nothing
        end

        idx -= 1
    end
    
    ## Update the value of the right watcher state variable
    setValue!(c.wR, idx)

    if value(c.wL) > value(c.wR)
        throw(DomainError("Inconsistency exception violating the Or constraint"))
    elseif value(c.wL) == value(c.wR)
        ## A case for only one unassigned variable
        Variables.fix(c.bVars[value(c.wL)], true)
        ## Deactivate the constraint
        setValue!(c.active, false)
    else
         ## Propagate the constraint only on the 2 variables at wL & wR
        propagateOnFix(c.bVars[value(c.wL)], c)
        propagateOnFix(c.bVars[value(c.wR)], c)
    end

    return nothing
end