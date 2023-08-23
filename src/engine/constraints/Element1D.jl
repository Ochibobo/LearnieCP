## Element1D Constraint

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
    array::Vector{T}
    y::AbstractVariable{T}
    z::AbstractVariable{T}
    numberOfEntries::Integer

    ## Active and isScheduled fields for all constraints
    active::State
    scheduled::Bool
    
    function Element1D{T}(array::Vector{T}, y::AbstractVariable{T}, z::AbstractVariable{T}) where T
        ## The solver instance
        solver = Variables.solver(y)
        ## State Manager
        sm = stateManager(solver)
        ## Number of elements in the array
        numberOfEntries = length(array)
        
        ## The active state
        active = makeStateRef(sm, true)

        new{T}(solver, array, y, z, numberOfEntries, active, false)
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
    propagateOnDomainChange(c.z, c)

    ## Propagate
    propagate(c)

    return nothing
end


"""
    propagate(c::Element1D)::Nothing

Function to `propagate` the `Element1D` constraint
"""
function propagate(c::Element1D)::Nothing
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
Helper function for the `Element1D` constraint
"""
function element1D(array::Vector{T}, y::AbstractVariable{T})::AbstractVariable{T} where T
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