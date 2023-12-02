## Tests for thr Theta Tree julia
include("../../JuliaCP.jl")

using .JuliaCP

thetaTree = Engine.Utilities.ThetaTree{Integer}(4)
## Insert an activity
insert!(thetaTree, 1, 5, 5)

## Get the earliest completion time == 5
Engine.Utilities.ect(thetaTree)

## Insert another activity
insert!(thetaTree, 2, 31, 6)
Engine.Utilities.ect(thetaTree)

## Insert another activity
insert!(thetaTree, 3, 30, 4)
Engine.Utilities.ect(thetaTree)

## Insert another activity
insert!(thetaTree, 4, 42, 10)
Engine.Utilities.ect(thetaTree)

## Remove the activity at 3
delete!(thetaTree, 4)

## Get the ect
Engine.Utilities.ect(thetaTree)

## Reset the Theta tree
Engine.Utilities.reset(thetaTree)

## Get the ect
Engine.Utilities.ect(thetaTree)
