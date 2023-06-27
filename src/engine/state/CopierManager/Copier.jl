using Parameters
using DataStructures


"""
    struct Copier{T} <: StateManager
        store::Stack{State{T}}  = Stack{State{T}}() ## Stack of objects that we need to save
        prior::Stack{BackUp{T}} = Stack{BackUp{T}}() ## Stack of a Stack of states every time we take a branch
    end

Implements the `StateManager` for the `Copy` interface. It saves all state variables on each `saveState` call
regardless of whether or not a variable's state changed between its last persistence & the current one.
"""
@with_kw struct Copier{T} <: StateManager
    store::Stack{State{T}}  = Stack{State{T}}() ## Stack of objects that we need to save
    prior::Stack{BackUp{T}} = Stack{BackUp{T}}() ## Stack of a Stack of states every time we take a branch
end


"""
    store(c::Copier{T})::Stack{State{T}} where T

Get the `primary store` of the `Copier`. This is where all the state variables are saved.
"""
function store(c::Copier{T})::Stack{State{T}} where T
    return c.store
end


"""
    clear!(s::Stack)::Nothing

Clear a `Stack` of its elements. Can be used to clear the `prior`, the `backup` store and the copier's `store`
"""
function clear!(s::Stack)::Nothing
    while length(s) > 0
        pop!(s)
    end   
    
    return nothing
end


"""
    storeSize(c::Copier{T})::Integer where T

Get the size of the `store` of the `Copier`. This is also the number of state variables.
"""
function storeSize(c::Copier{T})::Integer where T
    return length(store(c))
end


"""
    setSize!(s::Stack{T}, size::Integer)::Nothing where T

Set the size of a `Stack` to `size`. While this shows up in the `Java` implementation, I don't see its utility at all.
"""
function setSize!(s::Stack{T}, size::Integer)::Nothing where T
    sizeDifference = size - length(s)

    while sizeDifference > 0
        pop!(s)
        sizeDifference -= 1
    end

    return nothing
end


"""
    addToStore!(c::Copier{T}, value::Copy{T})::Nothing where T

Add an instance of `Copy{T}` to the `Copier`'s store.
"""
function addToStore!(c::Copier{T}, value::Copy{T})::Nothing where T
    _store = store(c)
    push!(_store, value)

    return nothing
end


"""
    prior(c::Copier{T})::Stack where T

Get the `prior` of the `Copier`. This is the `Stack` of all `BackUp` instances.
"""
function prior(c::Copier{T})::Stack{BackUp{T}} where T
    return c.prior
end


"""
    backUps(c::Copier{T})::Nothing where T

Helper function to print the backUps from the `Copier`
"""
function backUps(c::Copier{T})::Nothing where T
    for e in prior(c)
        println(store(e))
    end

    nothing
end


"""
    getLevel(c::Copier{T})::Integer where T

Get the number of backups stored. This is similar to the `level` in the `SearchTree`
"""
function getLevel(c::Copier{T})::Integer where T
    return length(prior(c))
end


"""
saveState(c::Copier{T})::Nothing where T

`Save` the current state of the variables. This creates a `copy` of everything present in the current `store` and
inserts it into the BackUp. While the store only contains values of type `Copy{T}`, before the persistence of each value 
into the `BackUp{CopyStateEntry{T}}`, the function `save(c::Copy{T})::CopyStateEntry{T} where T` is called to create a new 
`CopyStateEntry{T}` for each instance of `Copy{T}` then add the to the `BackUp{CopyStateEntry{T}}` store. The `CopyStateEntry{T}`
contains the value of `Copy{T}` at the point of backing up and its instance. It is this value that is reset during restoration.
"""
function saveState(c::Copier{T})::Nothing where T
    ## Create a backUp for the store
    backUp = BackUp{T}(store(c))
    ## Push the backUp into the prior stack
    push!(c.prior, backUp)

    return nothing
end


