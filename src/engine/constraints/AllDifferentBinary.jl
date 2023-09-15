"""
    @with_kw mutable struct AllDifferentBinary <: AbstractConstraint
        solver::AbstractSolver
        vars::Vector{<:AbstractVariable}

        ## Constraint-wide variables
        active::State
        isScheduled::Bool

        function AllDifferentBinary(vars::Vector{<:AbstractVariable})
            isempty(vars) && throw(DomainError("Constraint cannot work on empty vector."))
            
            ## Get the solver instance
            solver = Variables.solver(vars[1])
            ## Get the stateManager
            sm = stateManager(solver)

            ## Initialize the state
            active = makeStateRef(sm, true)

            new(solver, vars, active, false)
        end

        function AllDifferentBinary(vars::Vararg{<:AbstractVariable})
            AllDifferentBinary(collect(vars))
        end
    end

This is basically a couple of `NotEquals` that ensure members of an array of variables aren't equal
"""
@with_kw mutable struct AllDifferentBinary{T} <: AbstractConstraint
    solver::AbstractSolver
    vars::Vector{<:AbstractVariable}

    ## Constraint-wide variables
    active::State
    isScheduled::Bool

    function AllDifferentBinary{T}(vars::Vector{<:AbstractVariable}) where T
        isempty(vars) && throw(DomainError("Constraint cannot work on empty vector."))
        
        ## Get the solver instance
        solver = Variables.solver(vars[1])
        ## Get the stateManager
        sm = stateManager(solver)

        ## Initialize the state
        active = makeStateRef(sm, true)

        new{T}(solver, vars, active, false)
    end

    function AllDifferentBinary{T}(vars::Vararg{<:AbstractVariable}) where T
        AllDifferentBinary{T}(collect(vars))
    end
end


"""
    post(c::AllDifferentBinary{T})::Nothing where T

Function to `post` the `AllDifferentBinary` constraint
"""
function post(c::AllDifferentBinary{T})::Nothing where T
    vars = c.vars
    solver = c.solver
    for i in eachindex(vars)
        for j in i + 1:length(vars)
            Solver.post(solver, NotEqual{T}(vars[i], vars[j]))
        end
    end

    return nothing
end


"""
    propagate(c::AllDifferentBinary)::Nothing

Function to `propagate` the `AllDifferentBinary` constraint
"""
function propagate(c::AllDifferentBinary)::Nothing
    _ = c

    return nothing
end