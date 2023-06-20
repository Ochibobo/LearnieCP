using Parameters
import Base: isempty, size, minimum, maximum, collect, in, values

"""
    struct StateSparseSet{T}
        values::Vector{T}
        index::Vector{Integer}
        sm::StateManager
        size::StateInt
        max::State{T}
        min::State{T}
        offset::Integer ## Not all domains will begin from 1
        n::Integer      ## Domain Size

        ## Custom constructor
        function StateSparseSet{T}(sm::StateManager, n::Integer, offset::Integer)
            ## The domain size is stored as a state variable
            size = makeStateInt(sm, n)
            ## The minimum is stored as a state variable 
            min = makeStateInt(sm, 1)
            ## The maximum is stored as a state variable
            max = makeStateInt(sm, n)
            ## Values is an array of n elements
            values = zeros(T, n)
            ## Index is an array of n elements too
            index = zeros(Integer, n)
            
            ## Fill the values and indexes with numbers
            for i in 1:n
                values[i] = i
                index[i] = i
            end

            new(values = values, index = index, sm = sm, size = size, min = min, max = max, offset = offset, n = n)
        end
    end

Actual implementation of the `SparseSet` structure used to store operate on stored values
It can be saved and restored throught `saveState(sm)` & `restoreState(sm)` of an instance of `StateManager`
"""
@with_kw struct StateSparseSet{T}
    values::Vector{T}
    index::Vector{Integer}
    sm::StateManager
    size::StateInt
    max::State{T}
    min::State{T}
    offset::Integer ## Not all domains will begin from 1
    n::Integer      ## Domain Size

    ## Custom constructor
    function StateSparseSet{T}(sm::StateManager, n::Integer, offset::Integer) where T
        ## The domain size is stored as a state variable
        size = makeStateInt(sm, n)
        ## The minimum is stored as a state variable
        min = makeStateInt(sm, 0)
        ## The maximum is stored as a state variable
        max = makeStateInt(sm, n - 1)
        ## Values is an array of n elements
        values = zeros(T, n)
        ## Index is an array of n elements too
        index = zeros(Integer, n)
        
        ## Fill the values and indexes with numbers
        for i in 1:n
            ## `1` is subtracted from `i` to store values from `0` in the `values` vector.
            values[i] = i - 1
            index[i] = i
        end

        new{T}(values, index, sm, size, max, min, offset, n)
    end
end


"""
As `julia` has 1-based indices, the index of a value is calculated by adding 1 to it. 
This allows for our `values` vector to hold values from 0 to n - 1. 

This function is used to create an index of a value `v`.
"""
function indexOf(v::Integer)::Integer
    return v + 1
end


"""
    values(ss:StateSparseSet{T})::Vector{T} where T

Return the `values` vector of the `StateSparseSet{T}` instance
"""
function Base.values(ss::StateSparseSet{T})::Vector{T} where T
    return ss.values
end


"""
Return the `index` vector of the `StateSparseSet{T}` instance
"""
function index(ss::StateSparseSet{T})::Vector{Integer} where T
    return ss.index
end


"""
    Base.size(sd::StateSparseSet)

Get the `size` of the `StateSparseSet{T}` instance
"""
function Base.size(ss::StateSparseSet{T})::Integer where T
    return value(ss.size)
end


"""
    Base.isempty(sd::StateSparseSet)

Check if the `StateSpartSet{T}` instance is `emtpy`
"""
Base.isempty(ss::StateSparseSet) = size(ss) == 0


"""
    Base.in(v::T, ss::StateSparseSet{T})::Bool where T

Check if value is `in` the `values` vector of the `StateSparseSet{T}` instance
"""
function Base.in(v::T, ss::StateSparseSet{T})::Bool where T
    v -= offset(ss)

    ## Don't use size(ss) to test the bounds as size(ss) changes
    if v < 0  || v >= ss.n return false end

    return index(ss)[indexOf(v)] < size(ss)
end


"""
    offset(ss::StateSparseSet{T})::Integer where T

Get the `offset` of the domain values of the `StateSparseSet{T}` instance
"""
function offset(ss::StateSparseSet{T})::Integer where T
    return ss.offset
end


"""
    Base.minimum(ss::StateSparseSet{T})::T where T

Get the `minimum` value of the `StateSparseSet{T}` instance
"""
function Base.minimum(ss::StateSparseSet{T})::T where T
    if isempty(ss)
        throw(error("NoSuchElement::DomainError"))
    end

    return value(ss.min) + offset(ss)
end


"""
    Base.maximum(ss::StateSparseSet{T})::T where T

Get the `maximum` of the value of the `StateSparseSet{T}` instance
"""
function Base.maximum(ss::StateSparseSet{T})::T where T
    if isempty(ss)
        throw(error("NoSuchElement::DomainError"))
    end

    return value(ss.max) + offset(ss)
end


"""
    Base.collect(ss::StateSparseSet{T})::Vector{T} where T

Collect the `values` of the `StateSparseSet{T}` instance
"""
function Base.collect(ss::StateSparseSet{T})::Vector{T} where T
    sz = size(ss)
    v = Vector{T}(undef, sz)
    
    for i in 1:sz
        v[i] = values(ss)[i] + offset(ss)
    end

    return v
end


