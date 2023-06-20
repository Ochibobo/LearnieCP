"""
    abstract type StateEntry end

Abstract type that encorfes the implementation of the `restore` function used to `restore` the state of a variable
"""
abstract type StateEntry{T} end


"""
    restore(se::StateEntry{T})::Nothing where T

Function used to `restore` the state of a variable
"""
function restore!(se::StateEntry{T})::Nothing where T
    throw(error("restore not implemented for $se instance"))
end
