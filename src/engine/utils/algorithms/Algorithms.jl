### Algorithms used in this Engine
module Algorithms

using ..Structures
import ..InnerCore: AbstractVariable, Variables, minimum, maximum

include("MaximalMatching.jl")
export MaximalMatching
export compute

include("SCC.jl")
export getStronglyConnectedComponents

end