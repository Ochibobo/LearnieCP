using Parameters
import ..Domains: offset
"""
The offset view of an IntVar where:
y = x + o or y = x - o
where x is an IntVar and o is an integer.
"""

"""
    @with_kw struct IntVarOffsetView <: AbstractVariable{Integer}
        iv::IntVar
        offset::Integer

        function IntVarOffsetView(iv::IntVar, offset::Integer)
            if maximum(iv) + offset == typemin(Int) + (offset - 1)
                throw(OverflowError("Adding $(offset) leads to an overflow error"))
            end

            if minimum(iv) + offset == typemax(Int) - (offset + 1)
                throw(OverflowError("Adding $(offset) leads to an overflow error"))
            end
    
            new(iv, offset)
        end
    end

The `IntVarOffsetView` struct to hold variables that are combined with offsets
"""
@with_kw struct IntVarOffsetView <: AbstractVariable{Integer}
    iv::IntVar
    offset::Integer

    function IntVarOffsetView(iv::IntVar, offset::Integer)
        ## Assert that adding the offset to the variable's max does not result in an overflow error
        if maximum(iv) + offset == typemin(Int) + (offset - 1)
            throw(OverflowError("Adding $(offset) leads to an overflow error"))
        end
        ## Asset that adding the offset to the variable's minimum value does not result in an overflow
        ## Works then the offset is negative
        if minimum(iv) + offset == typemax(Int) - (offset + 1)
            throw(OverflowError("Adding $(offset) leads to an overflow error"))
        end

        new(iv, offset)
    end
end


"""
    variable(iv::IntVarOffsetView)::IntVar

Function to retrieve the `IntVar` instance of the `IntVarOffsetView` instance
"""
variable(iv::IntVarOffsetView)::IntVar = iv.iv


"""
    offset(iv::IntVarOffsetView)::Integer 

Function to return the `offset` of the `IntVarOffsetView` instance
"""
offset(iv::IntVarOffsetView)::Integer = iv.offset


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
onDomainChangeConstraints(iv::IntVarOffsetView)::StateStack{AbstractConstraint} = onDomainChangeConstraints(variable(iv)).onDomainChangeConstraints


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
    return dm.minimum(domain(variable(iv))) + offset(iv)
end


"""
    Base.maximum(iv::IntVarOffsetView)::Integer

Get the `maximum` value of this variable's domain
"""
function Base.maximum(iv::IntVarOffsetView)::Integer
    dm.maximum(domain(variable(iv))) + offset(iv)  
end


"""
    Base.size(iv::IntVarOffsetView)::Integer

Get the `size` value of this variable's domain
"""
function Base.size(iv::IntVarOffsetView)::Integer
    dm.size(domain(variable(iv)))
end


"""
    isFixed(iv::IntVarOffsetView)::Integer

Check if this variable's domain is bound
"""
function isFixed(iv::IntVarOffsetView)::Integer
    dm.isBound(domain(variable(iv)))
end


"""
    Base.in(v::Integer, iv::IntVarOffsetView)::Bool

Check if value `v` is in the variable's domain
"""
function Base.in(v::Integer, iv::IntVarOffsetView)::Bool
    dm.in(v - offset(iv), domain(variable(iv)))
end


"""
    remove(iv::IntVarOffsetView, v::Integer)::Nothing

Function to remove an element from the variable's domain
"""
function remove(iv::IntVarOffsetView, v::Integer)::Nothing
    remove(variable(iv), v - offset(v))
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
function propagateOnBoundsChange(iv::IntVarOffsetView, c::AbstractConstraint)::Nothing
    propagateOnBoundsChange(variable(iv), c)
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
    _target = Vector{T}(undef, size(variable(iv)))

    for i in eachindex(target)
        _target[i] = target[i] + offset(iv)
    end

    return _target
end
