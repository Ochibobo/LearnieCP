"""
    NONE = typemin(Int)

`NONE` representation used to show that a variable is a `free` variable
"""
const NONE = typemin(Int)


"""
    mutable struct MaximalMatching{T}
        vars::Vector{<:AbstractVariable{T}}
        nVars::Integer
        min::T ## Global minimum  
        max::T ## Global maximum

        sizeMatching::Integer ## Number of matching elements

        ## For each variable, the setValue it is matched to
        match::Vector{Integer}
        varSeen::Vector{Integer}

        ## The number of values
        valSize::Int

        ## For each setValue, the variable index matched to it's setValue, -1 if none
        valMatch::Vector{Integer}
        valSeen::Vector{Integer}

        magic::Integer
    end

Structure definition of the `MaximalMatching` object
"""
mutable struct MaximalMatching{T}
    vars::Vector{<:AbstractVariable{T}}
    nVars::Integer
    min::T ## Global minimum  
    max::T ## Global maximum

    sizeMatching::Integer ## Number of matching elements

    ## For each variable, the setValue it is matched to
    match::Vector{Integer}
    varSeen::Vector{Integer}

    ## The number of values
    valSize::Int

    ## For each setValue, the variable index matched to it's setValue, -1 if none
    valMatch::Vector{Integer}
    valSeen::Vector{Integer}

    magic::Integer

    function MaximalMatching{T}(vars::Vector{<:AbstractVariable{T}}) where T
        nVars = length(vars)
        ## The values set maximum and minimum range
        minVal = minimum(Variables.minimum.(vars))
        maxVal = maximum(Variables.maximum.(vars))

        ## Update the size of the value set
        valSize = maxVal - minVal + 1
        
        ## Update the values matched set
        valMatch = fill(-1, valSize) ## -1 symbolizing unmatched

        ## Initialze the match values
        match = fill(NONE, length(vars))

        varSeen = zeros(Int, length(vars))
        valSeen = zeros(Int, valSize)

        mxMatching = new{T}(vars, nVars, minVal, maxVal, 0, match, varSeen, valSize, valMatch, valSeen, 0)

        ## Perform the initial matching
        findInitialMatching(mxMatching)

        ## Return an instance of the maximal matching
        mxMatching
    end
end


"""
    compute(g::MaximalMatching, results::Vector{Integer})::Integer

Function to execute the maximumal matching process and compute the size of the matching. Store withing the result vector the value the variable
at index `i` is matched to.
"""
function compute(g::MaximalMatching, results::Vector{Integer})::Integer
    ## Update the matching if variable values have changed
    for i in eachindex(g.vars)
        ## Check if the value initial matched to variable at i is still part of its domain
        if g.match[i] != NONE
            if !in(g.match[i], g.vars[i])
                ## Reset the matched edges
                g.valMatch[(g.match[i] - g.min) + 1] = -1
                g.match[i] = NONE
                ## Reduce the size of the matching
                g.sizeMatching -= 1
            end
        end
    end

    ## Find the size of the maximal matching
    sizeMatching = findMaximalMatching(g)

    ## Copy the values in match to the passed results array
    for (i, v) in enumerate(g.match)
        results[i] = v
    end

    return sizeMatching
end


"""
    findInitialMatching(g::MaximalMatching)::Nothing

Function to get the size of the initial matching
"""
function findInitialMatching(g::MaximalMatching)::Nothing
    ## Set the initial matching size to zero first
    g.sizeMatching = 0

    for k in eachindex(g.vars)
        var = g.vars[k]
        ## Get the minimum & maximum of the current variable
        minVal = minimum(var)
        maxVal = maximum(var)
        
        ## Check if the current variable is matched to any value of it's domain
        for i in minVal:maxVal
            idx = (i - g.min) + 1 ## The difference may be zero, add 1 for Julia indexing
            if(g.valMatch[idx] < 0) ## This means the value is not yet matched
                ## Check if the value is in the variable's domain
                if in(i, var)
                    ## Show the variable is matched to the value i
                    g.match[k] = i
                    ## Show that the value is matched to variable k
                    g.valMatch[idx] = k
                    ## Increase the size of the matching
                    g.sizeMatching += 1
                    ## Exit this inner loop
                    break
                end
            end
        end
    end
    
    return nothing
end


"""
    findMaximalMatching(g::MaximalMatching)::Nothing

Function to find the maximal matching
"""
function findMaximalMatching(g::MaximalMatching)::Integer
    ## Find maximal if the current size matching is less than the number of variables
    if g.sizeMatching < g.nVars
        ## Loop through all vertices to try and find alternating paths and re-augment them
        for i in eachindex(g.vars)
            ## If the variable is yet to be matched, attempt to find an alternating path from it
            if g.match[i] == NONE ## This is a free-variable vertex
                ## Increase the magic number
                g.magic += 1
                if findAlternatingPathFromVariable(g, i)
                    g.sizeMatching += 1
                end
            end
        end
    end

    return g.sizeMatching
end


"""
    findAlternatingPathFromVariable(g::MaximalMatching, node::Integer)::Nothing

Function to find the alternating path from a variable in the variable-set
"""
function findAlternatingPathFromVariable(g::MaximalMatching, nodeIdx::Integer)::Bool
    ## If the variable seen is not equal to the current iteration or hasn't been visited, keep seeking a path
    if g.varSeen[nodeIdx] != g.magic
        g.varSeen[nodeIdx] = g.magic
        ## Get the maximum and minimum values of the variable
        xMin = minimum(g.vars[nodeIdx])
        xMax = maximum(g.vars[nodeIdx])
        ## Loop through the domain of the variable at nodeIdx
        for v in xMin:xMax
            if g.match[nodeIdx] != v 
                ## Assert that v in in the variable's domain
                if in(v, g.vars[nodeIdx])
                    ## If the variable isn't matched to the current value in the variable's domain, find an alternating path
                    if findAlternatingPathFromValue(g, v)
                        ## If an alternating path is found, map the var to the value and the value to the var
                        g.match[nodeIdx] = v
                        g.valMatch[(v - g.min) + 1] = nodeIdx
                        return true
                    end
                end
            end
        end
    end

    return false
end


"""
    findAlternatingPathFromValue(g::MaximalMatching, value::Integer)::Nothing

Function to find the alternating path from a value in the value-set
"""
function findAlternatingPathFromValue(g::MaximalMatching, value::Integer)::Bool
    idx = (value - g.min) + 1
    ## Assert that it's a free value
    if g.valSeen[idx] != g.magic
        g.valSeen[idx] = g.magic
        ## Return true if the current value is a free value node
        if g.valMatch[idx] == -1
            return true
        end
        ## Attempt to find an alternating path from variable this value points to otherwise
        if findAlternatingPathFromVariable(g, g.valMatch[idx])
            return true
        end
    end

    return false
end