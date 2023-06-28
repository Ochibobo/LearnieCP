module Solver

using ..SolverState
import ..InnerCore: AbstractConstraint, AbstractSolver, AbstractObjective, AbstractVariable, post, propagate, schedule, activate
using ..InnerCore

import DataStructures: Deque, push!, popfirst!

include("AbstractSolver.jl")
export stateManager
export post
export propagate
export propagationQueue
export schedule
export fixPoint
export onFixPoint
export minimize
export maximize
export objective
export setObjective
export setStateManager

include("LearnieCP.jl")
export LearnieCP

end