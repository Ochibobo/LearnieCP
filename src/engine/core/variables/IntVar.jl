using Parameters
import Base: size, minimum, maximum, in

"""
    struct IntVar <: AbstractVariable{Integer}
        domain::AbstractDomain{Integer}
        domainListener::DomainListener

        function IntVar(solver::Solver, min::Integer, max::Integer)
            ## Create an instance of the SparseSetDomain
            domain = SparseSetDomain{Integer}(stateManager(solver), n , offset)
            
            ## Return an IntVar instance
            new(domain, DomainListener(solver = s), onDomainChangeConstraints, onBoundsChangeConstraints, onBindConstraints)
        end
    end

Implementation of an Integer Variable
"""
@with_kw struct IntVar <: AbstractVariable{Integer}
    solver::AbstractSolver
    domain::AbstractDomain{Integer}
    domainListener::DomainListener

    function IntVar(solver::AbstractSolver, min::Integer, max::Integer)
        ## Create an instance of the SparseSetDomain
        domain = SparseSetDomain{Integer}(stateManager(solver), min , max)
        
        ## Return an IntVar instance
        new(solver, domain, DomainListener(solver))
    end

    ## A variable having a domain of n elements starting from 0
    function IntVar(solver::AbstractSolver, n::Integer)
        return IntVar(solver, 0, n - 1)
    end
end


"""
    solver(iv::IntVar)::AbstractSolver

Get the variable's solver
"""
solver(iv::IntVar)::AbstractSolver = iv.solver


"""
    domain(iv::IntVar)::SparseSetDomain{Integer} 

Get the variable's domain
"""
domain(iv::IntVar)::SparseSetDomain{Integer} = iv.domain


"""
    domainListener(iv::IntVar)::DomainListener

Get the variable's domain listener
"""
domainListener(iv::IntVar)::DomainListener = iv.domainListener
    

"""
    onDomainChangeConstraints(iv::IntVar)::Stack{AbstractConstraint

Get a list of constraints triggered when the domain of this variable changes
"""
onDomainChangeConstraints(iv::IntVar)::StateStack{AbstractConstraint} = domainListener(iv).onDomainChangeConstraints


"""
    onBoundsChangeConstraints(iv::IntVar)::Stack{AbstractConstraint

Get a list of constraints triggered when the bounds of this variable changes
"""
onBoundsChangeConstraints(iv::IntVar)::StateStack{AbstractConstraint} = domainListener(iv).onBoundsChangeConstraints


"""
    onBindConstraints(iv::IntVar)::Stack{AbstractConstraint

Get a list of constraints triggered when this variable is bound
"""
onBindConstraints(iv::IntVar)::StateStack{AbstractConstraint} = domainListener(iv).onBindConstraints


"""
    Base.minimum(iv::IntVar)::Integer

Get the `minimum` value of this variable's domain
"""
function Base.minimum(iv::IntVar)::Integer
    return dm.minimum(domain(iv))
end


"""
    Base.maximum(iv::IntVar)::Integer

Get the `maximum` value of this variable's domain
"""
function Base.maximum(iv::IntVar)::Integer
    dm.maximum(domain(iv))    
end


"""
    Base.size(iv::IntVar)::Integer

Get the `size` value of this variable's domain
"""
function Base.size(iv::IntVar)::Integer
    dm.size(domain(iv))
end


"""
    isFixed(iv::IntVar)::Integer

Check if this variable's domain is bound
"""
function isFixed(iv::IntVar)::Integer
    dm.isBound(domain(iv))
end


"""
    Base.in(v::Integer, iv::IntVar)::Bool

Check if value `v` is in the variable's domain
"""
function Base.in(v::Integer, iv::IntVar)::Bool
    dm.in(v, domain(iv))
end


