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

end