"""
    mutable struct Circuit{T} <: AbstractConstraint
        solver::AbstractSolver
        vars::Vector{<:AbstractVariable{T}}
        nVars::Integer
        dest::Vector{StateInt}
        origin::Vector{StateInt}
        lengthToDest::Vector{StateInt}

        active::State
        scheduled::Bool
    end

The `Circuit` constraint
"""
@with_kw mutable struct Circuit{T} <: AbstractConstraint
    solver::AbstractSolver
    vars::Vector{<:AbstractVariable{T}}
    nVars::Integer
    dest::Vector{StateInt}
    origin::Vector{StateInt}
    lengthToDest::Vector{StateInt}

    active::State
    scheduled::Bool

    function Circuit{T}(vars::Vector{<:AbstractVariable{T}}) where T
        ## Throw an error if the variable vector is zero
        isempty(vars) && throw(DomainError("Variable vector should have a length > 1."))
        ## Solver and stateManager
        solver = Variables.solver(vars[1])
        sm = stateManager(solver)

        ## The number of variables
        nVars = length(vars)

        ## Destination, source and lengthToDest vectors
        dest = Vector{StateInt}(undef, nVars)
        src = Vector{StateInt}(undef, nVars)
        lengthToDest = Vector{StateInt}(undef, nVars)

        ## Fill the destination, source and lengthToDest vectors
        for i in 1:length(vars)
            dest[i] = makeStateInt(sm, i)
            src[i] = makeStateInt(sm, i)
            lengthToDest[i] = makeStateInt(sm, i)
        end

        ## Mark the constraint as being active
        active = makeStateRef(sm, true)

        new{T}(solver, vars, nVars, dest, src, lengthToDest, active, false)
    end
end


"""
    post(c::Circuit)::Nothing

Function to `post` the `Circuit` constraint
"""
function post(c::Circuit{T})::Nothing where T
    ## Ensure the successor of each variable is different
    Solver.post(c.solver, AllDifferentDC{T}(c.vars))

    ## Clean the variable's domain space
    for (i, var) in enumerate(c.vars)
        ## Remove self-references
        Variables.remove(var, i)
        ## Remove any references to non-positive values
        Variables.removeBelow(var, 1)
        ## Remove any references to values greater than the number of variables
        Variables.removeAbove(var, c.nVars)
    end

    ## Execute a function on-bind
    for (i, var) in enumerate(c.vars)
        Variables.whenFix(var, () -> fix(c, i))
    end

    return nothing
end


"""
    fix(c::Circuit, index::Integer)::Nothing

"""
function fix(c::Circuit, i::Integer)::Nothing
    successor = minimum(c.vars[i]) ## Get the successor variable index
    
    ## Mark variable i as the origin of it's successor
    setValue!(c.origin[successor], i)

    ## Update the length to the destination - across all board
    setValue!(c.lengthToDest[value(c.origin[i])], value(c.lengthToDest[value(c.origin[i])]) + value(c.lengthToDest[successor]) + 1)

    for (idx, var) in c.vars
        ## Update the destination of all nodes whose destination was node i
        if value(c.dest[idx]) == i
            ## Update the destination to the successor's destination
            successorDestination = value(c.dest[successor])
            setValue!(c.dest[idx], successorDestination)
            ## Update the length from idx to destination
            updatedLength = value(c.lengthToDest[idx]) + value(c.lengthToDest[successor]) + 1
            setValue!(c.lengthToDest[idx], updatedLength)
        end

        ## Update the origin of all variables whose origin is the successor 
        if value(c.origin[idx]) == successor
            updatedOrigin = value(c.origin[i])
            setValue!(c.origin[idx], updatedOrigin)
        end
    end

    ## The length of the path from the origin
    pathLength = value(c.lengthToDest[value(c.origin[i])])

    ## Remove variable i from the domain of it's successor to prevent a loop/cycle if the length < nVars
    if pathLength < c.nVars
        Variables.remove(c.vars[successor], i)
    end

    ## Throw an error if the length is greater than nVars
    if pathLength > c.nVars
        throw(DomainError("Length exceeds number of variables."))
    end
    
    ## Ensure there is a single SCC if the length = number of variables
    if pathLength == c.nVars
        !isCircuitSingleSCC(c.vars, nVars) && throw(DomainError("Multiple SCC's detected"))
    end

    return nothing
end


"""
    isCircuitSingleSCC(vars::Vector{<:AbstractVariable{T}}, n::Integer)::Bool where T

Function to ascertain that the returned Circuit is a single SCC
"""
function isCircuitSingleSCC(vars::Vector{<:AbstractVariable{T}}, n::Integer)::Bool where T
    ## Create a graph from the variables
    g = Utilities.Graph(n)

    ## Enforce the relationships by attaching nodes to their neighbours
    for (i, var) in enumerate(vars)
        Utilities.addNeighbour(g, i, minimum(var))
    end

    ## Run the SCC algorithm
    scc = Utilities.getStronglyConnectedComponents(g)

    ## Ascert that all variables belong to the same scc
    return length(Set(scc)) == 1
end


"""
    propagate(c::Circuit)::Nothing

Function to `propagate` the `Cicuit` constraint
"""
function propagate(c::Circuit)::Nothing
    _ = c

    return nothing
end