### TSP Problem
include("JuliaCP.jl")

using .JuliaCP

## Model instance
solver = Engine.LearnieCP()

## Read the data
f = open("./data/tsp/tsp_15.txt")

## Number of nodes
n = parse(Int, readline(f))

matrixStr = readlines(f)

## The distance matrix instance
distanceMatrix = Matrix{Integer}(undef, n, n)

## Read the file input
function populateDistanceMatrix()
    for (index, rawEntry) in enumerate(matrixStr)
        ## Get the distance row
        distanceEntry = filter(s -> length(s) > 0, split(rawEntry, r"\s"))
        ## Convert the vector into an int-vector
        distanceEntry = parse.(Int, distanceEntry)
        ## Append this to the distance matrix
        distanceMatrix[index, :] = distanceEntry
    end
end

populateDistanceMatrix()

## Get the maximum distance
maxDistance = maximum(distanceMatrix)

## Variables representation of each point
successors = Engine.Variables.makeIntVarArray(solver, n, 1, n)

## Distance from successor
distanceSucc = Engine.makeIntVarArray(solver, n, 1, maxDistance)

## Post the circuit constraint
Engine.post(solver, Engine.Circuit{Integer}(successors))

## Compute the distance by assigning the appropriate value to the distance matrix
for i in 1:n
    ## Once the successor of i is fixed, use index into the distance vector and set the distanceSucc at index i to the value 
    ## indexed in the distanceMatrix
    Engine.post(solver, Engine.Element1D{Integer}(distanceMatrix[i, :], successors[i], distanceSucc[i]))
end

## Compute the total length found so far
totalDistance = Engine.summation(distanceSucc)

## Objective to minimize the total distance
objective = Engine.Minimize{Integer}(totalDistance)

## Search function based on the first fail branching scheme - slow when it comes to large matrices
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(successors))

## Large Neighbourhood Search


## Variable to hold the best solution
xBest = Vector{Integer}(collect(1:n))
xBest = map(i -> ((i + 3) % n) + 1, xBest)
## Vector to conntect the best solution at each solution realization
bestDistance = Vector{Integer}()
## Matrix to store the array of vectors
bestSolutions = Vector{Vector{Integer}}()

## onSolution
Engine.addOnSolution(search, () -> begin
    println("Solution found..")
    for i in 1:n
        xBest[i] = Engine.minimum(successors[i])
    end

    dist = Engine.minimum(totalDistance)
    ## Store the best solution so far
    push!(bestSolutions, copy(xBest))
    push!(bestDistance, dist)

end)

Engine.optimize(objective, search)

search.searchStatistics.completed
search.searchStatistics.numberOfFailures
search.searchStatistics.numberOfSolutions
search.searchStatistics.numberOfNodes

bestSolutions
bestDistance
vscodedisplay(bestDistance)


using GLMakie

## Figure instance
fig = Figure();

## Axis Definition
ax = fig[1, 1] = Axis(fig,
    ## Title
    title = "Distance Progress (Travelling Salesman Problem)",
    titlegap = 12, titlesize = 16,

    ## x axis definition
    xgridcolor = :darkgray, xgridwidth = 2,
    xlabel = "Completed Solution Timestep", xlabelsize = 16,
    xticklabelsize = 12, xticks = LinearTicks(20),

    ## y axis
    ygridcolor = :darkgray, ygridwidth = 2,
    ylabel = "Distance Value", ylabelsize = 18,
    yticklabelsize = 12, yticks = LinearTicks(20),
)


frames = 1:length(bestDistance)

data = convert.(Int64, bestDistance)

record(fig, "tsp_v1.gif", frames; framerate = 6) do i
    lines!(ax, 1:i, data[1:i], color = :blue, linestyle = :dash, linewidth = 2)
    GLMakie.scatter!(ax, i, data[i], color = :gray, markersize = 18)
end







"""
Undone!! => THIS IS HOWEVER THE NEXT FOCUS - LARGE NEIGHBOURHOOD SEARCH
"""
## Number of restarts
nRestarts = 1000
failLimit = 100
percentage = 5


## Find the optimal solution
for i in 1:nRestarts
    Engine.optimizeSubjectTo(objective, search,
        ## The search limit definition
        searchLimit = () -> Engine.numberOfFailures(search.searchStatistics) > failLimit,
        ## Large Neighbourhood Search
        subjectTo = () -> begin
            ## Assign the fragment percentage% of the variables randomly chosen
            for j in 1:n
                if (rand() * 100) <= percentage
                    @show j
                    Engine.post(solver, Engine.ConstEqual{Integer}(successors[j], xBest[j]))
                end
            end
        end    
    )
end



# Engine.optimizeSubjectTo



# fn(s::Function = () -> println("tried")) = s()
# fn(() -> begin
#     k = 1 + 1
#     println("The sum is: $k")
# end)
