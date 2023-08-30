module BranchingScheme

import ..Engine: AbstractVariable, Constraints, Variables, Solver, size, minimum

include("FirstFail.jl")
export selectMin
export firstFail

include("And.jl")
export and

end