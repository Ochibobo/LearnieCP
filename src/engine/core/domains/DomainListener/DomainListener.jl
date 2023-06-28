using Parameters

"""
    struct DomainListener <: AbstractDomainListener 
        solver::AbstractSolver
        onDomainChangeConstraints::Stack{AbstractConstraint}    = Stack{AbstractConstraint}()
        onBoundsChangeConstraints::Stack{AbstractConstraint}    = Stack{AbstractConstraint}()
        onBindConstraints::Stack{AbstractConstraint}            = Stack{AbstractConstraint}()
    end

Instance of a `DomainListener` that implements an `AbstractDomainListener`
"""
@with_kw struct DomainListener <: AbstractDomainListener 
    solver::AbstractSolver
    onDomainChangeConstraints::StateStack{AbstractConstraint}    = StateStack{AbstractConstraint}()
    onBoundsChangeConstraints::StateStack{AbstractConstraint}    = StateStack{AbstractConstraint}()
    onBindConstraints::StateStack{AbstractConstraint}            = StateStack{AbstractConstraint}()

    function DomainListener(solver::AbstractSolver)
        ## Retrieve the state manager
        sm = stateManager(solver)

        ## Return a new DomainListener instance
        new(solver, 
            StateStack{AbstractConstraint}(sm),
            StateStack{AbstractConstraint}(sm),
            StateStack{AbstractConstraint}(sm)
        )
    end
end


"""
    solver(dl::DomainListener)::AbstractSolver 

Get the Solver instance from the DomainListener
"""
solver(dl::DomainListener)::AbstractSolver = dl.solver



"""
    scheduleAll(s::AbstractSolver, cs::Stack{AbstractConstraint})::Nothing

Function used to schedule all `constraints` present in a Stack of constraints
"""
function scheduleAll(s::AbstractSolver, cs::StateStack{AbstractConstraint})::Nothing
    for c in stack(cs)
        Solver.schedule(s, c)
    end

    return nothing
end


"""
    onEmpty(l::DomainListener)::Nothing

`onEmpty` implementation of the `DomainListener` instance
"""
function onEmpty(l::DomainListener)::Nothing
    _ = l
    throw(error("Domain is empty"))
end


"""
    onChange(l::DomainListener)::Nothing

`onChange` implementation of the `DomainListener` instance
"""
function onChange(l::DomainListener)::Nothing
    scheduleAll(solver(l), l.onDomainChangeConstraints)
end


"""
    onChangeMin(l::DomainListener)::Nothing

`onChangeMin` implementation of the `DomainListener` instance
"""
function onChangeMin(l::DomainListener)::Nothing
    scheduleAll(solver(l), l.onBoundsChangeConstraints)
end


"""
    onChangeMax(l::DomainListener)::Nothing

`onChangeMax` implementation of the `DomainListener` instance
"""
function onChangeMax(l::DomainListener)::Nothing
    scheduleAll(solver(l), l.onBoundsChangeConstraints)
end


"""
    onBind(l::DomainListener)::Nothing

`onBind` implementation of the `DomainListener` instance
"""
function onBind(l::DomainListener)::Nothing
    scheduleAll(solver(l), l.onBindConstraints)
end
