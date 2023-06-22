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
@with_kw mutable struct Minimize <: AbstractObjective
    bound::Integer
    value::IntVar

    function Minimize(iv::IntVar)
        value = iv
        bound = typemax(Int)

        new(bound, value)
    end
end


