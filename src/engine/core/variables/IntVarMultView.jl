using Parameters

"""
    @with_kw struct IntVarMultView <: AbstractVariable{Integer}
        iv::AbstractVariable{Integer}
        coefficient::Integer

        new(iv, coeffecient)        
    end

The `IntVarMultView` struct to hold variables that are combined with coeffecients. The coefficient view of an `IntVar` where
`y = c * x` where `x` is an IntVar and `c` is an integer.
"""
@with_kw struct IntVarMultView <: AbstractVariable{Integer}
    iv::AbstractVariable{Integer}
    coefficient::Integer

    function IntVarMultView(iv::AbstractVariable{Integer}, coefficient::Integer)
        ## Assert the multiplication doesn't exceed the maximum Integer
        if coefficient > 0
            if maximum(iv) >= 0
                if coefficient * BigInt(maximum(iv)) > BigInt(typemax(Int))
                    throw(OverflowError("Multiplying $(coefficient) leads to an overflow error. Consider changing your coefficient value."))
                end

                if coefficient * BigInt(minimum(iv)) < BigInt(typemin(Int))
                    throw(OverflowError("Multiplying $(coefficient) leads to an overflow error. Consider changing your coefficient value."))
                end
            else
                ## If the domain comprises of negative values, check they are not lesser than the smallest in upon multiplying wiht the coeffecient
                ## The || here is complely useless
                if coefficient * BigInt(maximum(iv)) < BigInt(typemin(Int)) || coefficient * BigInt(minimum(iv)) < BigInt(typemin(Int))
                    throw(OverflowError("Multiplying $(coefficient) leads to an overflow error. Consider changing your coefficient value."))
                end
            end
        elseif coefficient < 0
            if maximum(iv) > 0
                ## The || here is complely useless
                if coefficient * BigInt(maximum(iv)) < BigInt(typemin(Int)) || coefficient * BigInt(minimum(iv)) < BigInt(typemin(Int))
                    throw(OverflowError("Multiplying $(coefficient) leads to an overflow error. Consider changing your coefficient value."))
                end
            else
                if coefficient * BigInt(minimum(iv)) > BigInt(typemax(Int))
                    throw(OverflowError("Multiplying $(coefficient) leads to an overflow error. Consider changing your coefficient value."))
                end
            end
        else
            throw(DomainError("Unsupported coeffecient 0 detected. Use non-zero integers as co-efficients."))
        end

        new(iv, coefficient)
    end 
end


"""
    variable(iv::IntVarMultView)::IntVar

Function to retrieve the `AbstractVariable{Integer}` instance of the `IntVarOffsetView` instance
"""
variable(iv::IntVarMultView)::AbstractVariable{Integer} = iv.iv


"""
    coefficient(iv::IntVarOffsetView)::Integer 

Function to return the `coefficient` of the `IntVarMultView` instance
"""
coefficient(iv::IntVarMultView)::Integer = iv.coefficient


"""
    domain(iv::IntVarMultView)::StateSparseSet{Integer}

Function to return the domain of the `IntVarMultView` instance
"""
domain(iv::IntVarMultView)::SparseSetDomain{Integer} = domain(variable(iv))


"""
    solver(iv::IntVarMultView)::AbstractSolver

Function to retrieve the `IntVarMultView` solver
"""
solver(iv::IntVarMultView)::AbstractSolver = solver(variable(iv))


"""
    domainListener(iv::IntVarMultView)::DomainListener 

Get the domain listener of the `IntVarMultView`
"""
domainListener(iv::IntVarMultView)::DomainListener = domainListener(variable(iv))



"""
    onDomainChangeConstraints(iv::IntVarMultView)::Stack{AbstractConstraint}

Get a list of constraints triggered when the domain of this variable changes
"""
onDomainChangeConstraints(iv::IntVarMultView)::StateStack{AbstractConstraint} = onDomainChangeConstraints(variable(iv)).onDomainChangeConstraints



"""
    onBoundsChangeConstraints(iv::IntVarMultView)::Stack{AbstractConstraint}

Get a list of constraints triggered when the bounds of this variable changes
"""
onBoundsChangeConstraints(iv::IntVarMultView)::StateStack{AbstractConstraint} = domainListener(variable(iv)).onBoundsChangeConstraints



"""
    onBindConstraints(iv::IntVarMultView)::Stack{AbstractConstraint}

Get a list of constraints triggered when this variable is bound
"""
onBindConstraints(iv::IntVarMultView)::StateStack{AbstractConstraint} = domainListener(variable(iv)).onBindConstraints


"""
    Base.minimum(iv::IntVarMultView)::Integer

Get the `minimum` value of this variable's domain
"""
function Base.minimum(iv::IntVarMultView)::Integer
    return coefficient(iv) < 0 ? maximum(variable(iv)) * coefficient(iv) :
                minimum(variable(iv)) * coefficient(iv)
end


"""
    Base.maximum(iv::IntVarOffsetView)::Integer

Get the `maximum` value of this variable's domain
"""
function Base.maximum(iv::IntVarMultView)::Integer
    return coefficient(iv) < 0 ? minimum(variable(iv)) * coefficient(iv) :
        maximum(variable(iv)) * coefficient(iv)  
end


"""
    Base.size(iv::IntVarMultView)::Integer

Get the `size` value of this variable's domain
"""
function Base.size(iv::IntVarMultView)::Integer
    size(variable(iv))
end


