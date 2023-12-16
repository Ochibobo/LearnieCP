"""
    @with_kw mutable struct Disjunctive{T} <: AbstractConstraint
        solver::AbstractSolver
        startTimes::Vector{<:AbstractVariable{T}}
        durations:: Vector{<:T}
        endTimes::Vector{<:AbstractVariable{T}}
        
        permLct::Vector{<:T}
        permEst::Vector{<:T}
        rankEst::Vector{<:T}
        startMin::Vector{<:T}
        endMax::Vector{<:T}
        
        thetaTree::Utilities.ThetaTree
        postMirror::Bool

        ## Constraint wide variables
        active::State
        scheduled::Bool

        function Disjunctive{T}(startTimes::Vector{<:AbstractVariable{T}}, durations::Vector{<:T}; postMirror = true) where T
            (isempty(startTimes) || isempty(durations) || (length(startTimes) != length(durations))) &&
                throw(DomainError("startTimes & durations need be of equal non-zero lengths")) 
            ## Get the solver instance
            solver = Variables.solver(startTimes[1])
            ## Get the state manager instance
            sm = stateManager(solver)

            ## Get the number of variables
            nVars = length(startTimes)

            ## EndTimes variable creation
            endTimes = map(i -> startTimes[i] + durations[i], 1:nVars)

            startMin = zeros(T, nVars)
            endMax = zeros(T, nVars)
            permEst = map(i -> i, 1:nVars)
            permLct = map(i -> i, 1:nVars)
            rankEst = zeros(T, nVars)

            ## Create an instance of the ThetaTree
            thetaTree = Utilities.ThetaTree{T}(nVars)

            active = makeStateRef(sm, true)

            new{T}(solver, startTimes, durations, endTimes, permLct, permEst, rankEst, startMin, endMax, thetaTree, postMirror, active, false)
        end
    end

`Disjunctive` constraint structure used to ensure that any two pairs of activities cannot overlap in time. That means, for activities `i`
and `j`, `startTimes[i] + durations[i] <= startTimes[j] + durations[j]` or `startTimes[j] + durations[j] <= startTimes[i] + durations[i]`

`solver` - is the solver instance

`startTimes` is the set of all activity start times

`durations` is the set of each activity's durations

`endTimes` is the set of all activity end times

`nVars` is the number of variables = number of activities

`permLct` is the index permutation of latest completion times

`permEst` is the index permutation of startTimes vector sorted by the est

`rankEst` is the ordering of each est - subject to confirmation 

`startMin` is the set of each activity's earliest start times

`endMax` is the set of each activity's latest completion times

`thetaTree` is the `ThetaTree` instance used in the feasibility computations

`postMirror` is a boolean to indicate whether the constraint should be posted for the inverse of the `startTimes`
"""
@with_kw mutable struct Disjunctive{T} <: AbstractConstraint
    solver::AbstractSolver
    startTimes::Vector{<:AbstractVariable{T}}
    durations:: Vector{<:T}
    endTimes::Vector{<:AbstractVariable{T}}
    nVars::Int
    
    permLct::Vector{<:T}
    permEst::Vector{<:T}
    rankEst::Vector{<:T}
    startMin::Vector{<:T}
    endMax::Vector{<:T}
    
    thetaTree::Utilities.ThetaTree
    postMirror::Bool

    ## Constraint wide variables
    active::State
    scheduled::Bool

    function Disjunctive{T}(startTimes::Vector{<:AbstractVariable{T}}, durations::Vector{<:T}; postMirror = true) where T
        (isempty(startTimes) || isempty(durations) || (length(startTimes) != length(durations))) &&
            throw(DomainError("startTimes & durations need be of equal non-zero lengths")) 
        ## Get the solver instance
        solver = Variables.solver(startTimes[1])
        ## Get the state manager instance
        sm = stateManager(solver)

        ## Get the number of variables
        nVars = length(startTimes)

        ## EndTimes variable creation
        endTimes = map(i -> startTimes[i] + durations[i], 1:nVars)

        startMin = zeros(T, nVars)
        endMax = zeros(T, nVars)
        permEst = map(i -> i, 1:nVars)
        permLct = map(i -> i, 1:nVars)
        rankEst = zeros(T, nVars)

        ## Create an instance of the ThetaTree
        thetaTree = Utilities.ThetaTree{T}(nVars)

        active = makeStateRef(sm, true)

        new{T}(solver, startTimes, durations, endTimes, nVars, permLct, permEst, rankEst, startMin, endMax, thetaTree, postMirror, active, false)
    end
