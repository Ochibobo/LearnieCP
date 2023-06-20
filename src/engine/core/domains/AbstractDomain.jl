import Base: size, minimum, maximum, in

"""
Implementation of an AbstractDomain
"""

"""
    abstract type AbstractDomain{T} end

`Interface` definition of a domain. All domains should implement this Interface
"""
abstract type AbstractDomain{T} end


"""
    minimum(d::AbstractDomain{T})::T where T

Return the `minimum` value of the domain
"""
function Base.minimum(d::AbstractDomain{T})::T where T
    throw(error("Domain $(d) does not implement the min function."))
end


"""
    maximum(d::AbstractDomain{T})::T where T

Return the `maximum` value of the domain
"""
function Base.maximum(d::AbstractDomain{T})::T where T
    throw(error("Domain $(d) does not implement the max function."))
end


"""
    size(d::AbstractDomain{T})::Integer where T

Return the `size` value of the domain
"""
function Base.size(d::AbstractDomain{T})::Integer where T
    throw(error("Domain $(d) does not implement the size function."))
end


"""
    isBound(d::AbstractDomain{T})::Bool where T

Return whether the domain is `bound` or not.
"""
function isBound(d::AbstractDomain{T})::Bool where T
    throw(error("Domain $(d) does not implement the isBound function."))
end


"""
    in(d::AbstractDomain{T}, value::T)::Bool where T

Return whether a `value` is present in the domain
"""
function in(value::T, d::AbstractDomain{T})::Bool where T
    throw(error("Domain $(d) does not implement the in($d, $value) function."))
end


"""
    remove!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove the `value` from domain `d`
"""
function remove(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the remove!($d, $value, $listener) function."))
end


"""
    removeAllBut!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove all values apart from `value` from domain `d`
"""
function removeAllBut(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the removeAllBut!($d, $value, $listener) function."))
end


"""
    removeBelow!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove all values below `value` from the domain `d`
"""
function removeBelow(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the removeBelow!($d, $value, $listener) function."))
end


"""
    removeAbove!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove all values above `value` from the domain `d`
"""
function removeAbove(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the removeAbove!($d, $value, $listener) function."))
end


"""
    removeBelowInclusive!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove all values below and including `value` from the domain `d`
"""
function removeBelowInclusive(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the removeBelowInclusive!($d, $value, $listener) function."))
end


"""
    removeAboveInclusive!(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T

Remove all values above and including `value` from the domain `d`
"""
function removeAboveInclusive(d::AbstractDomain{T}, value::T, listener::AbstractDomainListener)::Nothing where T
    throw(error("Domain $(d) does not implement the removeAboveInclusive!($d, $value, $listener) function."))
end


"""
    fillArray!(d::AbstractDomain{T}, destination::Vector{T})::Nothing where T

Fill the `target` vector with the values from domain `d`. This updated the `destination` vector
"""
function fillArray(d::AbstractDomain{T}, destination::Vector{T})::Nothing where T
    throw(error("Domain $(d) does not implement the fillArray!($d, $destination) function."))
end

