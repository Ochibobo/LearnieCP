module Constraints

using Parameters
import ..InnerCore: AbstractConstraint, AbstractSolver, State, AbstractVariable, Solver,
            post, propagate, stateManager, makeStateRef, Variables, activate, schedule, isScheduled, isActive,
            IntVarOffsetView, IntVarMultView, makeStateInt, StateInt, decrement, BoolVar,
            setValue!, value, fix, isFixed, fillArray, propagateOnBoundChange, propagateOnFix,
            propagateOnDomainChange, whenBoundChange, whenDomainChange, whenFix, solver

## Contains shared structures and algorithms
using ..Utilities

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

include("Sum.jl")
export Sum
export summation

include("Element2D.jl")
export Element2D
export element2D

include("Element1D.jl")
export Element1D
export element1D

include("Element1DVar.jl")
export Element1DVar
export element1DVar

include("IsLessOrEqual.jl")
export IsLessOrEqual
export IsLess
export IsGreaterOrEqual
export IsGreater

include("AllDifferentBinary.jl")
export AllDifferentBinary

include("TableCT.jl")
export TableCT

include("AllDifferentDC.jl")
export AllDifferentDC

include("Circuit.jl")
export Circuit

include("Cumulative.jl")
export Cumulative

include("LessOrEqual.jl")
export LessOrEqual

include("Maximum.jl")
export Maximum

end