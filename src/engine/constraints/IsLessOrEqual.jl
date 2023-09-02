"""
    @with_kw mutable struct IsLessOrEqual{T} <: AbstractConstraint
        solver::AbstractSolver
        b::BoolVar
        iv::AbstractVariable{T}
        v::T

        active::State
        isScheduled::Bool

        function IsLessOrEqual{T}(b::BoolVar, iv::AbstractVariable{T}, v::T)
            ## Get the solver instance
            solver = Variables.solver(b)
            ## Retrieve the state manager
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            new{T}(solver, b, iv, v, active, false)
        end
    end

`IsLessOrEqual` reified constraint to mark `b` as true if `iv <= v` or to prune the domain of `iv` based on the value of `b`
"""
@with_kw mutable struct IsLessOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    b::BoolVar
    iv::AbstractVariable{T}
    v::T

    active::State
    isScheduled::Bool

    function IsLessOrEqual{T}(b::BoolVar, iv::AbstractVariable{T}, v::T) where T
        ## Get the solver instance
        solver = Variables.solver(b)
        ## Retrieve the state manager
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, b, iv, v, active, false)
    end
end


"""
    post(c::IsLessOrEqual)::Nothing

Function to `post` the `IsLessOrEqual` constraint
"""
function post(c::IsLessOrEqual)::Nothing
    if(Variables.isTrue(c.b))
        Variables.removeAbove(c.iv, c.v)
    elseif Variables.isFalse(c.b)
        Variables.removeBelow(c.iv, c.v + 1)
    elseif maximum(c.iv) <= c.v
        Variables.fix(c.b, true)
    elseif minimum(c.iv) > c.v
        Variables.fix(c.b, false)
    else
        ## Propagate anonymous constraints
        whenFix(c.b, () -> begin
            ## If b is fixed, prune c.iv's domain
            if(Variables.isTrue(c.b))
                Variables.removeAbove(c.iv, c.v)
            else
                Variables.removeBelow(c.iv, c.v + 1)
            end
        end)

        whenBoundChange(c.iv, () -> begin
            ## Mark the BoolVar as true or false depending on the bounds of c.iv
            if maximum(c.iv) <= c.v
                Variables.fix(c.b, true)
            elseif minimum(c.iv) > c.v
                Variables.fix(c.b, false)
            else
                ## Do nothing
            end
        end)
    end

    return nothing
end



"""
    IsLessOrEqual(iv::AbstractVariable{T}, c::T)::BoolVar where T

Function to return a `BoolVar` after applying the `IsLessOrEqual` constraint to `iv` & `v`
"""
function IsLessOrEqual(iv::AbstractVariable{T}, v::T)::BoolVar where T
    solver = Variables.solver(iv)
    b = BoolVar(solver)
    ## Post the IsLessOrEqual constraint
    Solver.post(solver, IsLessOrEqual{T}(b, iv, v))
    ## Return the BoolVar
    return b
end


"""
    IsLess(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` < `v`
"""
function IsLess(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return IsLessOrEqual(iv, v - 1) ## Assumes type T implements `-`
end


"""
    IsGreaterOrEqual(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` >= `v`
"""
function IsGreaterOrEqual(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return IsLessOrEqual(-iv, -v)
end


"""
    IsGreater(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` > `v`
"""
function IsGreater(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return IsGreaterOrEqual(iv, v + 1)
end
