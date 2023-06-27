using Parameters


"""
    mutable struct Trail{T} <: State{T}
        v::T                    
        versionID::Integer      = -1
        trailer::Trailer{T}
    end

State<T> element that is a member of the `Trailer` StateManager
The `Trailer{T}` instance is passed for version comparison in the `trail` function
"""
@with_kw mutable struct Trail{T} <: State{T}
    v::T                    
    versionID::Integer      = -1
    trailer::Trailer{T}
end


"""
    struct TrailStateEntry{T} <: StateEntry{T}
        v::T
        so::Trail{T}
    end

The `StateEntry{T}` of a `Trail{T}` instance. Useful for storage and restoration.
"""
@with_kw struct TrailStateEntry{T} <: StateEntry{T}
    v::T
    so::Trail{T}
end


"""
    restore!(tse::TrailStateEntry{T})::Nothing where T

`restore!` function of the `TrailStateEntry{T}` instance
"""
function restore!(tse::TrailStateEntry{T})::Nothing where T
    tse.so.v = tse.v

    return nothing
end



"""
    versionID(t::Trail{T})::Integer where T

Get the `versionID` of a `Trail{T}` instance
"""
function versionID(t::Trail{T})::Integer where T
    return t.versionID
end


"""
    trailer(trail::Trail{T})::Trailer{T} where T

Get the `trailer` from an instance of `Trail{T}`
"""
function trailer(trail::Trail{T})::Trailer{T} where T
    return trail.trailer
end


"""
    trail(tr::Trail{T})::Nothing where T

Persist the `trail's` TrailEntry to the Trailer's state
"""
function trail(tr::Trail{T})::Nothing where T
    _trailer = trailer(tr)
    ## Compare the versionID of the Trail with the Trailer's
    ## Prevents from mutliple saves of the same State by creating a new StateEntry
    ## if the element has been saved
    ## Ensures a State{T} object is saved only once.
    if versionID(_trailer) != versionID(tr)
        ## Update the trail's version to the trailer's
        tr.versionID = _trailer.versionID
        ## save the Trail's state entry to the trailer
        pushState!(_trailer, save(tr))
    end

    return nothing
end


"""
    setValue!(t::Trail{T}, value::T)::Nothing where T

Set the value of the `Trail{T}` instance
"""
function setValue!(t::Trail{T}, value::T)::T where T
    ## Check if incoming value differs from the current value
    if value != t.v
        ## Create a backup
        trail(t)
        ## Update the Trail's value
        t.v = value
    end

    return t.v
end


"""
    value(tr::Trail{T})::T where T

Get the value of a `Trail{T}` instance
"""
function value(tr::Trail{T})::T where T
    return tr.v
end


"""
    save(trail::Trail{T})::Nothing where T

Return a new instance of `TrailStateEntry{T}` whose value is the same as the `trail`. It also keeps an instance of the `trail`.
This is useful for restoration.
"""
function save(trail::Trail{T})::StateEntry{T} where T
    return TrailStateEntry(trail.v, trail)
end