end


"""
    post(c::Disjunctive{T})::Nothing where T

Function to `post` the `Disjunctive` constraint
"""
function post(c::Disjunctive{T})::Nothing where T
    for var in c.startTimes
        propagateOnBoundChange(var, c)
    end

    # demands = fill(1, c.nVars)

    # Solver.post(c.solver, Cumulative{T}(c.startTimes, c.durations, demands, 1))
    
    for i in 1:c.nVars
        for j in (i + 1):c.nVars
            Solver.post(c.solver, 
                DisjunctiveBinary{T}(c.startTimes[i], c.endTimes[i],
                                    c.startTimes[j], c.endTimes[j]))
            
        end
    end
    
    ## Post the DisjunctiveBinary constraint
    ## Post mirror
    if c.postMirror
        startMirror = map(var -> -var, c.endTimes)

        Solver.post(c.solver, Disjunctive{T}(startMirror, c.durations, postMirror = false), enforceFixpoint = false)
    end

    ## Perform the initial propagation
    propagate(c)

    return nothing
end


"""
    propagate(c::Disjunctive{T})::Nothing where T

Function to `propagate` the `Disjunctive` constraint
"""
function propagate(c::Disjunctive{T})::Nothing where T
    changed = true

    while changed
        ## Perform the overload check
        overloadCheck(c)
        ## Perform the detectable precedence
        changed = detectablePrecedence(c)
        ## NotLast filtering
        changed = changed || notLast(c)
    end

    return nothing
end


"""
    update!(c::Disjuctive)::Nothing

Function used to update the `permEst`, `rankEst`, `startMin` and `endMax`
"""
function update!(c::Disjunctive)::Nothing
    ## Sort based on the est of each activity
    c.permEst = sortperm(c.startTimes, by = v -> minimum(v))
    for i in 1:c.nVars
        ## Assess this move
        c.rankEst[c.permEst[i]] = i
        ## Store the est of i
        c.startMin[i] = minimum(c.startTimes[i])
        ## Store the lct of i
        c.endMax[i] = maximum(c.endTimes[i])
    end

    return nothing
end


"""
    overloadCheck(c::Disjuctive)::Nothing

Function used to check if the left cut of any activity has `earlieast start time` + `processing time` > `latest completion time`. 
If so, throw an error. Else, the validation is completely ok.
"""
function overloadCheck(c::Disjunctive)::Nothing
    ## Start by updating the est
    update!(c)

    ## Get the index permutation of the sorted lct - this nesting improves the feasibility check
    c.permLct = sortperm(c.endTimes, by = v -> maximum(v))

    ## Reset the ThetaTree
    reset(c.thetaTree)

    ## Loop through activities based on the sorted lst while performing the overload check
    for i in 1:c.nVars
        activity = c.permLct[i]
        ## Insert the activity into the theta tree
        insert!(c.thetaTree, c.rankEst[activity], minimum(c.endTimes[activity]), c.durations[activity])
        ## Check if the ect of the theta tree is greater than the lct of activity i
        if Utilities.ect(c.thetaTree) > maximum(c.endTimes[activity])
            throw(DomainError("Overload Check violated"))
        end
    end
end


