"""
Module that handles the search functions
"""
module SearchMethods

using Parameters
using ..Engine: StateManager, withNewState

include("SearchStatistics.jl")

include("DFSearch.jl")
export DFSearch
export setOnSolution
export stateManager
export notifySolution
export solve
export dfs

end