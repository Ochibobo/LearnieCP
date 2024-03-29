using Parameters
import ..Domains: offset

"""
    @with_kw struct IntVarOffsetView <: AbstractVariable{Integer}
        iv::IntVar
        offset::Integer
    end

The `IntVarOffsetView` struct to hold variables that are combined with offsets. The offset view of an `IntVar` where
`y = x + o` or `y = x - o` where `x` is an IntVar and `o` is an integer.
"""
@with_kw struct IntVarOffsetView <: AbstractVariable{Integer}
    iv::AbstractVariable{Integer}
    offset::Integer

    function IntVarOffsetView(iv::AbstractVariable{Integer}, offset::Integer)
        ## Assert that adding the offset to the variable's max does not result in an overflow error
        if maximum(iv) + offset == typemin(Int) + (maximum(iv)  - 1)
            throw(OverflowError("Adding $(offset) leads to an overflow error. Consider changing your offset value."))
        end
        ## Asset that adding the offset to the variable's minimum value does not result in an overflow
        ## Works then the offset is negative
        if minimum(iv) + offset == typemax(Int) - (minimum(iv)  + 1)
            throw(OverflowError("Adding $(offset) leads to an overflow error. Consider changing your offset value."))
        end

        new(iv, offset)
    end
end


"""
    variable(iv::IntVarOffsetView)::IntVar

Function to retrieve the `AbstractVariable{Integer}` instance of the `IntVarOffsetView` instance
"""
variable(iv::IntVarOffsetView)::AbstractVariable{Integer} = iv.iv


"""
    offset(iv::IntVarOffsetView)::Integer 

Function to return the `offset` of the `IntVarOffsetView` instance
"""
offset(iv::IntVarOffsetView)::Integer = iv.offset


"""
    domain(iv::IntVarOffsetView)::StateSparseSet{Integer}

Function to return the domain of the `IntVarOffsetView` instance
"""
domain(iv::IntVarOffsetView)::SparseSetDomain{Integer} = domain(variable(iv))


"""
    solver(iv::IntVarOffsetView)::AbstractSolver

Function to retrieve the `IntVarOffsetView` solver
"""
solver(iv::IntVarOffsetView)::AbstractSolver = solver(variable(iv))


"""
    domainListener(iv::IntVarOffsetView)::DomainListener 

Get the domain listener of the `IntVarOffsetView`
"""
domainListener(iv::IntVarOffsetView)::DomainListener = domainListener(variable(iv))


"""
    onDomainChangeConstraints(iv::IntVarOffsetView)::Stack{AbstractConstraint}

Get a list of constraints triggered when the domain of this variable changes
"""
onDomainChangeConstraints(iv::IntVarOffsetView)::StateStack{AbstractConstraint} = domainListener(variable(iv)).onDomainChangeConstraints


"""
    onBoundsChangeConstraints(iv::IntVarOffsetView)::Stack{AbstractConstraint}

Get a list of constraints triggered when the bounds of this variable changes
"""
onBoundsChangeConstraints(iv::IntVarOffsetView)::StateStack{AbstractConstraint} = domainListener(variable(iv)).onBoundsChangeConstraints


"""
    onBindConstraints(iv::IntVarOffsetView)::Stack{AbstractConstraint}

Get a list of constraints triggered when this variable is bound
"""
onBindConstraints(iv::IntVarOffsetView)::StateStack{AbstractConstraint} = domainListener(variable(iv)).onBindConstraints


"""
    Base.minimum(iv::IntVarOffsetView)::Integer

Get the `minimum` value of this variable's domain
"""
function Base.minimum(iv::IntVarOffsetView)::Integer
    return minimum(variable(iv)) + offset(iv)
end


"""
    Base.maximum(iv::IntVarOffsetView)::Integer

Get the `maximum` value of this variable's domain
"""
function Base.maximum(iv::IntVarOffsetView)::Integer
    maximum(variable(iv)) + offset(iv)  
end


"""
    Base.size(iv::IntVarOffsetView)::Integer

Get the `size` value of this variable's domain
"""
function Base.size(iv::IntVarOffsetView)::Integer
    size(variable(iv))
end


"""
    isFixed(iv::IntVarOffsetView)::Integer

Check if this variable's domain is bound
"""
function isFixed(iv::IntVarOffsetView)::Integer
    isFixed(variable(iv))
end


