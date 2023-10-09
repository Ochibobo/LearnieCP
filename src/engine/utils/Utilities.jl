module Utilities

using ..InnerCore

include("structures/Structures.jl")
using .Structures
export Structures

include("algorithms/Algorithms.jl")
using .Algorithms
export Algorithms

end