"""
    detectablePrecedence(c::Disjuctive)::Bool

Function used to detect the `earliest start time` of a set of activities.

Returns a boolean to indicate if any variable changed during the feasibility check
"""
function detectablePrecedence(c::Disjunctive)::Bool
    update!(c)
    ## Sort activities based on the lst
    lst_sorted = sortperm(c.startTimes, by = v -> maximum(v))
    ## Sort activities based on the ect
    ect_sorted = sortperm(c.endTimes, by = v -> minimum(v))

    ## Create an iterator for activities based on the latest start time
    j_idx = 1
    j = lst_sorted[j_idx] ## Candidate precedence of i
    
    ## Initialize the theta-tree
    reset(c.thetaTree)

    ## Boolean to indicate whether any variable has changed
    changed = false

    ## Check if activity is seen
    activity_seen = falses(c.nVars)

    ## Loop through activities based on the sorted earliest completion time
    for i in eachindex(ect_sorted)
        ## Retrieve the most recent activity
        activity = ect_sorted[i]
        
        ## Insert values into the thetaTree as long as est_i + p_i > lst_j
        while j_idx <= c.nVars && minimum(c.endTimes[activity]) > maximum(c.startTimes[lst_sorted[j_idx]])
            j = lst_sorted[j_idx]
            ## Mark an activity as being seen
            activity_seen[j] = true
            ## Insert activity `j` into the thetaTree
            insert!(c.thetaTree, c.rankEst[j], minimum(c.endTimes[j]), c.durations[j])
            j_idx += 1
        end

        ## Start by removing activity from the ThetaTree
        if activity_seen[activity] 
            delete!(c.thetaTree, c.rankEst[activity])
        end

        ## Update the earliest start time of activity
        c.startMin[activity] = max(Utilities.ect(c.thetaTree), c.startMin[activity])

          ## Re-insert the activity if it was seen during this operation
        if activity_seen[activity]
            insert!(c.thetaTree, c.rankEst[activity], minimum(c.endTimes[activity]), c.durations[activity])
        end
    end

    for i in 1:c.nVars
        changed = changed || (c.startMin[i] > minimum(c.startTimes[i]))
        Variables.removeBelow(c.startTimes[i], c.startMin[i])
    end

    return changed
end


"""
    notLast(c::Disjuctive)::Bool

Function to enforce the `notLast` feasibility check that ensures an activity is not placed as the last one if by so doing we will 
violate the activity's deadline by going beyond it.

Returns a boolean indicating if any variable was changed during the check.
"""
function notLast(c::Disjunctive)::Bool
    update!(c)
    ## Sort activities according to the latest start time
    lst_sorted = sortperm(c.startTimes, by = v -> maximum(v))
    ## Sort activities according to the latest completion time
    lct_sorted = sortperm(c.endTimes, by = v -> maximum(v))

    ## Get a referenct to the element with the smallest lst
    idx = 1
    k = lst_sorted[idx]
    ## This leeps a reference to the last element to be processed from the lct_sorted list
    j = 0

    ## For each activity i, the ThetaTree will contains the NLSet(T, i)
    reset(c.thetaTree)

    ## Boolean to indicate if any variable changed
    changed = false

    ## Check if this activity is added to the ThetaTree in this loop
    activity_seen = falses(c.nVars)

    ## Loop through the activities in the lct sorted order
    for i in eachindex(lct_sorted)
        ## Get the activity in reference
        activity = lct_sorted[i]

        ## Insert the elements into the thetatree to make it equal to the NLSet(T, i)
        while idx <= c.nVars && maximum(c.endTimes[activity]) > maximum(c.startTimes[lst_sorted[idx]])
            k = lst_sorted[idx]
            activity_seen[k] = true
            ## Insert activity k into the ThetaTree
            insert!(c.thetaTree, c.rankEst[k], minimum(c.endTimes[k]), c.durations[k])
            ## j captures the reference to the last element to be inserted into the ThetaTree
            j = k
            ## Increase the idx
            idx += 1
        end

        ## If the activity was part of the Theta tree, remove it first
        if activity_seen[activity]
            delete!(c.thetaTree, c.rankEst[activity]) 
        end

        ## Check if the ect of the NLSet(T, i) exceeds the lst of activity
        if Utilities.ect(c.thetaTree) > maximum(c.startTimes[activity])
            ## Update the activity's lct based on the last activity, j, in its NLSet
            c.endMax[activity] = maximum(c.startTimes[j])
        end

        ## Re-insert the activity if it had been removed yet it had already been seen
        if activity_seen[activity]
            insert!(c.thetaTree, c.rankEst[activity], minimum(c.endTimes[activity]), c.durations[activity])
        end
    end

    ## See if any change occured
    for i in 1:c.nVars
        ## Indicate change iff the lct of `i` has been updated (reduced)
        changed = changed || (c.endMax[i] < maximum(c.endTimes[i]))
        Variables.removeAbove(c.endTimes[i], c.endMax[i])
    end

    return changed
end