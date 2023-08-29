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
        whenFixed(c.b, () -> begin
            ## If b is fixed, prune c.iv's domain
            if(Variables.isTrue(c.b))
                Variables.removeAbove(c.iv, c.v)
            else Variables.isFalse(c.b)
                Variables.removeBelow(c.iv, c.v + 1)
            end
        end)

        whenBoundsChange(c.iv, () -> begin
            ## Mark the BoolVar as true or false depending on the bounds of c.iv
            if maximum(c.iv) <= c.v
                Variables.fix(c.b, true)
            else minimum(c.iv) > c.v
                Variables.fix(c.b, false)
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
    isLess(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` < `v`
"""
function isLess(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return IsLessOrEqual(iv, v - 1) ## Assumes type T implements `-`
end


"""
    isGreaterOrEqual(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` >= `v`
"""
function isGreaterOrEqual(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return IsLessOrEqual(-iv, -v)
end


"""
    isGreater(iv::AbstractVariable{T}, v::T)::BoolVar where T

Function to return a `BoolVar` that indicates if `iv` > `v`
"""
function isGreater(iv::AbstractVariable{T}, v::T)::BoolVar where T
    return isGreaterOrEqual(iv, v + 1)
end