"""
    restoreState(c::Copier{T})::Nothing where T

Restore the state of a `Copier`'s state from the most receng `BackUp`.
"""
function restoreState(c::Copier{T})::Nothing where T
    if length(prior(c)) < 1
        throw(error("cannot restore from an empty backup"))
    end

    ## Get the top backUp entry
    backUp = pop!(c.prior)
    
    ## Get the length of the backup
    sz = length(backUp)

    ## Set the storeSize which will remove elements that aren't relevant anymore from the store
    setSize!(c.store, sz)

    ## Restore this backUp by calling restore on every stateEntry
    restore(backUp)
    
    return nothing
end


"""
    restoreStateUntil(c::Copier{T}, level::Integer)::Nothing where T

`Level` driven restoration.
"""
function restoreStateUntil(c::Copier{T}, level::Integer)::Nothing where T
    while getLevel(c) > level
        restoreState(c)
    end
end


"""
    withNewState(c::Copier{T}, procedure::Function)::Nothing where T

Convenient function to create a new state, invoke a `procedure` then restore the state. The invoked `procedure` may have changed
the state hence the need for restoration.
"""
function withNewState(c::Copier{T}, procedure::Function)::Nothing where T
    level = getLevel(c)
    ## Save the initial State
    saveState(c)
    ## Call the procedure
    procedure()
    ## Restore the state
    while (getLevel(c) > level) restoreState(c) end
end


"""
    makeStateRef(c::Copier{T}, initialValue::T)::State{T} where T

Make an instance of `Copy{T}` and save it to the `Copier`'s store.
"""
function makeStateRef(c::Copier{T}, initialValue::T)::State{T} where T
    ci::Copy{T} = Copy{T}(initialValue)
    addToStore!(c, ci)
    return ci
end


"""
    makeStateInt(c::Copier{T}, initialValue::T)::StateInt where T <: Integer

Make an instance of `Copy{Integer}` and save it to the `Copier`'s store.
"""
function makeStateInt(c::Copier{T}, initialValue::T)::StateInt where T <: Integer
    ci::Copy{Integer} = Copy{Integer}(initialValue)
    addToStore!(c, ci)
    return ci
end


"""
    makeStateBool(c::Copier{T}, initialValue::T)::StateInt where T <: Bool

Make an instance of `Copy{Bool}` and save it to the `Copier`'s store.
"""
function makeStateBool(c::Copier, initialValue::T)::StateBool where T <: Bool
    
end

















# """
#     @with_kw struct BackUp{T}
#         size::Integer                   = 0
#         store::Stack{StateEntry{T}}     = Stack{StateEntry{T}}()
#     end

# BackUp Type Design
# - Has a size field used for restoration of the data
# """

# @with_kw struct BackUp{T}
#     size::Integer                   = 0
#     store::Stack{StateEntry{T}}     = Stack{StateEntry{T}}()
# end


# """
#     BackUp(source::Stack{State{T}})::BackUp{T} where T

# Creates a BackUp of the current state. O(n).
# """
# function BackUp(source::Stack{State{T}})::BackUp{T} where T
#     size = length(source)
#     stack = Stack{StateEntry{T}}()

#     for s in source
#         push!(stack, save(s))
#     end

#     return BackUp{T}(size = size, store = stack)
# end


# """
#     store(b::BackUp{T})::Stack{StateEntry{T}} where T

# Get the `BackUp` store which holds the `CopyStateEntry{T}` instances.
# """
# function store(b::BackUp{T})::Stack{StateEntry{T}} where T
#     return b.store
# end



# """
#     restoreBackUp(b::BackUp{T})::Nothing where T

# Restore the value of the states in the `BackUp`
# """
# function restoreBackUp(b::BackUp{T})::Nothing where T
#     ## If the store is emtpy, inform the user and exit
#     ## Or should I throw an error??
#     if length(store(b)) < 1
#         throw(error("Cannot restore from an emtpy back up."))
#     end

#     for se in store(b)
#         restore!(se)
#     end
# end