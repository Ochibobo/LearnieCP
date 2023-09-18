"""
    @with_kw mutable struct Element1DVar{T} <: AbstractConstraint
        solver::AbstractSolver
        array::Vector{AbstractVariable{T}}
        y::AbstractVariable{Integer}
        z::AbstractVariable{T}

        active::State
        scheduled::Bool

        function Element1DVar{T}(array::Vector{<:AbstractVariable{T}}, y::AbstractVariable{Integer}, z::AbstractVariable{T}) where T
            ## Get the solver instance
            solver = Variables.solver(y)

            ## Get the state manager
            sm = stateManager(solver)

            ## Create an active state instance
            active = makeStateRef(sm, true)

            new{T}(solver, array, y, z, active, false)
        end
    end

`Element1DVar` constraint used to index through variable arrays using an integer variable.
`T` is the Variable array
`y` is the index variable
`z` is the 
"""
@with_kw mutable struct Element1DVar{T} <: AbstractConstraint
    solver::AbstractSolver
    array::Vector{AbstractVariable{T}}
    y::AbstractVariable{Integer}
    z::AbstractVariable{T}

    active::State
    scheduled::Bool

    function Element1DVar{T}(array::Vector{<:AbstractVariable{T}}, y::AbstractVariable{Integer}, z::AbstractVariable{T}) where T
        ## Get the solver instance
        solver = Variables.solver(y)

        ## Get the state manager
        sm = stateManager(solver)

        ## Create an active state instance
        active = makeStateRef(sm, true)

        new{T}(solver, array, y, z, active, false)
    end
end


"""
    post(c::Element1DVar)::Nothing  

Function to `post` the `Element1DVar` constraint
"""
function post(c::Element1DVar)::Nothing
    ## Remove irrelevant values from y's domain
    Variables.removeBelow(c.y, 1)
    Variables.removeAbove(c.y, length(c.array))

    ## Ensure Domain Consistency on Post
    ## y is the guiding looping factor
    # yVals = Vector{Integer}()
    # Variables.fillArray(c.y, yVals)

    # for i in yVals
    #     Tᵢ = c.array[i]
    #     tVals = Vector{Integer}()
    #     Variables.fillArray(Tᵢ, tVals)
    #     hasValueInZ = false
    #     for entry in tVals
    #         if in(entry, c.z)
    #             hasValueInZ = true
    #             break
    #         end
    #     end

    #     if !hasValueInZ
    #         Variables.remove(c.y, i)
    #     end
    # end

    # ## Remove values from z that aren't present in array
    # Variables.fillArray(c.y, yVals)

    # zVals = Vector{Integer}()
    # Variables.fillArray(c.z, zVals)

    # for v in zVals
    #     existsInT = false
    #     for i in yVals
    #         if in(v, c.array[i])
    #             existsInT = true
    #             break
    #         end
    #     end

    #     if !existsInT
    #         Variables.remove(c.z, v)
    #     end
    # end

    ## Propagate on domain changes
    propagateOnDomainChange(c.y, c)
    propagateOnBoundChange(c.z, c)

    for variable in c.array
        propagateOnDomainChange(variable, c)
    end

    propagate(c) ## Just in case the domain values may have changed up until now due to the 1st 2 operations
    
    return nothing
end


"""
    propagate(c::Element1DVar)::Nothing

Function to `propagate` the `Element1DVar` constraint
"""
function propagate(c::Element1DVar{T})::Nothing where T
    ## Perform a relaxed domain consistency
    ## Filter from array & z to y
    ## If the intersection between array[i] & z is ∅, remove i from y's domain
    zMax = maximum(c.z)
    zMin = minimum(c.z)

    ## y is the guiding looping factor
    yVals = Vector{Integer}()
    Variables.fillArray(c.y, yVals)

    for i in yVals
        v = c.array[i]
        iMax = maximum(v)
        iMin = minimum(v)
        
        ## No overlap here
        if (zMin > iMax) || (iMin > zMax)
            ## Remove i from y
            Variables.remove(c.y, i)
        end
    end

    ## Filter from array & y to z
    Variables.fillArray(c.y, yVals)

    ## Get the greatest minimum & smallest maximum
    vMin = max(zMin, minimum.([c.array[i] for i in yVals])...)
    vMax = min(zMax, maximum.([c.array[i] for i in yVals])...)
    ## Prune the domain of z again
    Variables.removeBelow(c.z, vMin)
    Variables.removeAbove(c.z, vMax)

    ## The following filter is only possible when y is fixed
    if isFixed(c.y)
        ## Filter from z & y to array
        ## Force c.array[i] == c.z
        Variables.removeAbove(c.array[minimum(c.y)], maximum(c.z))
        Variables.removeBelow(c.array[minimum(c.y)], minimum(c.z))
    end

    return nothing
end


"""
    element1DVar(array::Vector{AbstractVariable{T}}, y::AbstractVariable{T}) where T

Helper function for the `Element1DVar` constraint. It returns an `AbstractVariable{T}` that has the value of the variable indexed at `y`
"""
function element1DVar(array::Vector{AbstractVariable{T}}, y::AbstractVariable{T}) where T
    ## Get the solver instance
    solver = Variables.solver(y)

    ## Get the global minimum & maximum values from variables in array
    ## They will form the range of variables in the domain of z
    globalMax = max(maximum.(array)...)
    globalMin = min(minimum.(array)...)

    ## Create the variable z
    z = Variables.IntVar(solver, globalMin, globalMax)

    ## Post the Element1DVar constraint
    Solver.post(solver, Element1DVar{T}(array, y, z))

    ## Return a z instance
    return z
end