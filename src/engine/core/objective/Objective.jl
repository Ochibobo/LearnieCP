module Objective

using Parameters
import ..InnerCore: AbstractObjective, AbstractVariable, Variables, onFixPoint

## Minimize structure
include("Minimize.jl")
export Minimize
export removeValuesAboveBound
export tighten
export objectiveValue

include("Maximize.jl")
export Maximize

end
