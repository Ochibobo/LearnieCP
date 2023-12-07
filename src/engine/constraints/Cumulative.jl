"""
    @with_kw mutable struct Cumulative{T} <: AbstractConstraint
        solver::AbstractSolver
        startTimes::Vector{<:AbstractVariable{T}}
        duration::Vector{<:T}
        endTimes::Vector{<:AbstractVariable{T}}
        demand::Vector{Int}
        capacity::Int
        postMirror::Bool

        ## Constraint-wide variables
        active::State
        scheduled::Bool

        function Cumulative{T}(start::Vector{<:AbstractVariable{T}}, duration::Vector{T}, demand::Vector{Int}, capacity::Int; postMirror = true) where T
            (isempty(start) || isempty(demand) || isempty(duration) || capacity <= 0) && throw(ArgumentError("Invalid argumets passed."))
            ## Get the solver instance
            solver = Variables.solver(start[1])
            ## Retrieve the state manager
            sm = stateManager(solver)

            ## Create the end variables
            n = length(start)
            endTimes = Vector{<:AbstractVariable{T}}(undef, n)

            for i in eachindex(start)
                endTimes[i] = start[i] + duration[i]
            end

            active = makeStateRef(sm, true)

            new{T}(solver, start, duration, endTimes, demand, capacity, postMirror, active, false)
        end
    end

`Cumulative` constraint using `TimeTable` filtering.
"""
@with_kw mutable struct Cumulative{T} <: AbstractConstraint
    solver::AbstractSolver
    startTimes::Vector{<:AbstractVariable{T}}
    duration::Vector{<:T}
    endTimes::Vector{<:AbstractVariable{T}}
    demand::Vector{<:T}
    capacity::T
    postMirror::Bool

    ## Constraint-wide variables
    active::State
    scheduled::Bool

    function Cumulative{T}(start::Vector{<:AbstractVariable{T}}, duration::Vector{<:T}, demand::Vector{<:T}, capacity::T; postMirror = true) where T
        (isempty(start) || isempty(demand) || isempty(duration) || capacity <= 0) && throw(ArgumentError("Invalid argumets passed."))
        ## Get the solver instance
        solver = Variables.solver(start[1])
        ## Retrieve the state manager
        sm = stateManager(solver)

        ## Create the end variables
        n = length(start)
        endTimes = map(i -> start[i] + duration[i], 1:n)

        active = makeStateRef(sm, true)

        new{T}(solver, start, duration, endTimes, demand, capacity, postMirror, active, false)
    end
end



"""
    post(c::Cumulative{T})::Nothing where T

Function to `post` the `Cumulative` constraint
"""
function post(c::Cumulative{T})::Nothing where T
    ## Propagate the constraint when the bounds of the start variable change
    for start in c.startTimes
        propagateOnBoundChange(start, c)
    end    

    ## If the postMirror is set to true, execute
    if c.postMirror
        startMirror = map(var -> -(var), c.endTimes)
        ## Post the startMirror to the solver
        Solver.post(c.solver, Cumulative{T}(startMirror, c.duration, c.demand, c.capacity, postMirror = false), enforceFixpoint = false)
    end

    ## Initialize propagation
    propagate(c)
    
    return nothing
end


"""
    propagate(c::Cumulative)::Nothing

Function to `propagate` the `Cumulative` constraint
"""
function propagate(c::Cumulative)::Nothing
    ## Create a profile instance
    profile = buildProfile(c)

    ## Check that the profile is not exceeding the capacity, else throw an exception (Inconsistency)
    ## Invalid mandatory parts signal that the activities' demands will always exceed the required resources
    for i in 1:size(profile)
        ## We are now dealing with profile rectangles, not individual activity rectangles
        rect = Utilities.getRectangle(profile, i)
        if rect.height > c.capacity
            #println("Profile rectangle has height $(rect.height) which is greater than capacity: $(c.capacity)")
            throw(DomainError("Profile rectangle has height $(rect.height) which is greater than capacity: $(c.capacity)"))
        end
    end

    ## TimeTable filtering: Check the consistency of the current time of an activity
    for (i, startTime) in enumerate(c.startTimes)
        ## If the current variable is not fixed
        if !Variables.isFixed(c.startTimes[i])
            # ## est is the earliest start time
            # est = minimum(c.startTimes[i])
            # ## j is the index of the profile rectangle overlapping time `t`
            # j = Utilities.rectangleIndex(profile, minimum(c.startTimes[i]))
            # """
            # // TODO 3: postpone i to a later point in time
            # // hint:
            # // Check that at every point in the interval
            # // [start[i].getMin() ... start[i].getMin()+duration[i]-1]
            # // there is enough remaining capacity.
            # // You may also have to check the following profile rectangle(s).
            # // Note that the activity you are currently postponing
            # // may have contributed to the profile.
            # """
            # demand = c.demand[i]
            # m = minimum(c.startTimes[i])
            # n = minimum(c.startTimes[i]) + c.duration[i] - 1
            # for t in minimum(c.startTimes[i]):(minimum(c.startTimes[i]) + c.duration[i] - 1)
            #     ## Check if t is not in the mandatory part minimum(startTime) + c.duration[i]
            #     if (!(t >= maximum(c.startTimes[i]) && t < (minimum(c.startTimes[i]) + c.duration[i])))
            #         ## Move to a different rectangle if necessary
            #         if Utilities.getRectangle(profile, j).endTime <= t
            #             j = Utilities.rectangleIndex(profile, t)
            #         end
            #         ## Get the profile rectangle
            #         rect = Utilities.getRectangle(profile, j)
            #         ## If any violation is met (remaining capacity is not enough),
            #         ## remove this minimum value (est) from the startTime's domain
            #         if c.capacity < (rect.height + c.demand[i])
            #             ## Remove est
            #             Variables.remove(c.startTimes[i], minimum(c.startTimes[i]))
            #             ## Update the est
            #             ## est = minimum(startTime)
            #             ## Exit the loop
            #             t = minimum(c.startTimes[i]) + c.duration[i]
            #         end
            #     end
            # end
            
            est = minimum(startTime)
            j = Utilities.rectangleIndex(profile, est)
            while j <= size(profile) && Utilities.getRectangle(profile, j).startTime < min(est + c.duration[i], maximum(startTime))
                ## Get the rectangle instance
                rect = Utilities.getRectangle(profile, j)
                ## Check if capacity is violated
                if c.capacity < (rect.height + c.demand[i])
                    ## Update the est
                    est = min(Utilities.getRectangle(profile, j).endTime, maximum(startTime))
                end
                ## Increase j
                j += 1
            end

            ## Remove all times below the est
            Variables.removeBelow(startTime, est)
        end
    end

    return nothing
end


"""
    buildProfile(c::Cumulative)::Utilities.Profile

Function used to build the `Profile` based on `Mandatory` sections of activities
"""
function buildProfile(c::Cumulative)::Utilities.Profile
    mandatoryParts = Vector{Utilities.Rectangle}()

    for i in eachindex(c.startTimes)
        ## Get the mandatory part of this activity
        ## Get the earliest completion time
        ect = minimum(c.endTimes[i])

        ## Get the latest start time
        lst = maximum(c.startTimes[i])

        ## If the lst < ect then we have a mandatory part
        if lst < ect
            ## Create a manatory part and add it to the mandatory parts vector
            rect = Utilities.Rectangle(lst, ect, c.demand[i])
            push!(mandatoryParts, rect)
        end
    end

    ## Return a vector of mandatory parts
    return Utilities.Profile(mandatoryParts)
end