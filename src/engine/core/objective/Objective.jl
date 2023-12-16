using Parameters

"""
    mutable struct Minimize <: AbstractObjective
        bound::Integer
        value::IntVar

        function Minimize(iv::IntVar)
            value = iv
            bound = typemax(Int)

            new(bound, value)
        end
    end

Structure of the `Minimize` objective
"""
@with_kw mutable struct Minimize{T} <: AbstractObjective
    bound::Integer = typemax(Int)
    value::AbstractVariable{T}

    function Minimize{T}(iv::AbstractVariable{T}) where T
        ## Initialize the bound with the largest Int value
        bound = typemax(Int)
        ## Create a new instance of `Minimize`
        m = new{T}(bound, iv)

        ## Get the variable's solver
        solver  = Variables.solver(m.value)
        ## Remove the values above the bound
        onFixPoint(solver, () -> Variables.removeAbove(m.value, m.bound))

        ## Return a new instance of the Minimize struct
        m
    end
end


function removeValuesAboveBound(m::Minimize)
    onFixPoint(m.solver, () -> Variables.removeAbove(m.value, m.bound))
end


"""
    tighten(m::Minimize)::Nothing

Function to `tighten` to upper bound of the variable to be minimized
"""
function tighten(m::Minimize)::Nothing
    if(!Variables.isFixed(m.value))
        println("Variable not fixed for minimization with size: $(size(m.value))") 
        throw(ErrorException("Variable not fixed for minimization"))
    end
    ## Reduce the bound by 1
    m.bound = maximum(m.value) - 1

    return nothing
end


"""
    objectiveValue(m::Minimize)::AbstractVariable{Integer}

Function to get the objective value
"""
function objectiveValue(m::AbstractObjective)::Integer
    if isnothing(m)
        return typemax(Int)
    end
    return minimum(m.value)
end


