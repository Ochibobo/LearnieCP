"""
Module that handles the search functions
"""
module SearchMethods

using Parameters
using ..Engine: StateManager, withNewState, AbstractObjective, tighten

include("SearchStatistics.jl")
export SearchStatistics
export increaseNumberOfSolutions
export increaseNumberOfFailures
export increaseNumberOfNodes
export markAsCompleted
export numberOfSolutions
export numberOfFailures
export numberOfNodes
export isCompleted

include("DFSearch.jl")
export DFSearch
export addOnSolution
export stateManager
export notifySolution
export solve
export dfs
export optimize
export optimizeSubjectTo

end