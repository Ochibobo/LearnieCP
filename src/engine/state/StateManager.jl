"""
StateManager `interface` that manages the state of variables and constraints during search allowing for 
restoration where need be
"""
abstract type StateManager end


"""
Get's the current level of the state-tree. It is increased at each `saveState` & decreased at each `restoreState`.
Initially set to `0`
"""
function getLevel(sm::StateManager)::Integer
    throw(error("getLevel not implemented for $sm"))
end



###################################
#                                 #
#   Lower-level Back-Up API:      #s
#                                 #
###################################


"""
saveState
"""
function saveState(sm::StateManager)

end

"""
restoreState
"""
function restoreState(sm::StateManager)
    
end


"""
restoreStateUntil
"""
function restoreStateUntil(sm::StateManager, level::Integer)
    
end


###################################
#                                 #
#       Convenience API           #
#                                 #
###################################

"""
    withNewState(sm::StateManager, procedure::Function)::Nothing

Function that `saves` the state of the variable in the `StateManager`, then calls the `procedure` (branching algorithm) and later 
`restores` the state of the variable.
"""
withNewState(sm::StateManager, procedure)::Nothing = throw(error("not implemented"))
    


###################################
#                                 #
#           Factory API           #
#                                 #
###################################
## These functions are used to encapsulate the creation of a variable's domain and it's persistence in the state StateManager

"""
Create a StateRef of any type `T`
"""
function makeStateRef(sm::StateManager, initialValue::T)::T where T
    throw(error("not implemented for "))    
end


"""
makeStateInt
"""
function makeStateInt(sm::StateManager, initialValue::Integer)::StateInt
    
end


"""
makeStateBool
"""
function makeStateBool(sm::StateManager, initialValue::Bool)::StateBool
    
end


"""
Understand the state StateManager
- StateInt
- StateBool
- StateEntry - get & set values
"""