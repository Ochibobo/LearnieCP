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
    numberOfFixed::StateInt
    fixed::Vector{Integer}

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

        ## Set the number of fixed (index of fixed)
        numberOfFixed = makeStateInt(sm, 1)
        ## Set the various variable indices in the fixed variables vector
        fixed = Vector{Integer}(collect(1:nVars))

        ## Fill the destination, source and lengthToDest vectors
        for i in 1:length(vars)
            dest[i] = makeStateInt(sm, i)
            src[i] = makeStateInt(sm, i)
            lengthToDest[i] = makeStateInt(sm, 0)
        end

        ## Mark the constraint as being active
        active = makeStateRef(sm, true)

        new{T}(solver, vars, nVars, dest, src, lengthToDest, numberOfFixed, fixed, active, false)
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
        ## Run fix if var is already fixed
        if Variables.isFixed(var)
            fix(c, i)
        end
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
    
    for idx in eachindex(c.vars)
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
    if pathLength < c.nVars - 1
        Variables.remove(c.vars[successor], i)
    end
    
    # Update the fixed variables
    nF = value(c.numberOfFixed) ## The number of fixed so far
    for k in nF:c.nVars
        idx = c.fixed[k] 
        var = c.vars[idx]
        ## If the variable is fixed, swap
        if isFixed(var)
            c.fixed[k] = c.fixed[nF]
            c.fixed[nF] = idx

            ## Increase nF
            nF += 1
        end
    end

    setValue!(c.numberOfFixed, nF)

    ## Ensure there is a single SCC if the all variables are fixed
    if value(c.numberOfFixed) == c.nVars
        !isCircuitSingleSCC(c.vars, c.nVars) && throw(DomainError("Multiple SCC's detected"))
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