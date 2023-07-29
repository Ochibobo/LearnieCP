"""
    @with_kw mutable struct Sum{T} <: AbstractConstraint
        solver::AbstractSolver
        variables::Vector{AbstractVariable{T}}
        sumFixed::State{T}
        numberOfFixedVariables::State{Integer}
        min::Vector{T} ## To store the minimum value of variable i at index i
        max::Vector{T} ## To store the maximum value of variable i at index i
        fixedVariables::Vector{T}
        scheduled::Bool
        active::State


        function Sum{T}(variables::Vector{AbstractVariable{T}}) where T
            solver = Variables.solver(variables[1])
            sm = stateManager(solver)
            n = length(variables)
            
            ## Initialize the sum of fixed variables to 0
            sumFixed = makeStateRef(sm, zero(T))
            ## Initialize the number of unfixed variables to 0
            ## Used to split fixed | unfixed in the fixedVariables vector.
            numberOfFixedVariables = makeStateRef(sm, one(T))
            ## Vectors to store the minimum, maximum & fixed variable indices
            min = zeros(T, n)
            max = zeros(T, n)
            ## These are actually unfixed variables indices
            ## This vector is treated as a SparseSet
            fixedVariables = collect(1:n)
            ## The state
            active = makeStateRef(sm, true)

            new{T}(solver, variables, sumFixed, numberOfFixedVariables, min, max, fixedVariables, false, active)
        end

        ## Used to create a new Sum constraint where ∑variables = y
        function Sum{T}(variables::Vector{AbstractVariable{T}}, y::T) where T
            solver = Variables.solver(variables[0])
            yVar = Variables.IntVar(solver, -y, -y)

            vars = Vector{AbstractVariable{T}}()
            push!(vars, variables...)
            push!(vars, yVar)

            Sum{T}(vars)
        end

        ## Used to create a new Sum constraint where ∑variables = variable y
        function Sum{T}(variables::Vector{AbstractVariable{Integer}}, y::AbstractVariable{T}) where T
            vars = Vector{AbstractVariable{T}}()
            push!(vars, variables...)
            push!(vars, -y)

            Sum{T}(vars)
        end

        ## Used to create a Sum constraint using a variable number of arguments
        function Sum{T}(variables::Vararg{AbstractVariable{T}}) where T
            Sum{T}(collect(variables))
        end
    end

`Sum` constraint for variables Vector{AbstractVariable{T}}
"""
@with_kw mutable struct Sum{T} <: AbstractConstraint
    solver::AbstractSolver
    variables::Vector{AbstractVariable{T}}
    sumFixed::State{T}
    numberOfFixedVariables::State{Integer}
    min::Vector{T} ## To store the minimum value of variable i at index i
    max::Vector{T} ## To store the maximum value of variable i at index i
    fixedVariables::Vector{T}
    scheduled::Bool
    active::State


    function Sum{T}(variables::Vector{AbstractVariable{T}}) where T
        solver = Variables.solver(variables[1])
        sm = stateManager(solver)
        n = length(variables)
        
        ## Initialize the sum of fixed variables to 0
        sumFixed = makeStateRef(sm, zero(T))
        ## Initialize the number of unfixed variables to 0
        ## Used to split fixed | unfixed in the fixedVariables vector.
        numberOfFixedVariables = makeStateRef(sm, one(T))
        ## Vectors to store the minimum, maximum & fixed variable indices
        min = zeros(T, n)
        max = zeros(T, n)
        ## These are actually unfixed variables indices
        ## This vector is treated as a SparseSet
        fixedVariables = collect(1:n)
        ## The state
        active = makeStateRef(sm, true)

        new{T}(solver, variables, sumFixed, numberOfFixedVariables, min, max, fixedVariables, false, active)
    end

    ## Used to create a new Sum constraint where ∑variables = y
    function Sum{T}(variables::Vector{AbstractVariable{T}}, y::T) where T
        solver = Variables.solver(variables[0])
        yVar = Variables.IntVar(solver, -y, -y)

        vars = Vector{AbstractVariable{T}}()
        push!(vars, variables...)
        push!(vars, yVar)

        Sum{T}(vars)
    end

    ## Used to create a new Sum constraint where ∑variables = variable y
    function Sum{T}(variables::Vector{AbstractVariable{Integer}}, y::AbstractVariable{T}) where T
        vars = Vector{AbstractVariable{T}}()
        push!(vars, variables...)
        push!(vars, -y)

        Sum{T}(vars)
    end

    ## Used to create a Sum constraint using a variable number of arguments
    function Sum{T}(variables::Vararg{AbstractVariable{T}}) where T
        Sum{T}(collect(variables))
    end
end


"""
    post(c::Sum)::Nothing

Function used to post the `Sum` constraint
"""
function post(c::Sum)::Nothing
    vars = c.variables
    ## Propagate the constraint on bound change
    for v in vars
        propagateOnBoundChange(v, c)
    end

    ## Execute the propagate function as part of posting
    propagate(c)

    return nothing
end


"""
    propagate(c::Sum)::Nothing

Function used to propagate the `Sum` constraint
"""
function propagate(c::Sum)::Nothing
    ## Get the number of unfixed variables
    nF = value(c.numberOfFixedVariables)
    ## Get the partial sum to be updated
    sumMin = value(c.sumFixed)
    sumMax = value(c.sumFixed)

    ## Loop through all unfixed/unbounded variables and update the partial sum encountered so far
    ## in case one of the variables becomes fixed
    for i in nF:length(c.variables)
        ## Retreive the index of the unfixed variable
        idx = c.fixedVariables[i] ## Elents at i may as well be unfixed
        ## Get the minimum & maximum of this variable
        c.min[idx] = minimum(c.variables[idx])
        c.max[idx] = maximum(c.variables[idx])
        ## Update the minimum & maximum partial sums accordingly
        sumMax += c.max[idx]
        sumMin += c.min[idx]
        ## Check if the variable is fixed
        if Variables.isFixed(c.variables[idx])
            ## Update the partial sum so far
            setValue!(c.sumFixed, value(c.sumFixed) + minimum(c.variables[idx]))
            ## Mark the variable as index i as being fixed
            c.fixedVariables[i] = c.fixedVariables[nF]
            c.fixedVariables[nF] = idx
            ## Increment the number of fixed variables
            nF += 1
        end
    end

    ## Update the number of fixed variables
    setValue!(c.numberOfFixedVariables, nF)

    ## Assert that the condition of min <= 0 <= max still stands
    if !(sumMin <= 0 <= sumMax)
        throw(DomainError("Invalid summation"))
    end

    ## Filter over the remaining non-fixed variables
    ## Update their bounds as need be 
    for i in nF:length(c.variables)
        idx = c.fixedVariables[i]
        ## Update the maximum
        Variables.removeAbove(c.variables[idx], -sumMin + c.min[idx])
        ## Update the minimum
        Variables.removeBelow(c.variables[idx], -sumMax + c.max[idx])
    end

    return nothing
end