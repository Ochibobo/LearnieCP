## Read the file
## small/jobshop-6-6-0 uclouvain.txt
path = "./data/jobshop/uclouvain.txt"
f = open(path)

data = readlines(f)
data = data[4:end]

## Get the number of machines and the number of jobs
topRow = data[1]
nJobs, nMachines = parse.(Int, split(topRow, " "))

## Rows containing job entries
data = data[2:end]

machines = zeros(Int, nJobs, nMachines)
durations = zeros(Int, nJobs, nMachines)
horizon = 0

## Get the activities and respective durations filled into the machines & durations matrices
for i in 1:nJobs
    jobEntry = parse.(Int, split(data[i], r"\s+"))
    k = 1
    for j in 1:nMachines
        machines[i, j] = jobEntry[k]
        durations[i, j] = jobEntry[k + 1]
        ## Update the horizon
        horizon += durations[i, j]
        k += 2
    end
end

horizon

durations
machines

## Job Shop Scheduling example
include("../../JuliaCP.jl")

using .JuliaCP

## Solver Instance
solver = Engine.LearnieCP()

## Start times and end times variables
startTimes = Matrix{Engine.IntVar}(undef, nJobs, nMachines)
endTimes = Matrix{Engine.AbstractVariable{Integer}}(undef, nJobs, nMachines)

## Fill in the start and end times
for i in 1:nJobs
    for j in 1:nMachines
        startTimes[i, j] = Engine.IntVar(solver, 0, horizon)
        endTimes[i, j] = startTimes[i, j] + durations[i, j]
    end
end


## Enforce activity precedences per job
for i in 1:nJobs
    for j in 2:nMachines
        Engine.post(solver, Engine.LessOrEqual{Integer}(endTimes[i, j - 1], startTimes[i, j]))
    end
end

## Function to gather activities that run on the same machine
function gather(vars::Matrix{<:Engine.AbstractVariable{T}}, m::Int)::Vector{<:Engine.AbstractVariable{T}} where T
    rows, cols = size(vars)

    answer = Vector{Engine.AbstractVariable{T}}()

    for i in 1:rows
        for j in 1:cols
            if machines[i, j] == m
                push!(answer, vars[i, j])
            end
        end
    end

    return answer
end

function gather(vars::Matrix{Int}, m::Int)::Vector{Int}
    rows, cols = size(vars)

    answer = Vector{Int}()

    for i in 1:rows
        for j in 1:cols
            if machines[i, j] == m
                push!(answer, durations[i, j])
            end
        end
    end

    return answer
end

## Collect the DijsunctiveBinary constraints
disjunctiveBinaries = Vector{Engine.DisjunctiveBinary{Integer}}()

## Enforce the Disjuntive constraint between activities
for m in 0:(nMachines - 1)
    activityStartTimes = gather(startTimes, m)
    activityEndTimes = gather(endTimes, m)
    activityDurations = gather(durations, m)
  
    ## Post the Disjunctive Constraint
    Engine.post(solver, Engine.Disjunctive{Integer}(activityStartTimes, activityDurations))
end

# length(disjunctiveBinaries)
## Create the makeSpan
endLast = Vector{Engine.AbstractVariable{Integer}}(undef, nJobs)

for i in 1:nJobs
    endLast[i] = endTimes[i, nMachines]
end

makeSpan = Engine.IntVar(solver, 0, horizon)
Engine.post(solver, Engine.Maximum{Integer}(endLast, makeSpan))
objective = Engine.Minimize{Integer}(makeSpan)


## Perform the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(vcat(startTimes...)))

Engine.addOnSolution(search, () -> begin
    println(minimum(makeSpan))
    sleep(1)
end)

Engine.optimize(objective, search)












## Precedence constraint
# function branchPrecedence()
#     idx = nothing

#     for i in eachindex(disjunctiveBinaries)
#         if !Engine.isFixed(disjunctiveBinaries[i])
#             idx = i
#             break
#         end
#     end

#     if isnothing(idx)
#         return []
#     end

#     dBConstraint = disjunctiveBinaries[idx]

#     ## Branching functions
#     function left()
#         ## Fix before to true
#         return Engine.Solver.post(solver, dBConstraint.before)
#     end

#     function right()
#         ## Fix before to false
#         return Engine.Solver.post(solver, dBConstraint.after)
#     end

#     return [left, right]
# end


# ## Function to fix the makespan
# function fixMakespan()
#     if Engine.isFixed(makeSpan)
#         return []
#     end

#     ## Get the minimum of the makeSpan
#     minVal = minimum(makeSpan)

#     function setToMinimum()
#         return Engine.Solver.post(solver, Engine.ConstEqual{Integer}(makeSpan, minVal))
#     end

#     return [setToMinimum]
# end

# search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.And(branchPrecedence, fixMakespan))


    # if isempty(activityStartTimes) && isempty(activityDurations)
    #     continue
    # end

    ## For each pair of activities a1, a2 on machine m post a DisjunctiveBinary
    ## and add the constraint to the disjunctiveBinaries vector
    
    # for i in eachindex(activityStartTimes)
    #     startA = activityStartTimes[i]
    #     endA = activityEndTimes[i]
    #     for j in (i + 1):length(activityStartTimes)
    #         startB = activityStartTimes[j]
    #         endB = activityEndTimes[j]
    #         push!(disjunctiveBinaries, 
    #             Engine.DisjunctiveBinary{Integer}(startA, endA, startB, endB))
    #     end
    # end