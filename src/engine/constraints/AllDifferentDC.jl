"""
    mutable struct AllDifferentDC{T} <: AbstractConstraint
        solver::AbstractSolver
        vars::AbstractVariable{T}
        nVars::Integer
        nVals::Integer

        maximalMatching::Utilities.MaximalMatching{T}
        numberOfNodes::Integer
        graph::Union{Utilities.Graph, Nothing}
        
        minVal::T
        maxVal::T
        
        variableMatch::Vector{Integer}
        valueMatched::Vector{Bool}

        active::State
        scheduled::Bool
    end

`AllDifferentDC` structure for the AllDifferent constraint that achieves domain consistency
"""
@with_kw mutable struct AllDifferentDC{T} <: AbstractConstraint
    solver::AbstractSolver
    vars::Vector{<:AbstractVariable{T}}
    nVars::Integer ## Number of variables
    nVals::Integer ## Number of values

    maximalMatching::Utilities.MaximalMatching{T}
    numberOfNodes::Integer ## Number of graph nodes
    graph::Union{Utilities.Graph, Nothing}
    
    minVal::T ## Store the minimum value
    maxVal::T ## Store the maximum value
    
    variableMatch::Vector{Integer} ## The value a variable at index i is matched to
    valueMatched::Vector{Bool}  ## Whether a value has been matched to a variable

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function AllDifferentDC{T}(vars::Vector{<:AbstractVariable{T}}) where T
        isempty(vars) && throw(DomainError("Variable vector must contain at least one variable"))
        ## Get the solver instance
        solver = Variables.solver(vars[1])
        ## Get the state manager
        sm = stateManager(solver)

        ## The number of variables
        nVars = length(vars)
        
        ## The maximal matching
        maximalMatching = Utilities.MaximalMatching{T}(vars)

        ## The match vector
        variableMatch = zeros(Int, nVars)

        ## Mark the constraint as active
        active = makeStateRef(sm, true)

        new{T}(solver, vars, nVars, 0, maximalMatching, 0, nothing, 0, 0, variableMatch, Bool[], active, false)
    end
end


"""
    post(c::AllDifferentDC)::Nothing

Function to `post` the `AllDifferentDC` constraint
"""
function post(c::AllDifferentDC)::Nothing
    ## Propagate this constraint when the domain of a variable changes
    for var in c.vars
        Variables.propagateOnDomainChange(var, c)
    end

    ## Update the range of values
    updateRange(c)

    ## Update the matched boolean vector
    c.valueMatched = fill(false, c.nVals)

    ## Update the number of nodes (1 is added for the dummy node's sake)
    c.numberOfNodes = c.nVars + c.nVals + 1

    ## Create a graph for this constraint
    c.graph = Utilities.Graph(c.numberOfNodes)
    
    ## Propage the constraint
    propagate(c)

    return nothing
end


"""
    updateRange(c::AllDifferentDC)::Nothing

Function to update the range of the values
"""
function updateRange(c::AllDifferentDC)::Nothing
    c.minVal = minimum(minimum.(c.vars))
    c.maxVal = maximum(maximum.(c.vars))

    ## Update the number of vals
    c.nVals = c.maxVal - c.minVal + 1

    return nothing
end


"""
    updateGraph(c::AllDifferentDC)::Nothing

Function used to update the `Graph` in the `AllDifferentDC` constraint
"""
function updateGraph(c::AllDifferentDC)::Nothing
    c.numberOfNodes = c.nVars + c.nVals + 1
    dummyNode = c.numberOfNodes ## The index of the dummy node

    ## Clear the graph nodes
    for node in 1:c.numberOfNodes
        Utilities.clear(c.graph, node)
    end

    ## TODO continue the implementation for representing the residual graph
    ## Get the matchings
    matchings = c.variableMatch
    ## Only used matching with a valid value
    for (variableNode, value) in enumerate(matchings)
        if value > 0
            ## Mark the value as being seen
            c.valueMatched[value] = true 
            ## Get the node index of that value
            valueNodeIdx = value + c.nVars
            ## Make the dummy pointer node point to this value already present in the matching
            Utilities.addNeighbour(c.graph, dummyNode, valueNodeIdx)
            ## Make the value nodes present in the matching point towards variable nodes present in the matching
            Utilities.addNeighbour(c.graph, valueNodeIdx, variableNode)
        end
    end
    ## Mark the respecive valueMatches as true - indicating they have matched variables
    # c.valueMatched[matchings] .= true

    ## Increase the returned values by nVars to get their node ids
    # matchings = c.nVars .+ matchings
    ## Make the dummy pointer node point to all values already present in the matching
    ## Utilities.addNeighbours(c.graph, dummyNode, matchings)

    ## Make all value nodes not present in the matching point to the dummy node
    for (i, v) in enumerate(c.valueMatched)
        if !v ## If the value isn't present in the matching, make the dummy node it's neighbour with an edge from itself
            Utilities.addNeighbour(c.graph, i + c.nVars, dummyNode)
        end
    end

    ## Make the value nodes present in the matching point towards variable nodes present in the matching
    # for (variableNode, valueNode) in enumerate(matchings)
    #     Utilities.addNeighbour(c.graph, valueNode, variableNode)
    # end

    ## Make variable nodes point to value nodes present in their domain but not present in the matching
    for (i, var) in enumerate(c.vars)
        ## Loop across the global minimum & maximum values
        for val in c.minVal:c.maxVal
            if in(val, var) ## If the value is still in the variable's domain
                ## If the variable's matching is not equal to val, add an edge from variable to value
                if c.variableMatch[i] != val
                    ## Increase the value of val by the number of variable nodes
                    Utilities.addNeighbour(c.graph, i, val + c.nVars)
                end
            end
        end
    end

    return nothing
end


"""
    propagate(c::AllDifferentDC)::Nothing

Function to `propagate` the `AllDifferentDC` constraint
"""
function propagate(c::AllDifferentDC)::Nothing
    ## TODO Implement the filtering
    ## hint: use maximumMatching.compute(match) to update the maximum matching
    sizeMatching = Utilities.compute(c.maximalMatching, c.variableMatch)

    ## If the size of the Matching is smaller than the number of variables, throw an InconsistencyException
    if sizeMatching != c.nVars
        throw(DomainError("Constraint violated. Returned matching size as $sizeMatching which is different than the variable size $(c.nVars)"))
    end
    ## If the matching is equal to the number of variables
    ##  use updateRange() to update the range of values
    updateRange(c)
    ##  use updateGraph() to update the residual graph
    updateGraph(c)
    ##  use  GraphUtil.stronglyConnectedComponents to compute SCC's
    scc = Utilities.getStronglyConnectedComponents(c.graph)

    ##  Remove elements based on SCC results; if the (x, a) are not in the same SCC
    for (i, var) in enumerate(c.vars)
        ## Check across all values in the min-max range
        for val in c.minVal:c.maxVal
            if in(val, var)
                ## If this isn't the currently matched value in the variable's domain, chech if they are in the same SCC
                if c.variableMatch[i] != val 
                    ## If x and a are in different SCCs, remove a from x's domain
                    if scc[i] != scc[val + c.nVars]
                        Variables.remove(var, val)
                    end
                end
            end
        end
    end

    return nothing
end