"""
    swap(ss::StateSparseSet{T}, v1::T, v2::T)::Nothing where T

Function to `swap` elements in the `values` and `index` vectors
"""
function swap!(ss::StateSparseSet{T}, v1::T, v2::T)::Nothing where T
    ## Assert both the values are less than or equal to the size
    ## The Java guys compare this to the values array - this doesn't make sense
    v1 >= ss.n && throw(error("value $v1 not in the values set of the StateSparseSet"))
    v2 >= ss.n && throw(error("value $v2 not in the values set of the StateSparseSet"))

    ## Retrieve their indices
    idx1 = index(ss)[indexOf(v1)]
    idx2 = index(ss)[indexOf(v2)]


    ## Swap the values
    temp = values(ss)[idx1]
    values(ss)[idx1] = values(ss)[idx2]
    values(ss)[idx2] = temp

    ## Swap the index values
    index(ss)[indexOf(v1)] = idx2
    index(ss)[indexOf(v2)] = idx1

    return nothing
end


"""
    internalContains(ss::StateSparseSet{T}, v::T)::Bool where T

Operates on the shifted value `v`. Checks if the value `v` is present in the domain.
"""
function internalContains(ss::StateSparseSet{T}, v::T)::Bool where T
    ## Bounds are checked against n and not size(ss)
    if v < 0  || v >= ss.n return false end

    return index(ss)[indexOf(v)] < size(ss)
end


"""
    updateMinValueOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T

Update the `min` value if the minimum was removed
"""
function updateMinValueOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T
    ## Work with ss.min as it bears no offset; don't use minimum(ss) this contains an offset.
    ## At this stage, v = (original_v - offset)
    if !isempty(ss) && value(ss.min) == v
        ## Update the minimum if it is absent
        if !internalContains(ss, v)
            ## Search for the new minimum
            ## Loop through all values between minimum + 1 to the maximum value
            ## Set the first value to be encountered as the new minimum as the values are checked from 
            ## the initial (minimum + 1)...maximum, taking 1 step.
            for val in (v + 1):value(ss.max)
                if(internalContains(ss, val))
                    setValue!(ss.min, val)
                    return
                end
            end
        end
    end

    return nothing
end


"""
    updateMaxValueOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T

Update the `max` value if the maximum was removed
"""
function updateMaxValueOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T
    if !isempty(ss) && value(ss.max) == v
        ## Update the max value if the original max was removed
        if !internalContains(ss, v)
            ## Search for the new maximum
            ## Loop through all values from max - 1 to min 
            ## Set the first value to be encountered as the new maximum as the values are checked from 
            ## the initial (maximum - 1)...min, taking -1 steps.
            for val in (v - 1):-1:value(ss.min)
                if(internalContains(ss, val))
                    setValue!(ss.max, val)
                    return
                end
            end
        end
    end

    return nothing
end


"""
    updateBoundsOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T

Update the `bounds` of the `values` on change
"""
function updateBoundsOnRemove(ss::StateSparseSet{T}, v::T)::Nothing where T
    updateMinValueOnRemove(ss, v)    
    updateMaxValueOnRemove(ss, v)
end


"""
    remove(ss::StateSparseSet{T}, v::T)::Nothing where T

Function to `remove` and element from the `values` vector
"""
function remove(ss::StateSparseSet{T}, v::T)::Nothing where T
    if !(in(v, ss))
        throw(error("value $v not in the values set of the StateSparseSet")) ## v may have already been removed
    end

    v -= offset(ss)

    v >= ss.n && throw(error("value $(v + offset(ss)) not in the values set of the StateSparseSet"))

    ## Remove the value by swapping it with the value at the last position
    swap!(ss, v, values(ss)[size(ss)])

    ## Decrease the size by 1
    decrement(ss.size)

    ## Update the bounds on change
    updateBoundsOnRemove(ss, v)

    return nothing
end


"""
    removeAllBut(ss::StateSparseSet{T}, v::T)::Nothing where T

Remove all elements from the `values` vector but `v`
"""
function removeAllBut(ss::StateSparseSet{T}, v::T)::Nothing where T
    ## Confirm that value v is present
    if !in(v, ss)
        throw(error("Value $v not present in the values vector of the StateSparseSet"))
    end

    v -= offset(ss)

    v >= ss.n && throw(error("Value $(v + offset(ss)) not present in the values vector of the StateSparseSet"))

    ## Swap with element at index `1`
    swap!(ss, values(ss)[1], v)

    ## Set the minimum to value at 1
    setValue!(ss.min, v)

    ## Set the maximum to value at 1
    setValue!(ss.max, v)

    ## Set the size to 1
    setValue!(ss.size, 1)

    return nothing
end


"""
    removeAll(ss::StateSparseSet{T})::Nothing where T

Remove all elements from the `values` vector of the `StateSparseSet{T}` instance
"""
function removeAll(ss::StateSparseSet{T})::Nothing where T
    setValue!(ss.size, 0)

    return nothing
end


"""
    removeBelow(ss:StateSparseSet{T}, v::T)::Nothing where T

Remove all values less than `v` from the `values` vector of the `StateSparseSet{T}` instance
"""
function removeBelow(ss::StateSparseSet{T}, v::T)::Nothing where T
    if(maximum(ss) < v)
        ## Remove all if v is greater than the max value
        removeAll(ss)
    else
        ## Remove elements that meet the threshold
        for val in minimum(ss):(v - 1)
            remove(ss, val)
        end
    end

    return nothing
end


"""
    removeAbove(ss::StateSparseSet{T}, v::T)::Nothing where T

Remove all values greater than `v` from the `values` vector of the `StateSparseSet{T}` instance
"""
function removeAbove(ss::StateSparseSet{T}, v::T)::Nothing where T
    if(minimum(ss) > v)
        ## Remove all if minimum is greater than v
        removeAll(ss)
    else
        ## Remove only elements above `v`
        for val in maximum(ss):-1:(v + 1)
            remove(ss, val)
        end
    end

    return nothing
end
