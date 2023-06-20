"""
Responsible for exposing all State related details of the solver
"""
module SolverState

## StateManagerInterface
include("StateManager.jl")
export StateManager
export getLevel
export saveState
export restoreState
export restoreStateUntil
export withNewState
export makeStateRef
export makeStateBool
export makeStateInt


## StateEntry
include("StateEntry.jl")
export StateEntry
export restore!

## State
include("State.jl")
export State
export setValue!
export value
export save
export StateInt
export StateBool

## StateInt operations
include("StateInt.jl")
export increment
export decrement

## BackUp
include("BackUp/BackUp.jl")
export BackUp
export store
export restore

## Copy
include("CopierManager/Copy.jl")
export Copy
export CopyStateEntry
export setValue!
export value
export stateObject
export setStateObject!
export save
export restore!

## Copier
include("CopierManager/Copier.jl")
export store
export Copier
export storeSize
export setSize!
export addToStore!
export prior
export getLevel
export saveState
export restoreState
export restoreStateUntil
export withNewState
export makeStateRef
export makeStateInt
export backUps


## Trailer
include("TrailerManager/Trailer.jl")
export Trailer
export current
export setCurrent!
export versionID
export prior
export pushState!
export saveState
export restoreState
export makeStateRef
export makeStateInt
export withNewState

## Trail
include("TrailerManager/Trail.jl")
export TrailStateEntry
export restore!
export Trail
export versionID
export trailer
export trail
export setValue!
export value
export save

end