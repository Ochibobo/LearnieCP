"""
Module responsible for the definition and exposition of the solver's domains

Contains `interface` definitions and implementations of `common` domains.
"""
module Domains

using ..SolverState
import ..Core: AbstractConstraint, AbstractDomainListener, AbstractDomain
using ..Solver

## The domain listeners
include("AbstractDomainListener.jl")
export onEmpty
export onChange
export onChangeMin
export onChangeMax
export onBind

## The AbstractDomain
include("AbstractDomain.jl")
export minimum
export maximum
export size
export isBound
export in
export remove
export removeAllBut
export removeBelow
export removeAbove
export fillArray

## The DomainListener
include("DomainListener/DomainListener.jl")
export DomainListener
export solver
export scheduleAll


## The SparseSet implementation of a Domain
include("StateSparseSet/StateSparseSet.jl")
export StateSparseSet
export indexOf
export index
export values
export size
export isempty
export in
export offset
export minimum
export maximum
export collect
export swap!
export internalContains
export updateBoundsOnRemove
export remove
export removeAllBut
export removeAll
export removeBelow
export removeAbove

## The SparseSetDomain
include("SparseSetDomain.jl")
export SparseSetDomain
export domain
export isBound
export remove
export removeAllBut
export removeBelow
export removeAbove

end
