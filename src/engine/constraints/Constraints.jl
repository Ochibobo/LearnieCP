module Constraints

using Parameters
import ..InnerCore: AbstractConstraint, AbstractSolver, State, AbstractVariable,
            post, propagate, stateManager, makeStateRef, Variables, activate, schedule, isScheduled, isActive,
            setValue!, value, fix, isFixed, fillArray, propagateOnBoundChange, propagateOnFix,
            propagateOnDomainChange, whenBoundChange, whenDomainChange, whenFix, solver


include("ConstEqual.jl")
export ConstEqual
export solver
export post
export propagate
export schedule
export isScheduled
export activate
export isActive

include("NotEqual.jl")
export NotEqual

include("ConstNotEqual.jl")
export ConstNotEqual

include("Equals.jl")
export Equal

end