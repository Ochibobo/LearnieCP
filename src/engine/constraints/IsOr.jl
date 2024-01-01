"""
    @with_kw mutable struct IsOr <: AbstractConstraint
        solver::AbstractSolver
        b::BoolVar
        bVars::Vector{BoolVar}

        ## The Or constraint
        or::Or

        ## Variables to keep track of fixed & unfixed variables
        nUf::StateInt
        unFixed::Vector{Int}

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function IsOr(b::BoolVar, bVars::Vector{BoolVar})
            isempty(bVars) && throw(ArgumentError("bVars cannot be an empty vector"))

            ## Get the solver instance
            solver = Variables.solver(bVars[1])

            sm = stateManager(solver)

            or = Or(bVars)

            nUf = makeStateRef(sm, length(bVars))
            unFixed = collect(1:length(bVars))
        
            active = makeStateRef(sm, true)

            new(solver, b, bVars, or, nUf, unFixed, active, false)
        end
    end

`IsOr` constraint structure using a reified `BoolVar`.
"""
@with_kw mutable struct IsOr <: AbstractConstraint
    solver::AbstractSolver
    b::BoolVar
    bVars::Vector{BoolVar}

    ## The Or constraint
    or::Or

    ## Variables to keep track of fixed & unfixed variables
    nUf::StateInt
    unFixed::Vector{Int}

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function IsOr(b::BoolVar, bVars::Vector{BoolVar})
        isempty(bVars) && throw(ArgumentError("bVars cannot be an empty vector"))

        ## Get the solver instance
        solver = Variables.solver(bVars[1])

        sm = stateManager(solver)

        or = Or(bVars)

        nUf = makeStateRef(sm, length(bVars))
        unFixed = collect(1:length(bVars))
    
        active = makeStateRef(sm, true)

        new(solver, b, bVars, or, nUf, unFixed, active, false)
    end
end


"""
    post(c::IsOr)::Nothing

Function to `post` the `IsOr` constraint
"""
function post(c::IsOr)::Nothing
    propagate(c)

    if value(c.active)
        ## Add a listener if the constraint is active
        propagateOnFix(c.b, c)

        for bVar in c.bVars
            propagateOnFix(bVar, c)
        end
    end

    return nothing
end


"""
    propagate(c::IsOr)::Nothing

Function to `propagate` the `IsOr` constraint
"""
function propagate(c::IsOr)::Nothing
    if Variables.isTrue(c.b)
        ## Post the Or constraint
        Solver.post(c.solver, c.or)
        ## Deactivate the constraint
        setValue!(c.active, false)
    elseif Variables.isFalse(c.b)
        ## Set all variables to false
        for bVar in c.bVars
            Variables.fix(bVar, false)
        end
        ## Deactivate the constraint
        setValue!(c.active, false)
    else
        ## Get the number of unfixed variables
        numberOfUnfixed = value(c.nUf)

        if numberOfUnfixed > 0
            for i in numberOfUnfixed:1
                idx = c.unFixed[i]
                ## Get the boolvar instance
                bVar = c.bVars[idx]

                if Variables.isFixed(bVar)
                    if Variables.isTrue(bVar)
                        ## Mark `b` as true
                        Variables.fix(c.b, true)
                        ## Deactivate the constraint
                        setValue!(c.active, false)

                        return nothing
                    end

                    ## Swap the elements
                    c.unFixed[i] = c.unFixed[numberOfUnfixed]
                    c.unFixed[numberOfUnfixed] = idx 
                    numberOfUnfixed -= 1
                end
            end
        else
            Variables.fix(c.b, false)
            ## Deactivate the constraint
            setValue!(c.active, false)
        end

        ## Update the number of unfixed
        setValue!(c.nUf, numberOfUnfixed)
    end

    return nothing
end