"""
    isFixed(iv::IntVarMultView)::Integer

Check if this variable's domain is bound
"""
function isFixed(iv::IntVarMultView)::Integer
    isFixed(variable(iv))
end


"""
    Base.in(v::Integer, iv::IntVarMultView)::Bool

Check if value `v` is in the variable's domain
"""
function Base.in(v::Integer, iv::IntVarMultView)::Bool
    return (v % coefficient(iv) != 0) ? false : in(v ÷ coefficient(iv), variable(iv))
end


"""
    remove(iv::IntVarMultView, v::Integer)::Nothing

Function to remove an element from the variable's domain
"""
function remove(iv::IntVarMultView, v::Integer)::Nothing
    if v % coefficient(iv) == 0
        remove(variable(iv), v - coefficient(iv))
    end
end


"""
    fix(iv::IntVarMultView, v::Integer)::Nothing

Function to assign a value to a variable. Notice that this value oughts to be present in the variable's domain
"""
function fix(iv::IntVarMultView, v::Integer)::Nothing
    if(v % coefficient(iv) == 0)
        fix(variable(iv), v ÷ coefficient(iv))
    else
        throw(DomainError("$v not divisible by the coeffecient"))
    end
end


"""
    removeAbove(iv::IntVarMultView, v::Integer)::Nothing

Function to remove all values above a certain value in the variable's domain
"""
function removeAbove(iv::IntVarMultView, v::Integer)::Nothing
    ## Handle negative coefficients
    if coefficient(iv) < 0
        removeBelow(variable(iv), Int(ceil(v / coefficient(iv))))
        return nothing
    end

    ## Handle -ve v
    if v < 0
        removeAbove(variable(iv), v ÷ coefficient(iv))
        return nothing
    end

    ## Remove all values above the ceiling of the division
    removeAbove(variable(iv), Int(floor(v / coefficient(iv))))
end


"""
    removeBelow(iv::IntVarMultView, v::Integer)::Nothing

Function to remove all values below a certain value in the variable's domain
"""
function removeBelow(iv::IntVarMultView, v::Integer)::Nothing
    ## Handle negative co-efficients
    if coefficient(iv) < 0
        removeAbove(variable(iv), Int(floor(v / coefficient(iv))))
        return nothing
    end

    ## Handle -ve v
    if v < 0
        removeBelow(variable(iv), v ÷ coefficient(iv))
    end
    ## Remove all values below the floor
    removeBelow(variable(iv), Int(ceil(v / coefficient(iv))))
end


"""
    propagateOnDomainChange(iv::IntVarMultView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the domain of the variable changes
"""
function propagateOnDomainChange(iv::IntVarMultView, c::AbstractConstraint)::Nothing
    propagateOnDomainChange(variable(iv), c)
end


"""
    propagateOnBoundsChange(iv::IntVarMultView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the bounds of the variable changes
"""
function propagateOnBoundChange(iv::IntVarMultView, c::AbstractConstraint)::Nothing
    propagateOnBoundChange(variable(iv), c)
end


"""
    propagateOnFix(iv::IntVarMultView, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the vraribale becomes bound
"""
function propagateOnFix(iv::IntVarMultView, c::AbstractConstraint)::Nothing
    propagateOnFix(variable(iv), c)
end


"""
    whenFix(d::IntVarMultView, procedure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(iv::IntVarMultView, procedure::Function)::Nothing
    whenFix(variable(iv), procedure)
end


"""
    whenBoundChange(iv::IntVarMultView, procedure::Function)::Nothing where T

`Callback` executed when the domain's bounds (min and max) are changed
"""
function whenBoundChange(iv::IntVarMultView, procedure::Function)::Nothing
    whenBoundChange(variable(iv), procedure)
end


"""
    whenDomainChange(iv::IntVarMultView, procedure::Function)::Nothing where T

`Callback` executed when the domain is changed
"""
function whenDomainChange(iv::IntVarMultView, procedure::Function)::Nothing
    whenDomainChange(variable(iv), procedure)
end


"""
    fillArray(iv::IntVarMultView, target::Vector{T})::Vector{T} where T

Function to fill the `target` array with values from the variable's domain
"""
function fillArray(iv::IntVarMultView, target::Vector{T})::Vector{T} where T
    fillArray(variable(iv), target)

    for i in eachindex(target)
        target[i] *= coefficient(iv)
    end

    return target
end


"""
    Base.:-(iv::AbstractVariable{Integer}) = IntVarMultView(iv, -1)

Overriding the `*` symbol to allow for an alternative creation of the `IntVarMultView` for a negative number
"""
Base.:-(iv::AbstractVariable{Integer}) = IntVarMultView(iv = iv, coefficient = -1)


"""
    Base.:-(iv::AbstractVariable{Integer}, coefficient::Integer)

Overriding the `*` symbol to allow for an alternative creation of the `IntVarMultView` based on multiplication
"""
Base.:*(iv::AbstractVariable{Integer}, coefficient::Integer) = coefficient == 0 ? IntVar(solver(iv), 0, 0) : IntVarMultView(iv = iv, coefficient = coefficient)


"""
    Base.:*(coefficient::Integer, iv::AbstractVariable{Integer})

Overriding the `*` symbol to allow for an alternative creation of the `IntVarMultView` based on multiplication
"""
Base.:*(coefficient::Integer, iv::AbstractVariable{Integer}) = coefficient == 0 ? IntVar(solver(iv), 0, 0) : IntVarMultView(iv = iv, coefficient = coefficient)