"""
    Base.in(v::Integer, iv::IntVarOffsetView)::Bool

Check if value `v` is in the variable's domain
"""
function Base.in(v::Integer, iv::IntVarOffsetView)::Bool
    in(v - offset(iv), variable(iv))
end


"""
    remove(iv::IntVarOffsetView, v::Integer)::Nothing

Function to remove an element from the variable's domain
"""
function remove(iv::IntVarOffsetView, v::Integer)::Nothing
    remove(variable(iv), v - offset(iv))
end


"""
    fix(iv::IntVarOffsetView, v::Integer)::Nothing

Function to assign a value to a variable. Notice that this value oughts to be present in the variable's domain
"""
function fix(iv::IntVarOffsetView, v::Integer)::Nothing
    fix(variable(iv), v - offset(iv))
end


"""
    removeAbove(iv::IntVarOffsetView, v::Integer)::Nothing

Function to remove all values above a certain value in the variable's domain
"""
function removeAbove(iv::IntVarOffsetView, v::Integer)::Nothing
    removeAbove(variable(iv), v - offset(iv))
end


"""
    removeBelow(iv::IntVarOffsetView, v::Integer)::Nothing

Function to remove all values below a certain value in the variable's domain
"""
function removeBelow(iv::IntVarOffsetView, v::Integer)::Nothing
    removeBelow(variable(iv), v - offset(iv))
end


"""
    propagateOnDomainChange(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the domain of the variable changes
"""
function propagateOnDomainChange(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing
    propagateOnDomainChange(variable(iv), c)
end


"""
    propagateOnBoundsChange(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the bounds of the variable changes
"""
function propagateOnBoundChange(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing
    propagateOnBoundChange(variable(iv), c)
end


"""
    propagateOnFix(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the vraribale becomes bound
"""
function propagateOnFix(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing
    propagateOnFix(variable(iv), c)
end


"""
    whenFix(d::IntVarOffsetView, procedure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(iv::IntVarOffsetView, procedure::Function)::Nothing
    whenFix(variable(iv), procedure)
end


"""
    whenBoundChange(iv::IntVarOffsetView, procedure::Function)::Nothing where T

`Callback` executed when the domain's bounds (min and max) are changed
"""
function whenBoundChange(iv::IntVarOffsetView, procedure::Function)::Nothing
    whenBoundChange(variable(iv), procedure)
end


"""
    whenDomainChange(iv::IntVarOffsetView, procedure::Function)::Nothing where T

`Callback` executed when the domain is changed
"""
function whenDomainChange(iv::IntVarOffsetView, procedure::Function)::Nothing
    whenDomainChange(variable(iv), procedure)
end


"""
    fillArray(iv::IntVarOffsetView, target::Vector{T})::Vector{T} where T

Function to fill the `target` array with values from the variable's domain
"""
function fillArray(iv::IntVarOffsetView, target::Vector{T})::Vector{T} where T
    fillArray(variable(iv), target)

    for i in eachindex(target)
        target[i] += offset(iv)
    end

    return target
end


"""
    Base.:+(offset::Integer, iv::AbstractVariable{Integer})

Overriding the `+` symbol to allow for an alternative creation of the `IntVarOffsetView`
"""
Base.:+(offset::Integer, iv::AbstractVariable{Integer}) = IntVarOffsetView(iv = iv, offset = offset)


"""
    Base.:+(iv::AbstractVariable{Integer}, offset::Integer)

Overriding the `+` symbol to allow for an alternative creation of the `IntVarOffsetView`
"""
Base.:+(iv::AbstractVariable{Integer}, offset::Integer) = IntVarOffsetView(iv = iv, offset = offset)


"""
    Base.:-(iv::AbstractVariable{Integer}, offset::Integer)

Overriding the `-` operator to allow for an alternative creation of the `IntVarOffsetView`. Replaces `offset` with `-offset`
"""
Base.:-(iv::AbstractVariable{Integer}, offset::Integer) = IntVarOffsetView(iv = iv, offset = -offset)


"""
    Base.:-(offset::Integer, iv::AbstractVariable{Integer})

Overriding the `-` operator to allow for an alternative creation of the `IntVarOffsetView`. Replaces `offset` with `-offset`
"""
Base.:-(offset::Integer, iv::AbstractVariable{Integer}) = IntVarOffsetView(iv = -iv, offset = offset)