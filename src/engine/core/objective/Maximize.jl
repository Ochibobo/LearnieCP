import Lazy: @forward
"""
    mutable struct Maximize <: AbstractObjective
        bound::Integer
        value::IntVar

        function Maximize(iv::AbstractVariable{T})
            value = iv
            bound = typemax(Int)

            new(bound, value)
        end
    end

Structure of the `Maximize` objective. To maximize, we simply minimize the negative value of the variable to be maximized then run a apply
minimize on it.
"""
@with_kw mutable struct Maximize{T} <: AbstractObjective
    minimizer::Minimize{T}

    function Maximize{T}(iv::AbstractVariable{T}) where T
        minimizer = Minimize{T}(-iv)

        new{T}(minimizer)
    end
end


## Forward shared functions from minimize to maximize
@forward Maximize.minimizer removeValuesAboveBound, tighten, objectiveValue