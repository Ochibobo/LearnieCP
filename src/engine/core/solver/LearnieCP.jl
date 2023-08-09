using Parameters

"""
    mutable struct LearnieCP <: AbstractSolver
        propagationQueue::Queue{AbstractConstraint}
        sm::StateManager
        objective::Union{AbstractObjective, Nothing}

        ## Initialize the CP Solver
        function LearnieCP(sm::StateManager, objective::AbstractObjective)
            new(Queue{AbstractConstraint}(), sm, objective)
        end

        ## Initialize the solver without an objective
        function LearnieCP(sm::StateManager)
            new(Queue{AbstractConstraint}(), sm, nothing)
        end

        ## Initialize without a parameter
        function LearnieCP()
            new(Queue{AbstractConstraint}(), Trailer{Integer}(), nothing)
        end
    end

Structure of the `LearnieCP` solver
"""
mutable struct LearnieCP <: AbstractSolver
    propagationQueue::Deque{AbstractConstraint}
    sm::StateManager
    objective::Union{AbstractObjective, Nothing}
    fixPointListeners::Vector{Function}

    ## Initialize the CP Solver
    function LearnieCP(sm::StateManager, objective::AbstractObjective)
        new(Deque{AbstractConstraint}(), sm, objective, Vector{Function}())
    end

    ## Initialize the solver without an objective
    function LearnieCP(sm::StateManager)
        new(Deque{AbstractConstraint}(), sm, nothing, Vector{Function}())
    end

    ## Initialize without a parameter
    function LearnieCP()
        new(Deque{AbstractConstraint}(), Trailer{Integer}(), nothing, Vector{Function}())
    end
end


"""
    stateManager(s::LearnieCP)::StateManager

Function to get the solver's state manager
"""
function stateManager(s::LearnieCP)::StateManager
    return s.sm
end


"""
    setStateManager(s::LearnieCP, sm::StateManager)::Nothing

Function to set a solver's state manager
"""
function setStateManager(s::LearnieCP, sm::StateManager)::Nothing
    s.sm = sm
end


"""
    post(s::LearnieCP, c::AbstractConstraint)::Nothing

Function used to post a `constraint` from the `Solver`.
"""
function post(s::LearnieCP, c::AbstractConstraint; enforceFixpoint = true)::Nothing
    ## Post the constraint
    InnerCore.post(c)
    ## Run the fixPoint
    if (enforceFixpoint) fixPoint(s) end
end


"""
    propagate(s::LearnieCP, c::AbstractConstraint)::Nothing

Function used to `propagate` constraints in the `solver`
"""
function propagate(s::LearnieCP, c::AbstractConstraint)::Nothing
    _ = s
    ## Mark the constraint as not being scheduled (out of the queue)
    InnerCore.schedule(c, false)

    ## Assert the constraint is active
    if InnerCore.isActive(c)
        InnerCore.propagate(c)
    end
end


"""
    propagationQueue(s::AbstractSolver)::Queue{AbstractConstraint}

Function used to get the propagation queue of the constraints scheduled in the `LearnieCP`
"""
function propagationQueue(s::LearnieCP)::Deque{AbstractConstraint}
    return s.propagationQueue
end


"""
    schedule(s::LearnieCP, c::AbstractConstraint)::Nothing

Function to add constraint `c` to the propagationQueue of the solver for propagation
"""
function schedule(s::LearnieCP, c::AbstractConstraint)::Nothing
    ## Assert than the constraint is active & not scheduled first
    if InnerCore.isActive(c) && !InnerCore.isScheduled(c)
        ## Mark the constraint as being scheduled
        InnerCore.schedule(c, true)
        ## Add it to the solver's propagationQueue
        push!(propagationQueue(s), c)
    end

    return nothing
end



"""
    fixPoint(s::LearnieCP)::Nothing

Function used to repeatedly perform the propagation
"""
function fixPoint(s::LearnieCP)::Nothing
    try
        ## Execute the functions to be executed onFixPoint
        notifyOnFixPoint(s)
        ## Propagate the available scheduled constraints
        while(!isempty(propagationQueue(s)))
            cs = popfirst!(propagationQueue(s))
            propagate(s, cs)
        end
    catch e
        ## Clear the propagation queue at this node
        while(!isempty(propagationQueue(s)))
            cs = popfirst!(propagationQueue(s))
            ## Mark constraint cs as not being scheduled
            InnerCore.schedule(cs, false)
        end

        throw(e)
    end
end


"""
    onFixPoint(s::LearnieCP,procedure::Function)::Nothing

Procedure called each time the `fixPoint` is executed
"""
function onFixPoint(s::LearnieCP, procedure::Function)::Nothing
    push!(s.fixPointListeners, procedure)

    return nothing
end


"""
    notifyOnFixPoint(s::LearnieCP)::Nothing

Function to execute when the solver executes the fixpoint algorithm
"""
function notifyOnFixPoint(s::LearnieCP)::Nothing
    for f in s.fixPointListeners
        f() ## Execute the appropriate function onFixPoint
    end

    return nothing
end


"""
    setObjective(s::LearnieCP, o::AbstractObjective)::AbstractObjective

Function to set the solver's objective. The solver can only have one objective
"""
function setObjective(s::LearnieCP, o::AbstractObjective)::Nothing
    s.objective = o

    return nothing
end


"""
    objective(s::LearnieCP)::AbstractObjective

Function to get the solver's objective
"""
function objective(s::LearnieCP)::Union{AbstractObjective, Nothing}
    return s.objective   
end
