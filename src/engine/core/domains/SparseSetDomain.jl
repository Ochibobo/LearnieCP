using Parameters
import Base: size, minimum, maximum, in

"""
    struct SparseSetDomain{T} <: AbstractDomain{T}
        domain::StateSparseSet{T}

        ## Constructor that allows one to define the minimum and maximum values domain values during initialization
        function SparseSetDomain{T}(sm::StateManager, min::T, max::T) where T
            if(max < min) throw(error("minimum value of min is grater than the defined maximum value of max")) end
            ## Define the domain size
            n = (max - min) + 1
            ## Definition of the domain offset
            offset = min
            ## A new StateSparseSet instance
            domain = StateSparseSet{T}(sm, n, offset)
    
            new(domain)
        end
    end

`SparseSetDomain` is an implementation of the AbstractDomain. The underlying implementation is a 
`StateSparseSet` to allow for the saving and restoration of domain values during search.
"""
@with_kw struct SparseSetDomain{T} <: AbstractDomain{T}
    domain::StateSparseSet{T}

    ## Allow for the initialization of the `StateSparseSet` values during the initialization
    ## of the `SparseSetDomain{T}`
    # function SparseSetDomain{T}(sm::StateManager, n::Integer, offset::Integer) where T
    #     ## Initialize the `StateSparseSet` which is the internal store of this `AbstractDomain` instance
    #     domain = StateSparseSet{T}(sm, n, offset)

    #     new(domain)
    # end

    ## Constructor that allows one to define the minimum and maximum values domain values during initialization
    function SparseSetDomain{T}(sm::StateManager, min::T, max::T) where T
        if(max < min) throw(error("minimum value of $min is grater than the defined maximum value of $max")) end
        ## Define the domain size
        n = (max - min) + 1
        ## Definition of the domain offset
        offset = min
        ## A new StateSparseSet instance
        domain = StateSparseSet{T}(sm, n, offset)

        new(domain)
    end
end


"""
    domain(sd::SparseSetDomain{T})::StateSparseSet{T} where T

Get the underlying domain implementation, a `StateSparseSet{T}`, of the `SparseSetDomain{T}` instance
"""
function domain(sd::SparseSetDomain{T})::StateSparseSet{T} where T
    return sd.domain
end


"""
    Base.minimum(sd::SparseSetDomain{T})::T where T

Get the `minimum` value of the `SparseSetDomain{T}` instance
"""
function Base.minimum(sd::SparseSetDomain{T})::T where T
    return minimum(domain(sd))
end


"""
    Base.maximum(sd::SparseSetDomain{T})::T where T

Get the `maximum` value of the `SparseSetDomain{T}` instance
"""
function Base.maximum(sd::SparseSetDomain{T})::T where T
    return maximum(domain(sd))
end


"""
    Base.size(sd::SparseSetDomain{T})::Integer where T

Get the `size` value of the `SparseSetDomain{T}` instance
"""
function Base.size(sd::SparseSetDomain{T})::Integer where T
    return size(domain(sd))
end


"""
    isBound(sd::SparseSetDomain{T})::Bool where T

Check if the `domain` is currently bound; meaning it contains only one value
"""
function isBound(sd::SparseSetDomain{T})::Bool where T
    return size(sd) == 1
end


"""
    Base.in(v::T, sd::SparseSetDomain{T})::Bool where T

Check if a value `v` of type `T` is n the domain of the `SparseSetDomain{T}` instance
"""
function Base.in(v::T, sd::SparseSetDomain{T})::Bool where T
    return in(v, domain(sd))
end


