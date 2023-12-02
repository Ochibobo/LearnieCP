module Structures
using Parameters

include("Graphs.jl")
export Graph
export into
export out
export clear
export addNeighbour
export addNeighbours

include("Profile.jl")
export Rectangle
export Profile
export rectangleIndex
export rectangles
export getRectangle

include("ThetaTree.jl")
export Node
export ect
export sumP
export ThetaTree
export father
export left
export right
export insert!
export reCompute
export reComputeAux

end