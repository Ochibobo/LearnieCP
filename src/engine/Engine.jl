"""
Core Engine that exposes functionality
"""
module Engine

## Exceptipns
include("exceptions/Exceptions.jl")
using .Exceptions
export AbstractSolverException
export InconsistencyException
export NotImplementedException
export EmptyBackUpException

## State
include("state/SolverState.jl")
using .SolverState
export StateManager
export getLevel
export saveState
export restoreState
export restoreStateUntil
export withNewState
export makeStateRef
export makeStateBool
export makeStateInt
export StateEntry
export restore!
export State
export setValue!
export value
export save
export StateInt
export StateBool
export increment
export decrement
export BackUp
export store
export restore
export Copy
export CopyStateEntry
export setValue!
export value
export stateObject
export setStateObject!
export save
export restore!
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
export TrailStateEntry
export restore!
export Trail
export versionID
export trailer
export trail
export setValue!
export value
export save


## Core elements of the system
include("core/Core.jl")
using .Core

end