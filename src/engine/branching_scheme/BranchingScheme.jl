module BranchingScheme

import ..Engine: AbstractVariable, Constraints, Variables, Solver, size, minimum

include("FirstFail.jl")
export SelectMin
export FirstFail

include("And.jl")
export And

end