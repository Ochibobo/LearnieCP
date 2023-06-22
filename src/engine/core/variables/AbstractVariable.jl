import Base: size, minimum, maximum, in

"""
    minimum(d::AbstractVariable{T})::T where T

Return the `minimum` value of the variable
"""
function Base.minimum(d::AbstractVariable{T})::T where T
    throw(error("Variable $(d) does not implement the min function."))
end


"""
    maximum(d::AbstractVariable{T})::T where T

Return the `maximum` value of the variable
"""
function Base.maximum(d::AbstractVariable{T})::T where T
    throw(error("Variable $(d) does not implement the max function."))
end


"""
    size(d::AbstractVariable{T})::Integer where T

Return the `size` value of the variable
"""
function Base.size(d::AbstractVariable{T})::Integer where T
    throw(error("Variable $(d) does not implement the size function."))
end


"""
    isFixed(d::AbstractVariable{T})::Bool where T

Return whether the variable is `bound` or not.
"""
function isFixed(d::AbstractVariable{T})::Bool where T
    throw(error("Variable $(d) does not implement the isBound function."))
end


"""
    in(d::AbstractVariable{T}, value::T)::Bool where T

Return whether a `value` is present in the variable
"""
function Base.in(value::T, d::AbstractVariable{T})::Bool where T
    throw(error("Variable $(d) does not implement the in($d, $value) function."))
end


"""
    remove(d::AbstractVariable{T}, value::T)::Nothing where T

Remove the `value` from Variable `d`
"""
function remove(d::AbstractVariable{T}, value::T)::Nothing where T
    throw(error("Variable $(d) does not implement the remove($d, $value) function."))
end


"""
    fix(d::AbstractVariable{T}, value::T)::Nothing where T

Remove all values apart from `value` from Variable `d`
"""
function fix(d::AbstractVariable{T}, value::T)::Nothing where T
    throw(error("Variable $(d) does not implement the fix($d, $value) function."))
end


"""
    removeBelow(d::AbstractVariable{T}, value::T)::Nothing where T

Remove all values below `value` from the Variable `d`
"""
function removeBelow(d::AbstractVariable{T}, value::T)::Nothing where T
    throw(error("Variable $(d) does not implement the removeBelow($d, $value) function."))
end


"""
    removeAbove(d::AbstractVariable{T}, value::T)::Nothing where T

Remove all values above `value` from the Variable `d`
"""
function removeAbove(d::AbstractVariable{T}, value::T)::Nothing where T
    throw(error("Variable $(d) does not implement the removeAbove($d, $value) function."))
end


"""
    whenFix(d::AbstractVariable{T}, prodecure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(d::AbstractVariable{T}, prodecure::Function)::Nothing where T
    throw(error("Variable $(d) does not implement the whenFix($d, $prodecure) function."))
end


"""
    whenBoundChange(d::AbstractVariable{T}, prodecure::Function)::Nothing where T

`Callback` executed when the domain's bounds (min and max) are changed
"""
function whenBoundChange(d::AbstractVariable{T}, prodecure::Function)::Nothing where T
    throw(error("Variable $(d) does not implement the whenBoundChange($d, $prodecure) function."))
end


"""
    whenDomainChange(d::AbstractVariable{T}, prodecure::Function)::Nothing where T

`Callback` executed when the domain is changed
"""
function whenDomainChange(v::AbstractVariable{T}, prodecure::Function)::Nothing where T
    throw(error("Variable $(v) does not implement the whenDomainChange($v, $prodecure) function."))
end


"""
    propagateOnDomainChange(v::AbstractVariable, c::AbstractConstraint)::Nothing

Function used to propagate a constraint `c` when the domain of variable `v` changes
"""
function propagateOnDomainChange(v::AbstractVariable, c::AbstractConstraint)::Nothing
    throw(error("Variable $(v) does not implement the propagateOnDomainChange($v, $c) function."))
end


"""
    propagateOnBoundChange(V::AbstractVariable, c::AbstractConstraint)::Nothing

Function used to propagate a constraint `c` when the bounds of variable `v` changes
"""
function propagateOnBoundChange(v::AbstractVariable, c::AbstractConstraint)::Nothing
    throw(error("Variable $(v) does not implement the propagateOnBoundChange($v, $c) function."))
end


"""
    propagateOnFix(v::AbstractVariable, c::AbstractConstraint)::Nothing

Function used to propagate a constraint `c` when the variable `v` becomes fixed
"""
function propagateOnFix(v::AbstractVariable, c::AbstractConstraint)::Nothing
    throw(error("Variable $(v) does not implement the propagateOnFix($v, $c) function."))
end


"""
    solver(v::AbstractVariable)::AbstractSolver

Function to get a variable's Solver
"""
function solver(v::AbstractVariable)::AbstractSolver
    throw(error("function solver($v) not implemented"))
end