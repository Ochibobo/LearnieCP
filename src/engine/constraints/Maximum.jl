"""
    @with_kw mutable struct Maximum{T} <: AbstractConstraint
        solver::AbstractSolver
        x::Vector{<:AbstractVariable{T}}
        y::AbstractVariable{T}

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function Maximum{T}(x::Vector{<:AbstractVariable{T}}, y::AbstractVariable{T}) where T
            isempty(x) && throw(DomainError("Variable x cannot be empty"))
            ## Get the solver instance
            solver = Variables.solver(x[1])
            ## Get the stateManager
            sm = stateManager(solver)

            ## Create the active variable
            active = makeStateRef(sm, true)

            new{T}(solver, x, y, active, false)
        end
    end

`Maximum` constraint to creates the maximum constraint y = maximum(x[0],x[1],...,x[n])

`x` is the variable in which the `maximum` value is to be found

`y` is the variable that is equal to the maximum of `x`
"""
@with_kw mutable struct Maximum{T} <: AbstractConstraint
    solver::AbstractSolver
    x::Vector{<:AbstractVariable{T}}
    y::AbstractVariable{T}

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function Maximum{T}(x::Vector{<:AbstractVariable{T}}, y::AbstractVariable{T}) where T
        isempty(x) && throw(DomainError("Variable x cannot be empty"))
        ## Get the solver instance
        solver = Variables.solver(x[1])
        ## Get the stateManager
        sm = stateManager(solver)

        ## Create the active variable
        active = makeStateRef(sm, true)

        new{T}(solver, x, y, active, false)
    end
end


"""
    post(c::Maximum)::Nothing

Function to `post` the `Maximum` constraint
"""
function post(c::Maximum)::Nothing
    for var in c.x
        ## Propagate on bound changes of the variable x
        propagateOnBoundChange(var, c)
    end

    ## Set bounds for propagation on y too
    propagateOnBoundChange(c.y, c)
    
    propagate(c)

    return nothing
end


"""
    propagate(c::Maximum)::Nothing

Function to `propagate` the `Maximum` constraint
"""
function propagate(c::Maximum)::Nothing
    ## Update the min and max values of each x[i] based on the bounds of y
    yMax = maximum(c.y)
    yMin = minimum(c.y)

    xMax = typemin(Int)
    xMin = typemin(Int)

    nSupport = 0
    supportIdx = 0

    for (i, x) in enumerate(c.x)
        # if minimum(x) < yMin
        #     Variables.removeBelow(x, yMin)
        # end

        if maximum(x) > yMax
            Variables.removeAbove(x, yMax)
        end

        xMin = max(xMin, minimum(x)) ## Get the greatest minimum
        xMax = max(xMax, maximum(x)) ## Get the greatest maximum

        if maximum(x) >= yMin
            nSupport += 1
            supportIdx = i
        end
    end

    

    ## Update the min and max values of each y based on the bounds of all x[i]
    Variables.removeBelow(c.y, xMin)
    Variables.removeAbove(c.y, xMax)

    if nSupport == 1
        Variables.removeBelow(c.x[supportIdx], minimum(c.y))
    end
    
    return nothing
end


"""
x = [
    [1, 2, 3, 4],
    [2, 3, 4, 5]
]

y = [1, 2, 3, 4]
"""