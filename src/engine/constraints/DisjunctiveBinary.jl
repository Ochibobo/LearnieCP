"""
    @with_kw mutable struct DisjunctiveBinary{T} <: AbstractConstraint
        solver::AbstractSolver
        start1::AbstractVariable{T}
        start2::AbstractVariable{T}
        end1::AbstractVariable{T}
        end2::AbstractVariable{T}
        before::BoolVar
        after::BoolVar

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function DisjunctiveBinary{T}(start1::AbstractVariable{T}, end1::AbstractVariable{T}, start2::AbstractVariable{T}, end2::AbstractVariable{T}) where T
            ## Get the solver instance
            solver = Variables.solver(start1)
            ## Get the stateManager instance
            sm = stateManager(solver)

            active = makeStateRef(sm, true)

            before = BoolVar(solver)
            after = !before

            new{T}(solver, start1, start2, end1, end2, before, after, active, false)
        end
    end

`DisjunctiveBinary` constraint that ensures that 2 activities do not overlap.

`before` = `true` if `activity1` << `activity2`

`after` = `true` if `activity2` << `activity1`
"""
@with_kw mutable struct DisjunctiveBinary{T} <: AbstractConstraint
    solver::AbstractSolver
    start1::AbstractVariable{T}
    start2::AbstractVariable{T}
    end1::AbstractVariable{T}
    end2::AbstractVariable{T}
    before::BoolVar
    after::BoolVar

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function DisjunctiveBinary{T}(start1::AbstractVariable{T}, end1::AbstractVariable{T}, start2::AbstractVariable{T}, end2::AbstractVariable{T}) where T
        ## Get the solver instance
        solver = Variables.solver(start1)
        ## Get the stateManager instance
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        before = BoolVar(solver)
        after = BoolVar(solver)

        new{T}(solver, start1, start2, end1, end2, before, after, active, false)
    end
end

"""
    post(c::DisjunctiveBinary{T})::Nothing

Function to `post` the `DisjunctiveBinary` constraint
"""
function post(c::DisjunctiveBinary{T})::Nothing where T
    ## One of the 2 activities must proceed the other
    Solver.post(c.solver, IsLessOrEqualVar{T}(c.before, c.end1, c.start2))
    Solver.post(c.solver, IsLessOrEqualVar{T}(c.after, c.end2, c.start1))
    ## Solver.post(c.solver, NotEqual{T}(c.before, c.after), enforceFixpoint = false)
    ## Ensure that `after` is the opposite of `before` - this is just 
    c.after = !c.before

    return nothing
end


"""
    propagate(c::DisjunctiveBinary)::Nothing

Function used to `propagate` the `DisjunctiveBinary` constraint
"""
function propagate(c::DisjunctiveBinary)::Nothing
    _ = c

    return nothing
end


"""
    isFixed(c::DisjunctiveBinary)::Bool

Function to test if the decision of which activity should come first has been made already
"""
function isFixed(c::DisjunctiveBinary)::Bool
    return Variables.isFixed(c.before)
end


"""
    slack(c::DisjunctiveBinary)::Int

The total `slack` (estimated degrees of freedom)
"""
function slack(c::DisjunctiveBinary)::Int
    return size(c.start1) + size(c.start2)
end


"""
    slackIfBefore(c::DisjunctiveBinary)::Int

Total `slack` if activity1 was to be placed `before` activity2
"""
function slackIfBefore(c::DisjunctiveBinary)::Int
    slack1 = min(maximum(c.start2) - 1, maximum(c.start1)) - minimum(c.start1)
    slack2 = maximum(c.start2) - maximum(minimum(c.start2), minimum(c.end1))

    return slack1 + slack2
end


"""
    slackIfAfter(c::DisjunctiveBinary)::Int

Total `slack` if activity1 was to be placed `after` activity2
"""
function slackIfAfter(c::DisjunctiveBinary)::Int
    slack2 = min(maximum(c.start1) - 1, maximum(c.start2)) - minimum(c.start2)
    slack1 = maximum(c.start1) - maximum(minimum(c.start1), minimum(c.end2))

    return slack2 + slack1
end


"""
    before(c::DisjunctiveBinary)::BoolVar

Function that returns a `BoolVar` indicating whether activity1 occurs `before` activity2
"""
function before(c::DisjunctiveBinary)::BoolVar
    return c.before
end


"""
    after(c::DisjunctiveBinary)::BoolVar

Function that returns a `BoolVar` indicating whether activity1 occurs `after` activity2
"""
function after(c::DisjunctiveBinary)::BoolVar
    return c.after
end



@with_kw mutable struct lessOrEqual{T} <: AbstractConstraint
    solver::AbstractSolver
    x::AbstractVariable{T}
    v::T

    active::State
    scheduled::Bool

    function lessOrEqual(x::AbstractVariable{T}, v::T) where T
        solver = Variables.solver(x)
        sm = stateManager(solver)

        active = makeStateRef(sm, true)

        new{T}(solver, x, v, active, false)
    end
end


function post(c::lessOrEqual)::Nothing
    Variables.removeAbove(c.x, c.v)
    return nothing
end

function propagate(c::lessOrEqual)::Nothing
    _ = c
    return nothing
end