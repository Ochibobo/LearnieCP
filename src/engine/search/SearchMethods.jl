"""
Module that handles the search functions
"""
module SearchMethods

using Parameters
using ..Engine: StateManager

include("SearchStatistics.jl")

include("DFSearch.jl")
export DFSearch


end