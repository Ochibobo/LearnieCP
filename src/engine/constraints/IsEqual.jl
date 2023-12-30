"""
    @with_kw struct IsEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        var::AbstractVariable{T}
        val::T
        b::BoolVar
        
        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function IsEqual{T}(b::BoolVar, var::AbstractVariable{T}, val::T) where T
            solver = Variables.solver(var)
            ## Get the state manager instance
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, var, val, b, active, false)
        end
    end

`IsEqual` constraint structure used to check if an abstract variable is equal to the set value and adjust the passed boolean 
variable as accordingly. However, if the boolean variable is set prior, then it has an effect on the value of the abstract
variable depending on whether the boolean variable is fixed to `true` or `false`.
"""
@with_kw mutable struct IsEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    var::AbstractVariable{T}
    val::T
    b::BoolVar
    
    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function IsEqual{T}(b::BoolVar, var::AbstractVariable{T}, val::T) where T
        solver = Variables.solver(var)
        ## Get the state manager instance
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, var, val, b, active, false)
    end
end


"""
    post(c::IsEqual)::Nothing

Function to `post` the `IsEqual` constraint
"""
function post(c::IsEqual)::Nothing
    propagate(c)
    ## Only append callbacks if the current constraint is active after initial propagation
    if value(c.active) 
        propagateOnDomainChange(c.var, c)
        propagateOnFix(c.b, c)
    end

    return nothing
end


"""
    propagate(c::IsEqual)::Nothing 

Function to `propagate` the `IsEqual` constraint
"""
function propagate(c::IsEqual)::Nothing
    if Variables.isTrue(c.b)
        fix(c.var, c.val)
        setValue!(c.active, false)
    elseif Variables.isFalse(c.b)
        Variables.remove(c.var, c.val)
        setValue!(c.active, false)
    elseif !in(c.val, c.var)
        fix(c.b, false)
        setValue!(c.active, false)
    elseif isFixed(c.var)
        fix(c.b, true)
        setValue!(c.active, false)
    end

    return nothing
end


"""
    IsEqual(var::AbstractVariable{T}, val::T)::BoolVar where T

Function used to `post` the `IsEqual` constraint and return the associated `BoolVar`
"""
function IsEqual(var::AbstractVariable{T}, val::T)::BoolVar where T
    ## Get the solver instance
    solver = Variables.solver(var)
    ## Create the BoolVar instance
    b = BoolVar(solver)

    ## An instance of the IsEqual constraint
    isEqualConstraint = IsEqual{T}(b, var, val)

    ## Post the constraint
    Solver.post(solver, isEqualConstraint)

    return b
end