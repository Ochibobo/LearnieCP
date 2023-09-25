"""
    @with_kw mutable struct TableCT{T} <: AbstractConstraint
        solver::AbstractSolver
        vars::Vector{<:AbstractVariable{T}}
        table::Matrix{T}
        supports::Vector{Vector{BitVector}}

        active::State
        scheduled::Bool
    end

The `Table` constraint
"""
@with_kw mutable struct TableCT{T} <: AbstractConstraint
    solver::AbstractSolver
    vars::Vector{<:AbstractVariable{T}}
    table::Matrix{T}
    supports::Vector{Vector{BitVector}}
    lastDomSize::Vector{StateInt}

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function TableCT{T}(vars::Vector{<:AbstractVariable}, table::Matrix{<:T}) where T
        isempty(vars) && throw(DomainError("vars cannot be empty"))
        isempty(table) && throw(DomainError("table cannot be empty"))

        ## Get the solver instance
        solver = Variables.solver(vars[1])
        ## Get the state manager instance
        sm = stateManager(solver)
        ## Get the number of variables
        nVars = length(vars)
        ## Define the support bits
        supports = Vector{Vector{BitVector}}()
        ## Define an array x
        x = Vector{AbstractVariable{T}}(undef, nVars)
        
        ## Create the bitvector entries
        for i in eachindex(vars)
            ## Copy vars to x having each element normalized based on its minimum value
            x[i] = vars[i] - minimum(vars[i]) ## Values start at 0
            push!(supports, Vector{BitVector}(undef, (maximum(x[i] - minimum(x[i]) + 1))))
            ## Fill the support arrays with Bitsets
            for j in eachindex(supports[i])
                ## Fill the supports with BitVectors
                supports[i][j] = falses(length(supports[i]))
            end
        end

        ## Mark the BitVetor entries based on the values in the table
        for t in 1:size(table)[1]
            for i in eachindex(x)
                ## Get the value from the table
                v = table[t, i]
                println("t = $t, i = $i, v = $v")
                ## Check if the value is contained in the variable's domain
                if Variables.in(v, x[i])
                    idx = (v - minimum(x[i])) + 1
                    ## Mark the bit as 1
                    setindex!(supports[i][idx], true, idx)
                end
            end
        end

        ## An array to store the last domain size of each of the X elements
        lastDomSize = Vector{StateInt}(undef, nVars)

        ## Global constraints variable
        active = makeStateRef(sm, true)

        new{T}(solver, x, table, supports, lastDomSize, active, false)
    end
end


"""
    post(c::Table)::Nothing

Function to `post` the `Table` constraint
"""
function post(c::TableCT)::Nothing
    ## Propagate this constraint on domain change
    for v in c.vars
        propagateOnDomainChange(v, c)
    end

    ## Run a propagation
    propagate(c)
    
    return nothing
end


"""
    hasChanged(c::TableCT, i::Int)::Bool

`hasChanged` function to check if the domain size of an element has changed
"""
function hasChanged(c::TableCT, i::Int)::Bool
    ## Check if the last stored domain size differs from the current variable's size
    return value(c.lastDomSize[i]) != size(c.vars[i])
end


"""
    propagate(c::Table{T})::Nothing where T

Function to `propagate` the `Table` constraint
"""
function propagate(c::TableCT{T})::Nothing where T
    ## An instance of the supportedTuples
    supportedTuples = falses(length(c.table)) ## Marked all as 0 bits

    ## Update the supported tuple based on changed vars, if any
    for i in eachindex(c.vars)
        ## Check if the domain size has changed
        if hasChanged(c, i)
            ## Perform an and between the changed variable and the supportedTuples
            ## supportedTuples &= (supports[i][x[i].min()] | ... | supports[i][x[i].max()] )
            ## for all x[i] modified since last call node in the search tree
            for j in eachindex(minimum(c.vars[i]):maximum(c.vars[i]))
                ## Only attempt an and when the value of `j` is in the domain of c.vars[i]
                if(in(j, c.vars[i]))
                    ## & the supportedTuples and the supports[i][j]
                    supportedTuples .&= c.supports[i][j] ## Consider the implication of this and
                end
            end
        end
    end

    ## Update the domain of a variable i in vars[i] is it is no longer in the supportedTuples
    for i in eachindex(c.vars)
        ## Collect the values in a vector
        domainValues = Vector{T}()
        Variables.fillArray(c.vars[i], domainValues)

        ## Check if the domain value is part of the support, remove it if not
        for v in eachindex(domainValues)
            if supportedTuples .& c.supports[i][domainValues[v]] ## Consider the implication of this and
                Variables.remove(x[i], v)
            end
        end
    end

    return nothing
end