"""
    remove(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T

Remove the value `v` of type `T` from the `SparseSetDomain{T}` instance
"""
function remove(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T
    ## Check if the value is in the domain before attempting to remove it
    if v in(sd)
        ## Check if the value is equal to the `minimum`, meaning, on Success, the minimum value will be removed
        if minimum(sd) == v onChangeMin(l) end
        ## Check if the value is equal to the `maximum`, meaning, on Success, the minimum value will be removed
        if maximum(sd) == v onChangeMax(l) end
        ## Remove the value from the domain
        remove(domain(sd), v)
        ## Check if the domain is empty now
        if size(sd) == 0
            ## If empty, fire the onEmpty function
            onEmpty(l)
        end
        ## Call the onChange function
        onChange(l)

        ## Check if the domain is bound now
        if isBound(sd)
            ## If so, fire the onBind function
            onBind(l)
        end
    end
    
    return nothing
end


"""
    removeAllBut(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T

Assign a value `v` of type `T` to the `SparseSetDomain{T}` instance
"""
function removeAllBut(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T
    ## Check if the value is in the domain before attempting to remove it
    if v in(sd)
        ## Check if the value is equal to the `minimum`, meaning, on Success, the minimum value will be removed
        if minimum(sd) != v onChangeMin(l) end
        ## Check if the value is equal to the `maximum`, meaning, on Success, the minimum value will be removed
        if maximum(sd) != v onChangeMax(l) end
        ## Fire onChange if the domain size > 1, call the onChange function
        if !isBound(sd) onChange(l) end
        ## Remove the value from the domain
        removeAllBut(domain(sd), v)
        ## Call the onBind function as only `1` value is left
        onBind(l)
    else
        ## Remove all values
        removeAll(domain(sd))
        ## Call the onEmpty function as the domain is now empty
        onEmpty(l)
    end

    return nothing
end


"""
    removeAbove(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T

Remove all values above `v` from the `SparseSetDomain{T}` instance
"""
function removeAbove(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T
    ## If the value is above or equal to the maximum value, do nothing and return
    if v >= maximum(sd)
        return nothing
    end

    ## If the value is above the minimum value
    if v >= minimum(sd)
        ## Check if isBound
        if isBound(sd)
            ## Nothing really changes as min = v = max = only available value
            ## Removing above v does nothing
            return nothing
        end
        ## Remove the actual values above v
        removeAbove(domain(sd), v)

        ## Domain changes as values are removed
        onChange(l)
        ## Max changes as the old max would have been removed
        onChangeMax(l)

        ## Check if the variable is now bound
        if isBound(sd)
            onBind(l)
        end
    else
        ## If the value v is less than the domain's minimum, remove all elements
        removeAll(domain(sd))
        ## Dispatch onEmpty
        onEmpty(l)
    end

    return nothing
end


"""
    removeBelow(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T

Remove all values below `v` from the `SparseSetDomain{T}` instance
"""
function removeBelow(sd::SparseSetDomain{T}, v::T, l::AbstractDomainListener)::Nothing where T
    ## Do nothing if v is less than or equal to the minimum
    if minimum(sd) >= v
        return nothing
    end

    ## Check if v is below or equal to the maximum
    if v <= maximum(sd)
        ## Check if the domain is already bounds
        if isBound(sd)
            ## Nothing changes as max = v = min = only available value
            ## Removing below v does nothing
            return nothing
        end

        ## Perform the actual removal
        removeBelow(domain(sd), v)

        ## Domain has changed
        onChange(l)
        ## Minimum has changed
        onChangeMin(l)

        ## Check if the effect has fixed the domain
        if isBound(sd)
            onBind(l)
        end
    else
        ## If v > max, remove everything
        removeAll(domain(sd))
        ## Dispatch the onEmpty
        onEmpty(l)
    end

    return nothing
end


"""
    fillArray(sd::SparseSetDomain{T}, target::Vector{T})::Nothing where T

Fill the passed array with the domain's values. This ovewrites all elements in the `target` vector.
Pass an empty `target` vector
"""
function fillArray(sd::SparseSetDomain{T}, target::Vector{T})::Nothing where T
    list = collect(domain(sd))
    ## Clear the target vector
    empty!(target)
    
    for i in list
        push!(target, i)
    end

    return nothing
end