"""
    remove(iv::IntVar, v::Integer)::Nothing

Function to remove an element from the variable's domain
"""
function remove(iv::IntVar, v::Integer)::Nothing
    variableDomain = domain(iv)
    listener = domainListener(iv)

    ## Remove the value from the domain of the variable and call the propagate constraints through the listener where possible.
    dm.remove(variableDomain, v, listener)
end


"""
    fix(iv::IntVar, v::Integer)::Nothing

Function to assign a value to a variable. Notice that this value oughts to be present in the variable's domain
"""
function fix(iv::IntVar, v::Integer)::Nothing
    variableDomain = domain(iv)
    listener = domainListener(iv)

    dm.removeAllBut(variableDomain, v, listener)
end


"""
    removeAbove(iv::IntVar, v::Integer)::Nothing

Function to remove all values above a certain value in the variable's domain
"""
function removeAbove(iv::IntVar, v::Integer)::Nothing
    variableDomain = domain(iv)
    listener = domainListener(iv)

    dm.removeAbove(variableDomain, v, listener)
end


"""
    removeBelow(iv::IntVar, v::Integer)::Nothing

Function to remove all values below a certain value in the variable's domain
"""
function removeBelow(iv::IntVar, v::Integer)::Nothing
    variableDomain = domain(iv)
    listener = domainListener(iv)

    dm.removeBelow(variableDomain, v, listener)
end


"""
    propagateOnDomainChange(iv::IntVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the domain of the variable changes
"""
function propagateOnDomainChange(iv::IntVar, c::AbstractConstraint)::Nothing
    constraints =  onDomainChangeConstraints(iv)
    push!(constraints, c)

    return nothing
end


"""
    propagateOnBoundsChange(iv::IntVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the bounds of the variable changes
"""
function propagateOnBoundsChange(iv::IntVar, c::AbstractConstraint)::Nothing
    constraints = onBoundsChangeConstraints(iv)    
    push!(constraints, c)

    return nothing
end


"""
    propagateOnFix(iv::IntVar, c::AbstractConstraint)::Nothing

Function used to propagate constraints when the vraribale becomes bound
"""
function propagateOnFix(iv::IntVar, c::AbstractConstraint)::Nothing
    constraints = onBindConstraints(iv)
    push!(constraints, c)

    return nothing
end


"""


An instance of `ConstraintClosure` used to create anonymous constraints
"""
function constraintClosure(iv::IntVar, fn::Function)::AbstractConstraint
    _solver = solver(iv)
    c = ConstraintClosure(_solver, fn)
    Solver.post(_solver, c, enforceFixpoint = false)

    return c
end


"""
    whenFix(d::AbstractVariable{T}, procedure::Function)::Nothing where T

`Callback` executed when the domain is fixed
"""
function whenFix(iv::IntVar, procedure::Function)::Nothing
    constraint = constraintClosure(iv, procedure)
    constraints = onBindConstraints(iv)
    push!(constraints, constraint)

    return nothing
end


"""
    whenBoundChange(iv::IntVar, procedure::Function)::Nothing where T

`Callback` executed when the domain's bounds (min and max) are changed
"""
function whenBoundChange(iv::IntVar, procedure::Function)::Nothing
    constraint = constraintClosure(iv, procedure)
    constraints = onBoundsChangeConstraints(iv)
    push!(constraints, constraint)

    return nothing
end


"""
    whenDomainChange(iv::IntVar, procedure::Function)::Nothing where T

`Callback` executed when the domain is changed
"""
function whenDomainChange(iv::IntVar, procedure::Function)::Nothing
    constraint = constraintClosure(iv, procedure)
    constraints = onDomainChangeConstraints(iv)
    push!(constraints, constraint)

    return nothing
end


"""
    fillArray(iv::IntVar, target::Vector{T})::Vector{T} where T

Function to fill the `target` array with values from the variable's domain
"""
function fillArray(iv::IntVar, target::Vector{T})::Vector{T} where T
    dm.fillArray(domain(iv), target)

    return target
end