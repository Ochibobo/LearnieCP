"""
    @with_kw mutable struct AllDifferentFWC{T} <: AbstractConstraint
        solver::AbstractSolver
        vars::Vector{<:AbstractVariable{T}}
        nFixed::State ## Index of fixed variables
        fixed::Vector{<:Integer} ## Vector to store the fixed variables

        ## Constraint wide variables
        active::State
        scheduled::Bool
    end

`AllDifferentFWC` is the AllDifferent Forward Checking constraint
"""
@with_kw mutable struct AllDifferentFWC{T} <: AbstractConstraint
    solver::AbstractSolver
    vars::Vector{<:AbstractVariable{T}}
    nFixed::State ## Index of fixed variables
    fixed::Vector{<:Integer} ## Vector to store the fixed variables

    ## Constraint wide variables
    active::State
    scheduled::Bool

    function AllDifferentFWC{T}(vars::Vector{<:AbstractVariable{T}}) where T
        ## If an empty vars array is passed, throw an error
        isempty(vars) && throw(DomainError("variables vector cannot be empty!"))
        ## Get the solver instance
        solver = Variables.solver(vars[1])
        ## Get the state manager
        sm = stateManager(solver)
        ## The number of fixed variables is zero first
        nFixed = makeStateRef(sm, 1) ## Use 1 as index
        ## The fixed variables pointer
        fixed = collect(1:length(vars))

        ## Mark the constraint as being active
        active = makeStateRef(sm, true)

        new{T}(solver, vars, nFixed, fixed, active, false)
    end

    function AllDifferentFWC{T}(vars::Vararg{<:AbstractVariable{T}}) where T
        AllDifferentFWC{T}(collect(vars))
    end
end


"""
    post(c::AllDifferentFWC{T})::Nothing where T

Function to `post` the `AllDifferentFWC` constraint
"""
function post(c::AllDifferentFWC{T})::Nothing where T
    ## Mark all the variables with not equals
    for i in eachindex(c.vars)
        for j in (i + 1):length(c.vars)
            Solver.post(c.solver, NotEqual{T}(c.vars[i], c.vars[j]))
        end
    end

    return nothing
end


"""
    propagate(c::AllDifferentFWC)::Nothing

Function to `propagate` the `AllDifferentFWC` constraint
"""
function propagate(c::AllDifferentFWC)::Nothing
    nF = value(c.nFixed) ## Get the last index of the fixed variable

    for i in nF:length(c.vars)
        idx = c.fixed[i] ## Get the index stored at position i of the fixed array
        x = c.vars[idx] ## Get the associated variable represented by this index
        ## If the variable is fixed, swap it and advance the index of the fixed variables
        if isFixed(x)
            ## Swap it's index with the variable currently at nF
            c.fixed[i] = c.fixed[nF]
            c.fixed[nF] = idx

            ## Increase the size of nF
            nF += 1
        end
    end

    ## Set the value of the number of fixed indices
    setValue!(c.nFixed, nF)

    return nothing
end
