"""
Core Engine that exposes functionality
"""
module Engine

## Exceptipns
include("exceptions/Exceptions.jl")

## State
include("state/SolverState.jl")
using .SolverState

## constraints
include("constraints/Constraints.jl")
using .Constraints 

## Solver
include("solver/Solver.jl")
using .Solver

## Domains
include("domains/Domains.jl")
using .Domains

include("variables/Variables.jl")
using .Variables

include("objective/Objectives.jl")
using .Objectives

end