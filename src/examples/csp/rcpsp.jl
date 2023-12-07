## Resource Constrained Project Scheduling Project

## Read the rcpsp file
path = "./data/rcpsp/j30_1_1.rcp"
file = open(path)

## Read all lines
data = readlines(file)

## First line contains nActivites, nResources
nActivities, nResources = parse.(Int, split(data[1], " "))

## Update the data field
data = data[2:end]

## Vector of resouces with their respective capacities
capacities = parse.(Int, split(data[1], " "))

## Update the data field
data = data[2:end]

## Loop through each activity filling in its duration, successors and demands
duration = zeros(Int, nActivities)
consumption = zeros(Int, nResources, nActivities)
successors = Vector{Vector{Int}}(undef, nActivities)
horizon = 0

for i in 1:nActivities
    j = 1
    ## Fetch the activity line
    line = parse.(Int, split(data[i], " "))

    ## Fill in this activity's duration
    duration[i] = line[j]
    j += 1
    horizon += duration[i]

    ## Fill in the amount of consumption consumed by activity i in every resource
    for r in 1:nResources
        consumption[r, i] = line[j]
        j += 1
    end

    ## Fill in the successors of activity i
    successors[i] = zeros(Int, line[j])
    j += 1
    for k in eachindex(successors[i])
        successors[i][k] = line[j]
        j += 1
    end
end


## Import the solver
include("../../JuliaCP.jl")
using .JuliaCP

## The solver instance
solver = Engine.LearnieCP()

## Start variables for each activity
## The startTimes vary from 0...horizon
startTimes = Engine.makeIntVarArray(solver, nActivities, 0, horizon - 1)

## End variables
endTimes = Vector{Engine.AbstractVariable{Integer}}(undef, nActivities)

## The end times are a view of the the startTimes + durations
for i in 1:nActivities
    endTimes[i] = startTimes[i] + duration[i]
end


"""
Constaint Modeling
"""
## The cumulative constraint to model the resource
## capacities[r] is the capacity of resource r
## consumption[r] is the consumption for each activity on the resource [r]
## duration is the duration of each activity
for r in 1:nResources
    ## Post the cumulative constraint to the solver
    Engine.post(solver, Engine.Cumulative{Integer}(startTimes, duration, consumption[r, :], capacities[r]))
end


## Add the precedence constraints
## successors[i] contains all successors of activity i
for i in 1:nActivities
    ## Go through all successors of activity i, ensuring activity i <= each of them
    for s in successors[i]
        Engine.post(solver, Engine.LessOrEqual{Integer}(endTimes[i], startTimes[s]))
    end
end


## Minimize the makespan
## The span is initially from 0 to the horizon
makeSpan = Engine.IntVar(solver, 0, horizon - 1) 
## Post the Maximum constraint on the makeSpan
Engine.post(solver, Engine.Maximum{Integer}(endTimes, makeSpan))
## Attempt to minimize the makeSpan as the objective
objective = Engine.Minimize{Integer}(makeSpan)


## Execute the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver),
                        Engine.FirstFail(startTimes))

solution = Vector{Int}(undef, nActivities)
makeSpanTrajectory = Int[]
## Function to be executed when the solution is found
Engine.addOnSolution(search, () -> begin
    ## Collect the assigned start times
    for (index, startTime) in enumerate(startTimes)
        solution[index] = minimum(startTime)
    end
    ## Get the current makeSpan
    push!(makeSpanTrajectory, minimum(makeSpan))

    @show solution
    @show makeSpanTrajectory
end)

## Optimize the solution
Engine.optimize(objective, search)

solution
makeSpanTrajectory