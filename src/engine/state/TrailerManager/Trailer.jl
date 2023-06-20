using Parameters
using DataStructures


"""
    mutable struct Trailer{T} <: StateManager
        current::BackUp{T}         = BackUp()
        prior::Stack{BackUp{T}}    = Stack{BackUp{T}}()
        versionID::Integer          = 0
    end

Uses trailing - which only copies the variables that have been modified.
"""
@with_kw mutable struct Trailer{T} <: StateManager
    current::BackUp{T}         = BackUp{T}()
    prior::Stack{BackUp{T}}    = Stack{BackUp{T}}()
    versionID::Integer         = 0                          ## The number of backups present
end


"""
    current(t::Trailer{T})::BackUp{T} where T

Get the `current` backup of the `Trailer{T}` instance
"""
function current(t::Trailer{T})::BackUp{T} where T
    return t.current    
end


"""
    setCurrent!(trailer::Trailer{T}, newBackUp::BackUp{T})::Nothing where T

Set the `current` backup of the `Trailer{T}` instance
"""
function setCurrent!(trailer::Trailer{T}, newBackUp::BackUp{T})::Nothing where T
    trailer.current = newBackUp

    return nothing
end


"""
    versionID(t::Trailer{T})::Integer where T

Get the `versionID` of the `Trailer{T}` instance
"""
function versionID(t::Trailer{T})::Integer where T
    return t.versionID
end


"""
    prior(t::Trailer{T})::Stack{BackUp{T}} where T

Get the `prior` of the `Trailer{T}` instance
"""
function prior(t::Trailer{T})::Stack{BackUp{T}} where T
    return t.prior
end


"""
    pushState!(t::Trailer{T}, tse::TrailStateEntry{T})::Nothing where T

Add a `TrailStateEntry{T}` to the `current` backup instance.
"""
function pushState!(t::Trailer{T}, tse::StateEntry{T})::Nothing where T
    push!(store(current(t)), tse)

    return nothing
end


"""
    saveState(t::Trailer{T})::Nothing where T

Save the state of the `Trailer{T}` instance
"""
function saveState(t::Trailer{T})::Nothing where T
    ## Add the current backup to the prior 
    push!(prior(t), current(t))

    ## Set the current to a new BackUp instance
    setCurrent!(t, BackUp{T}())

    ## Increase the version number
    t.versionID += 1

    return nothing
end


"""
    restoreState(t::Trailer{T})::Nothing where T

Restore the state of the `Trailer{T}` instance
"""
function restoreState(t::Trailer{T})::Nothing where T
    ## Restore the current backup by undoing the changes made in it.
    restore(current(t))

    ## Set the BackUp to the previous backUp
    t.current = pop!(prior(t))

    ## Increase the version number
    t.versionID += 1

    return nothing
end


"""
    withNewState(c::Trailer{T}, procedure::Function)::Nothing where T

Convenient function to create a new state, invoke a `procedure` then restore the state. The invoked `procedure` may have changed
the state hence the need for restoration.
"""
function withNewState(trailer::Trailer{T}, procedure::Function)::Nothing where T
    level = getLevel(trailer)
    saveState(trailer)
    procedure()
    while(getLevel(trailer) > level) restoreState(trailer) end

    return nothing
end

"""
    makeStateRef(trailer::Trailer{T}, initialValue::T)::State{T} where T

Make an instance of `Trail{T}` which is a subset of `State{T}`
"""
function makeStateRef(trailer::Trailer{T}, initialValue::T)::State{T} where T
    return Trail{T}(v = initialValue, trailer = trailer)
end


"""
    makeStateInt(trailer::Trailer{T}, initialValue::T)::StateInt where T <: Integer

Make an instance of `Trail{Integer}` which is an instance of `State{T <: Integer}`
"""
function makeStateInt(trailer::Trailer{T}, initialValue::T)::StateInt where T <: Integer
    return Trail{Integer}(v = initialValue, trailer = trailer)
end


"""
Make an instance of `Trail{Bool}`
"""
function makeStateBool(trailer::Trailer{T}, initialValue::Bool)::StateInt where T
    
end












# """
#     mutable struct TBackUp{T}
#         store::Stack{TrailStateEntry{T}} = Stack{TrailStateEntry{T}}()
#     end

# Structure that holds the value of a `BackUp` instance
# """
# @with_kw mutable struct TBackUp{T}
#     store::Stack{TrailStateEntry{T}} = Stack{TrailStateEntry{T}}()
# end


# """
#     store(b::TBackUp{T})::Stack{TrailStateEntry{T}} where T

# Get the `store` of the `TBackUp{T}` instance
# """
# function store(b::TBackUp{T})::Stack{TrailStateEntry{T}} where T
#     return b.store
# end


# """
#     restoreBackUp(b::TBackUp{T})::Nothing where T

# Function to restore the values in the current backup
# """
# function restoreBackUp(b::TBackUp{T})::Nothing where T
#     for el in b
#         restore!(el)
#     end
# end