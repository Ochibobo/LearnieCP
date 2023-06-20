using Parameters

"""
Implements the `State{T}` for the `CopierManager`
"""
@with_kw mutable struct Copy{T} <: State{T}
    v::T
end


"""
State entry of each `Copy{T}` instance that allows for restoration of values
"""
@with_kw struct CopyStateEntry{T} <: StateEntry{T}
    v::T
    so::Copy{T}
end


"""
Set the value of v
"""
function setValue!(c::Copy{T}, value::T)::T where T
    c.v = value
    return c.v
end


"""
Get the value of v
"""
function value(c::Copy{T})::T where T
    return c.v
end


"""
Retrieve the `StateEntry` from `Copy{T}`
"""
# stateEntry(c::Copy{T})::CopyStateEntry{T} = c.stateEntry
function stateObject(cse::CopyStateEntry{T})::Copy{T} where T
    return cse.so
end


"""
Set the `StateEntry` for `Copy{T}`
"""
# setStateEntry!(c::Copy{T}, se::CopyStateEntry{T})::CopyStateEntry{T} = c.stateEntry = se 
function setStateObject!(cse::CopyStateEntry{T}, c::Copy{T})::CopyStateEntry where T
    return cse.so = c
end


"""
Function to save the state
"""
function save(c::Copy{T})::CopyStateEntry{T} where T
    return CopyStateEntry(c.v, c)
end


"""
Function to restore the value of the 
"""
function restore!(cse::CopyStateEntry{T})::Nothing where T
    cse.so.v = cse.v

    return nothing
end

