using Parameters
import Base: push!, size, get

"""
State Manager for the stack of constraints.
The `size` state variable is used to resotre the state of constraints to an appropriate level during search
"""
@with_kw mutable struct StateStack{T}
    size::StateInt
    stack::Vector{T}

    function StateStack{T}(sm::StateManager) where T
        size = makeStateInt(sm, 0)
        stack = Vector{T}()

        new(size, stack)
    end
end


"""
    Base.size(s::StateStack)::Integer

Function to get the size of the `StateStack` instance
"""
function Base.size(s::StateStack)::Integer
    return value(s.size)
end


"""
    stack(s::StateStack{T})::Vector{T} where T

Function to get the `stack` of the `StateStack` instance. This is the actual storage vector.
"""
function stack(s::StateStack{T})::Vector{T} where T
    return s.stack
end


"""
    Base.push!(s::StateStack{T}, v::T)::Nothing where T

Function to `push!` elements to the `StateStack` instance
"""
function Base.push!(s::StateStack{T}, v::T)::Nothing where T
    ## Get the current stack size
    sz = size(s)
    ## If the size is less than the current stack size, set the value instead
    if length(stack(s)) > sz 
        stack(s)[sz] = v
    else
        push!(stack(s), v)
    end

    ## Increase the size variable
    increment(s.size)

    return nothing
end


"""
    get(s::StateStack{T}, index::Integer)::T where T

Get the element at index `index` from the `StateStack` index
"""
function Base.get(s::StateStack{T}, index::Integer)::T where T
    return stack(s)[index]
end
