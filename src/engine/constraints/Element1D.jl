"""
    @with_kw mutable struct Element1D{T} <: AbstractConstraint
        solver::AbstractSolver
        array::Vector{T}
        y::AbstractVariable{T}
        z::AbstractVariable{T}
        numberOfEntries::Integer

        ## Active and isScheduled fields for all constraints
        active::State
        isScheduled::Boolean
        
        function Element1D{T}(array::Vector{T}, y::AbstractVariable{T}, z::AbstractVariable{T}) where T
            ## The solver instance
            solver = Variables.solver(y)
            ## State Manager
            sm = stateManager(sm)
            ## Number of elements in the array
            numberOfEntries = length(array)
            
            ## The active state
            active = makeStateRef(sm, true)

            new{T}(solver, array, y, z, numberOfEntries, active, false)
        end
    end

An array `array` of `T` values indexed by variable `y` ans the value assigned to variable `z`
In other words: `T[y] = z`
"""
@with_kw mutable struct Element1D{T} <: AbstractConstraint
    solver::AbstractSolver
    array::AbstractVector{<:T}
    y::AbstractVariable{T}
    z::AbstractVariable{T}
    numberOfEntries::Integer
    yz::Vector{Pair}
    topPointer::StateInt
    bottomPointer::StateInt

    ## Active and isScheduled fields for all constraints
    active::State
    scheduled::Bool
    
    function Element1D{T}(array::AbstractVector{<:T}, y::AbstractVariable{T}, z::AbstractVariable{T}) where T
        ## The solver instance
        solver = Variables.solver(y)
        ## State Manager
        sm = stateManager(solver)
        ## Number of elements in the array
        numberOfEntries = length(array)

        ## The yz pair
        yz = Vector{Pair}()
        ## Fill in the yz vector
        for (index, element) in enumerate(array)
            push!(yz, index => element)
        end

        ## Sort the yz vector
        sort!(yz, by = k -> k.second)

        ## Initialize the top & bottom pointers
        topPointer = makeStateInt(sm, 1)
        bottomPointer = makeStateInt(sm, numberOfEntries)
        
        ## The active state
        active = makeStateRef(sm, true)

        new{T}(solver, array, y, z, numberOfEntries, yz, topPointer, bottomPointer, active, false)
    end
end

"""
    post(c::Element1D)::Nothing

Function to `post` the `Element1D` constraint
"""
function post(c::Element1D)::Nothing
    ## As y is used for indexing, remove every value below 1 & above numberOfEntries
    Variables.removeBelow(c.y, 1)
    Variables.removeAbove(c.y, c.numberOfEntries)

    ## Propagate the constraint on changes in the domain of y & z
    propagateOnDomainChange(c.y, c)
    propagateOnBoundChange(c.z, c)

    ## Propagate
    propagate(c)

    return nothing
end



"""
    propagate(c::Element1D)::Nothing

Function to `propagate` the `Element1D` constraint
"""
function propagate(c::Element1D)::Nothing
    ## Get the top & bottom pointers
    # l = value(c.topPointer)
    # u = value(c.bottomPointer)

    # ## Get the maximum & minimum value of z
    # zMin = minimum(c.z)
    # zMax = maximum(c.z)

    # ## Prune the space
    # ## Based on the topPointer position
    # while c.yz[l].second < zMin|| !in(c.yz[l].first, c.y)
    #     ## Remove the value from y
    #     Variables.remove(c.y, c.yz[l].first)
    #     l += 1

    #     if l > u throw(DomainError("l > u")) end
    # end

    # ## Based on the bottomPointer position
    # while c.yz[u].second > zMax || !in(c.yz[u].first, c.y)
    #     Variables.remove(c.y, c.yz[u].first)
    #     u -= 1;
    #     if l > u throw(DomainError("l > u")) end
    # end

    # ## Remove values from the domain of z
    # Variables.removeBelow(c.z, c.yz[l].second)
    # Variables.removeAbove(c.z, c.yz[u].second)
    
    # ## Update the pointer values
    # setValue!(c.bottomPointer, u)
    # setValue!(c.topPointer, l)

    # return nothing

    ## Either domain of y or z has changed
    ## Variables in D(y)
    yVars = Vector{Integer}()
    Variables.fillArray(c.y, yVars)
    ## Filter the domain of y
    for v in yVars
        if !in(c.array[v], c.z)
            Variables.remove(c.y, v)
        end
    end

    ## Collect the support values
    supports = Set{Integer}()
    for v in yVars
        push!(supports, c.array[v])
    end

    ## Remove the variables from D(z) whose support is not present
    ## Collect values in D(z)
    zVars = Vector{Integer}()
    Variables.fillArray(c.z, zVars)
    ## Filter D(z)
    for v in zVars
        if !in(v, supports)
            Variables.remove(c.z, v)
        end
    end

    return nothing
end

"""
    element1D(array::AbstractVector{T}, y::AbstractVariable{T})::AbstractVariable{T} where T

Helper function for the `Element1D` constraint
"""
function element1D(array::AbstractVector{<:T}, y::AbstractVariable{T})::AbstractVariable{T} where T
    ## Get a mapping ov the values in the array
    freqMap = Dict{Integer, Integer}()

    for entry in array
        if !haskey(freqMap, entry)
            freqMap[entry] = 1
        else
            freqMap[entry] += 1
        end
    end

    freq_keys = keys(freqMap)
    zMin = minimum(freq_keys)
    zMax = maximum(freq_keys)

    ## Create the variable `z`
    z = Variables.IntVar(Variables.solver(y), zMin, zMax)
    

    ## Remove elements not present in z's domain that have been introduced by the min -> max range
    ## The domain of z may actually contain holes.
    ## For example, the domain of z = [10, 20, 15, 30]
    for entry in zMin:zMax
        !in(entry, freq_keys) && Variables.remove(z, entry)
    end

    ## Post the constraint
    Solver.post(Element1D{T}(array, y, z))

    return z
end

"""
array Tasks = [10, 20, 15, 30]
index_var = IntVar(1, 4)  // Index ranges from 1 to 4
value_var = IntVar()

element_constraint(Tasks, index_var, value_var)

The value_var will take the value of the task duration at the index specified by index_var.


"""


"""
TODO: Implement the sparse domain
"""