using Parameters
import Lazy: @forward

"""
    @with_kw struct BoolVar <: AbstractVariable{Integer}
        binaryVar::IntVar
    
        function BoolVar(variable::IntVar)
            new(variable)
        end
    end

`BoolVar` is an implementation of a boolean variable
"""
@with_kw struct BoolVar <: AbstractVariable{Integer}
   binaryVar::IntVar

   function BoolVar(variable::IntVar)
        new(variable)
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
    return minimum(b) == 0
end


"""
    fix(b::BoolVar, value::Bool)::Nothing

Function to `fix` the value of the `BoolVar` instance
"""
function fix(b::BoolVar, value::Bool)::Nothing
    fix(variable(b), value ? 1 : 0)

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
    whenFix(b::BoolVar, procedure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(b::BoolVar, procedure::Function)::Nothing
    whenFix(variable(b), procedure)

    return nothing
end


## Forward functions from IntVar to BoolVar
@forward BoolVar.binaryVar solver, domain, minimum, maximum, size, isFixed, in, onBindConstraints

