using Parameters
import Lazy: @forward

"""
    @with_kw struct BoolVar <: AbstractVariable{Integer}
        binaryVar::IntVar
    
        function BoolVar(variable::IntVar)
            new(variable)
        end

        function BoolVar(solver::AbstractSolver)
            binaryVar = IntVar(solver, 0, 1)
            new(binaryVar)
        end
    end

`BoolVar` is an implementation of a boolean variable
"""
@with_kw struct BoolVar <: AbstractVariable{Integer}
    binaryVar::AbstractVariable{Integer}

    function BoolVar(variable::AbstractVariable{Integer})
        new(variable)
    end

    ## Can create a Boolean Variable directly from the solver
    function BoolVar(solver::AbstractSolver)
        binaryVar = IntVar(solver, 0, 1)
        new(binaryVar)
    end
end


"""
    variable(b::BoolVar)::AbstractVariable{Integer}

Function to get the `IntVar` variable instance underlying the boolean variable
"""
variable(b::BoolVar)::AbstractVariable{Integer} = b.binaryVar


"""
    isTrue(b::BoolVar)::Boolean

Function to check if the boolean variable is true
"""
function isTrue(b::BoolVar)::Bool
    return minimum(b) == 1
end


"""
    isFalse(b::BoolVar)::Bool

Function to check if the boolean variable is false
"""
function isFalse(b::BoolVar)::Bool
    return maximum(b) == 0
end


"""
    fix(b::BoolVar, value::Bool)::Nothing

Function to `fix` the value of the `BoolVar` instance
"""
function fix(b::BoolVar, value::Integer)::Nothing
    fix(variable(b), value == 1)

    return nothing
end


"""
    remove(iv::BoolVar, v::Integer)::Nothing

Function to remove an element from the variable's domain
"""
function remove(b::BoolVar, v::Integer)::Nothing
    (v < 0 || v > 1) && throw(DomainError("Value $v is out of the range of boolean values. Accepted range is [0, 1]"))
    remove(variable(b), v)

    return nothing
end


"""
    removeAbove(b::BoolVar, v::Integer)::Nothing

Function to remove all values above a certain value in the variable's domain
"""
function removeAbove(b::BoolVar, v::Integer)::Nothing
    removeAbove(variable(b), v)
    return nothing
end


"""
    removeBelow(b::BoolVar, v::Integer)::Nothing

Function to remove all values below a certain value in the variable's domain
"""
function removeBelow(b::BoolVar, v::Integer)::Nothing
    removeBelow(variable(b), v)
    return nothing
end


"""
    propagateOnFix(b::BoolVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the varibale becomes bound
"""
function propagateOnFix(b::BoolVar, c::AbstractConstraint)::Nothing
    propagateOnFix(variable(b), c)
    return nothing
end


"""
    propagateOnBoundsChange(b::BoolVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the bounds of the variable changes
"""
function propagateOnBoundChange(b::BoolVar, c::AbstractConstraint)::Nothing
    propagateOnBoundChange(variable(b), c)
    return nothing
end


"""
    propagateOnDomainChange(b::BoolVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the domain of the variable changes
"""
function propagateOnDomainChange(b::BoolVar, c::AbstractConstraint)::Nothing
    propagateOnDomainChange(variable(b), c)

    return nothing
end


"""
    constraintClosure(b::BoolVar, fn::Function)::AbstractConstraint

An instance of `ConstraintClosure` used to create anonymous constraints
"""
function constraintClosure(b::BoolVar, fn::Function)::AbstractConstraint
    c = constraintClosure(variable(b), fn)

    return c
end


"""
    whenFix(b::BoolVar, procedure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(b::BoolVar, procedure::Function)::Nothing
    whenFix(variable(b), procedure)

    return nothing
end


"""
    whenBoundChange(b::BoolVar, procedure::Function)::Nothing where T

`Callback` executed when the domain's bounds (min and max) are changed
"""
function whenBoundChange(b::BoolVar, procedure::Function)::Nothing
    whenBoundChange(variable(b), procedure)

    return nothing
end


"""
    whenDomainChange(b::BoolVar, procedure::Function)::Nothing where T

`Callback` executed when the domain is changed
"""
function whenDomainChange(b::BoolVar, procedure::Function)::Nothing
    whenDomainChange(variable(b), procedure)

    return nothing
end


"""
Function to return the values in the `BoolVar`
"""
function fillArray(b::BoolVar, v::Vector{T})::Vector{T} where T
    return fillArray(variable(b), v)
end

"""
    not(b::BoolVar)::AbstractVariable{Integer}

Function used to implement `not` of a boolean variable.
"""
function not(b::BoolVar)::BoolVar
    ## Cast to BoolVar as BoolVar applying subsequent "nots" should only work on BoolVars and not all AbstractVariable Integers
    return BoolVar(1 - b)
end


"""
    Base.:!(b::BoolVar)

Function used to apply a `not` to a `BoolVar`. Converts BoolVar `b` to `!b`
"""
Base.:!(b::BoolVar) = not(b)


## Forward functions from IntVar to BoolVar
@forward BoolVar.binaryVar solver, domain, minimum, maximum, size, isFixed, in, onBindConstraints

