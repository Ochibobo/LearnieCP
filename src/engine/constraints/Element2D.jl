## Element2D Constraint Definition

"""
    @with_kw struct Tripple{T}
        x::T
        y::T
        z::T
    end

`Tripple` struct to capture the table comprising of `zxy` for the `Element2D` constraint
"""
@with_kw struct Tripple{T}
    x::T
    y::T
    z::T
end


@with_kw mutable struct Element2D{T} <: AbstractConstraint
    solver::AbstractSolver
    matrix::Matrix{T}
    x::AbstractVariable{T}
    y::AbstractVariable{T}
    z::AbstractVariable{T}
    zxy::Vector{Tripple{T}}
    nRows::Integer
    nCols::Integer
    topPointer::StateInt
    bottomPointer::StateInt

    ## Row & Column counters reflecting the domain size of the variables left by row & column
    nColSup::Vector{StateInt}
    nRowSup::Vector{StateInt}

    ## Active and schedule variables related to all constraints
    active::State
    scheduled::Bool

    function Element2D{T}(matrix::Matrix{T}, x::AbstractVariable{T}, y::AbstractVariable{T}, z::AbstractVariable{T}) where T
        ## Get the solver instance
        solver = Variables.solver(x)
        ## Get the state manager
        sm = stateManager(solver)
        
        ## Get the number of rows & columns the matrix has (columns are most likely just 2)
        nRows = size(matrix, 1)
        nCols = size(matrix, 2)

        ## Fill the zxy vector with appropriate Tripple values
        zxy = Vector{Tripple{T}}(undef, nRows * nCols)
        idx = 1
        for (ii, v) in enumerate(eachrow(matrix))
            for jj in eachindex(v)
                zxy[idx] = Tripple{T}(x = ii, y = jj, z = matrix[ii, jj])
                idx =  idx + 1
            end
        end

        ## Sort the zxy vector
        sort!(zxy, by = t -> t.z)

        ## Initialize the top and bottom pointers
        topPointer = makeStateInt(sm, 1)
        bottomPointer = makeStateInt(sm, length(zxy))

        ## Initialize the nColSup & nRowSup
        ## nRowSup has each entry comprising of a StateInt with a domain size = nCols, with 
        nRowsSup = Vector{StateInt}(undef, nRows)
        for i in 1:nRows
            nRowsSup[i] = makeStateInt(sm, nCols)
        end

        ## nColSup has each entry comprising of a StateInt with a domain size = nRows
        nColSup = Vector{StateInt}(undef, nCols)
        for i in 1:nCols
            nColSup[i] = makeStateInt(sm, nRows)
        end

        ## Active state
        active = makeStateRef(sm, true)

        ## Return a new instance of the Element2D vector
        new{T}(solver, matrix, x, y, z, zxy, nRows, nCols, 
                bottomPointer, topPointer, nColSup, nRowsSup, active, false)
    end
end


"""
    post(c::Element2D)::Nothing

Function to `post` the `Element2D` constraint
"""
function post(c::Element2D)::Nothing
    ## Assert that the domains of x and y are between n & m respectively
    Variables.removeBelow(c.x, 1) ## Should it be 0 or 1??
    Variables.removeAbove(c.x, c.nRows)
    Variables.removeBelow(c.y, 1)
    Variables.removeAbove(c.y, c.nCols)

    ## Post this constraint on change in the domain values of x & y 
    propagateOnDomainChange(c.x, c)
    propagateOnDomainChange(c.y, c)

    ## Post this constraint on change in the bounds of z
    propagateOnBoundChange(c.z, c)

    ## Perform the first propagation
    propagate(c)

    return nothing
end


"""
    updateSupport(lost::Integer)::Nothing

Function to update the support values
"""
function updateSupport(c::Element2D, lost::Integer)::Nothing
    decrement(c.nRowSup[c.zxy[lost].x])
    currentRowSup = value(c.nRowSup[c.zxy[lost].x])

    if currentRowSup == 0
        Variables.remove(c.x, c.zxy[lost].x)
    end

    decrement(c.nColSup[c.zxy[lost].y])
    currentColSup = value(c.nColSup[c.zxy[lost].y])
    
    if currentColSup == 0
        Variables.remove(c.y, c.zxy[lost].y)
    end

    return nothing
end


"""
    propagate(c::Element2D)::Nothing

Function to `propagate` the `Element2D` constraint
"""
function propagate(c::Element2D)::Nothing
    ## Get the current values of the bottom & top pointers
    l = value(c.bottomPointer) 
    u = value(c.topPointer)

    ## Get the current min & max of z
    zMin = minimum(c.z)
    zMax = maximum(c.z)

    ## Update the low pointer and x values
    while c.zxy[l].z < zMin || !Variables.in(c.zxy[l].x, c.x) || !Variables.in(c.zxy[l].y, c.y)
        updateSupport(c, l)
        l += 1
        if l > u
            throw(DomainError("l > u"))
        end
    end
    
    ## Update the upper pointer and y values
    while c.zxy[u].z > zMax || !Variables.in(c.zxy[u].x, c.x) || !Variables.in(c.zxy[u].y, c.y)
        updateSupport(c, u)
        u -= 1
        if l > u 
            throw(DomainError("l > u"))
        end
    end

    ## Update the z values
    Variables.removeBelow(c.z, c.zxy[l].z)
    Variables.removeAbove(c.z, c.zxy[u].z)

    ## Update the bottom & top pointers
    setValue!(c.bottomPointer, l)
    setValue!(c.topPointer, u)

    return nothing
end


"""
    element2D(matrix::Matrix{T}, x::AbstractVariable{T}, y::AbstractVariable{T})::AbstractVariable{T} where T

Helper function for the `Element2D` constraint. It returns the variable `z`
"""
function element2D(matrix::Matrix{T}, x::AbstractVariable{T}, y::AbstractVariable{T})::AbstractVariable{T} where T
    ## Get the minimum & maximum matrix values
    min = minimum(matrix)
    max = maximum(matrix)
    
    ## Create the variable z
    solver = Variables.solver(x)
    z = Variables.IntVar(solver, min, max)

    ## Post the Element2D constraint - register it to x, y & z variables
    Solver.post(solver, Element2D{T}(matrix, x, y, z))

    ## Return the element Z
    return z
end