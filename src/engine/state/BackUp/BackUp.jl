using DataStructures
using Parameters

"""
    struct BackUp{T}
        store::Stack{StateEntry{T}} = Stack{StateEntry{}}()

        ## Create a new BackUp instance from an existing source
        function BackUp(source::Stack{T}) where T
            stack = Stack{StateEntry{T}}()
        
            for s in source
                push!(stack, save(s))
            end
        
            return BackUp{T}(store = stack)
        end
    end

Global Implementation of the `BackUp{T}` of a `StateManager`'s state.
It stores instances of the `StateEntry{T}` type
"""
mutable struct BackUp{T}
    store::Stack{StateEntry{T}}

    ## Zero-arg constructor
    function BackUp{T}() where T
        new{T}(Stack{StateEntry{T}}())
    end

    ## Create a new BackUp instance from an existing source
    function BackUp{T}(source::Stack{State{T}}) where T
        stack = Stack{StateEntry{T}}()
    
        for s in source
            push!(stack, save(s))
        end
    
        return new{T}(stack)
    end
end


"""
    store(b::BackUp{T})::Stack{StateEntry{T}} where T

Get the `BackUp` store which holds the `CopyStateEntry{T}` instances.
"""
function store(b::BackUp{T})::Stack{StateEntry{T}} where T
    return b.store
end


"""
    restore(b::BackUp{T})::Nothing where T

Restore the value of the states in the `BackUp`
"""
function restore(b::BackUp{T})::Nothing where T
    ## If the store is emtpy, inform the user and exit
    ## Or should I throw an error??
    # if length(store(b)) < 1
    #     throw(error("Cannot restore from an emtpy back up."))
    # end

    for se in store(b)
        restore!(se)
    end
end

