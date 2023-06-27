module Variables

import ..Core: AbstractConstraint, AbstractVariable, AbstractDomain, AbstractSolver, stateManager
using ..Domains
using ..SolverState
const dm = Domains

include("AbstractVariable.jl")
export minimum
export maximum
export size
export isFixed
export in
export remove
export fix
export removeBelow
export removeAbove
export whenFix
export whenBoundChange
export whenDomainChange
export propagateOnBoundChange
export propagateOnDomainChange
export propagateOnFix

include("IntVar.jl")
export IntVar
export domain
export domainListener
export onDomainChangeConstraints
export onBoundsChangeConstraints
export onBindConstraints

include("IntVarArray.jl")
export makeIntVarArray

end