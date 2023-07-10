module Variables

import ..InnerCore: AbstractConstraint, AbstractVariable, AbstractDomain, AbstractSolver, stateManager,
                    ConstraintClosure, post, Solver
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
export solver

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