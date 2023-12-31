include("./JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Read the data

f = open("$(@__DIR__)/qad.txt")
data = readlines(f)
n = parse(Int64, data[1])

w_str = data[3:14]
d_str = data[16:end]

function getMatrix(str::Vector{String}, n::Int)::Matrix{Integer}
    ## An n x n Matrix
    m::Matrix{Integer} = Matrix{Integer}(undef, n, n)
    k = 1
    for e in str
        v = parse.(Int, filter(x -> length(x) > 0, split(e, " ")))
        for (index, entry) in enumerate(v)
            m[k, index] = entry
        end
        k += 1
    end

    return m
end

distances = getMatrix(d_str, n)
weights = getMatrix(w_str, n)

## Variables to store the positions of the different warehouses
x = Engine.Variables.makeIntVarArray(solver, n, 1, n)

## 2 warehouses cannot be in the same position
for i in 1:n
    for j in (i + 1):n
        Engine.Solver.post(solver, Engine.NotEqual{Integer}(x[i], x[j]))
    end
end

## An array of weighted distances
weightedDistances = Vector{Engine.AbstractVariable{Integer}}(undef, n * n)
k = 1

for i in 1:n
    for j in 1:n
        weightedDistances[k] = Engine.element2D(distances, x[i], x[j]) * weights[i, j]
        k += 1
    end
end

## Total cost of mutliplying weights and distances
totalCost = Engine.summation(weightedDistances)

## Minimize the total cost
objective = Engine.Minimize{Integer}(totalCost)

## Define the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))

objective_update_progress = []
warehouse_positions = Vector{Integer}(undef, n)

## OnSolution
Engine.addOnSolution(search, () -> begin
    obj = Engine.objectiveValue(objective)
    println("Objective value: $(Engine.objectiveValue(objective))")
    ## Append the objective value to the progrss
    push!(objective_update_progress, obj)
    ## Store the various positions of the values (update)
    for i in 1:n
        warehouse_positions[i] = minimum(x[i])
    end
end)

# Engine.solve(search)
## Solve the problem
Engine.optimize(objective, search)

## Print the objective value
Engine.objectiveValue(objective)

## Get the plot values
objective_update_progress

## The sequence of steps
warehouse_positions


using GLMakie

## Figure instance
fig = Figure();

## Axis Definition
ax = fig[1, 1] = Axis(fig,
    ## Title
    title = "Objective Value Progress (Quadratic Assignment Problem)",
    titlegap = 12, titlesize = 16,

    ## x axis definition
    xgridcolor = :darkgray, xgridwidth = 2,
    xlabel = "Completed Solution Timestep", xlabelsize = 16,
    xticklabelsize = 12, xticks = LinearTicks(20),

    ## y axis
    ygridcolor = :darkgray, ygridwidth = 2,
    ylabel = "Objective Value", ylabelsize = 18,
    yticklabelsize = 12, yticks = LinearTicks(20),
)


frames = 1:length(objective_update_progress)

data = convert.(Int64, objective_update_progress)

record(fig, "qap_example_progress.gif", frames; framerate = 6) do i
    lines!(ax, 1:i, data[1:i], color = :black, linestyle = :dash, linewidth = 2)
    GLMakie.scatter!(ax, i, data[i], color = :blue, markersize = 18)
end
