#######################################################################################################################################
#
# This example was pulled from JuMP's Facility Location problem
#
# Link: https://jump.dev/JuMP.jl/stable/tutorials/linear/facility_location/#Capacitated-facility-location
#
# The objective is to minimize the cost of serving clients  by also determining whether to open a facility or not. It also takes
# into account the client demands and facility capacities
#
#######################################################################################################################################
include("../../JuliaCP.jl")
using .JuliaCP
using Random
using LinearAlgebra
using Plots
using CSV
using DataFrames

Random.seed!(3456)

## Upper bound used for the random number integer generation for facility & client locations
LOCATION_UPPER_BOUND = 1_000
NUMBER_OF_CLIENTS = 8
NUMBER_OF_FACILITIES = 5
MAX_NUMBER_OF_FACILITIES_ASSIGNED = 1

## Generate the client locations
clients = CSV.read(joinpath(@__DIR__, "client_positions.txt"), DataFrames.DataFrame)
x_client, y_client = clients[:, :x], clients[:, :y]
#rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_CLIENTS), rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_CLIENTS)
facilities = CSV.read(joinpath(@__DIR__,"facility_positions.txt"), DataFrame)
x_facility, y_facility = facilities[:, :x], facilities[:, :y]
##rand(1:LOCATION_UPPER_BOUND * 1, NUMBER_OF_FACILITIES), rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_FACILITIES)


# ## Plot client positions
# p = Plots.scatter(
#     x_client,
#     y_client,
#     label= nothing,
#     markershape = :circle,
#     markercolor = :blue
# )


# ## Plot the facilities based on whether they were opened or not
# Plots.scatter!(
#     x_facility,
#     y_facility,
#     markershape = :square,
#     markercolor = :red,
#     markersize = 6,
#     markerstrokecolor = :red,
#     markerstrokewidth = 2,
#     label = nothing,
# )

## Fixed cost of opening the facilites
facilities_opening_cost = ones(Int, NUMBER_OF_FACILITIES)

## The distance between a client and each facility
distances = zeros(Int, NUMBER_OF_CLIENTS, NUMBER_OF_FACILITIES)

for c in 1:NUMBER_OF_CLIENTS
    for f in 1:NUMBER_OF_FACILITIES
        distance = LinearAlgebra.norm([x_client[c] - x_facility[f], y_client[c] - y_facility[f]], 2)
        distances[c, f] = floor(Int, distance)
    end
end

## Demands from each client
demands = rand(1:80, NUMBER_OF_CLIENTS)
demands
## Capacities for each facility
capacities = rand(200:500, NUMBER_OF_FACILITIES)

## Define the solver
solver = Engine.LearnieCP()

## Variable definition
## Shows whether a facility is open or closed
y = [Engine.BoolVar(solver) for _ in 1:NUMBER_OF_FACILITIES]

## Holds the assignment of a client to a facility
x = Matrix{Engine.BoolVar}(undef, NUMBER_OF_CLIENTS, NUMBER_OF_FACILITIES)

for c in 1:NUMBER_OF_CLIENTS
    for f in 1:NUMBER_OF_FACILITIES
        ## Whether client c is assigned to facility f
        x[c, f] = Engine.BoolVar(solver)

        ## A client can only be assigned to a facility if it's open
        Engine.post(solver, Engine.LessOrEqual{Integer}(x[c, f], y[f]))
    end

    ## A client can only be assigned to 1 facility
    Engine.post(solver, Engine.Sum{Integer}(x[c, :], MAX_NUMBER_OF_FACILITIES_ASSIGNED))
end

## Cost of opening a facility
facility_cost = [y[f] * facilities_opening_cost[f] for f in 1:NUMBER_OF_FACILITIES]

## Compute the cost of assigning a client to facility (this is the cost to be minimized)
client_cost = Vector{Engine.AbstractVariable{Integer}}()
for c in 1:NUMBER_OF_CLIENTS
    for f in 1:NUMBER_OF_FACILITIES
        ## Multiply the distance between the client & facility with the decision of whether the client was connected to 
        ## the facility or not
        push!(client_cost, distances[c, f] * x[c, f])
    end
end

## Capacity and demands limit constraints
for f in 1:NUMBER_OF_FACILITIES
   total_client_demand = demands .* x[:, f]
   total_client_demand = Engine.summation(total_client_demand)

   ## Facility capacity
   facility_capacity = capacities[f] * y[f]

   ## The total met demand in facility f should be <= its capacity
   ## Take into account whether the facility is open or not
   Engine.post(solver, Engine.LessOrEqual{Integer}(total_client_demand, facility_capacity))
end

## The total cost is to be minimized
total_cost = Engine.summation([client_cost..., facility_cost...])
objective = Engine.Minimize{Integer}(total_cost)

## Search Definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail([y..., x...]))

## Solution holders
cost_progress = Int[]
## Client- Facility assoc
client_facility_association_progress = Vector{Vector{Int}}()
## Whether a facitlity is open or not
facility_open_progress = Vector{Vector{Integer}}()

## What to display on solution
Engine.addOnSolution(search, () -> begin
    client_facility_association = zeros(Int, NUMBER_OF_CLIENTS)
    ## Get the facility the client is assigned to
    for c in 1:NUMBER_OF_CLIENTS
        assigned_facility = nothing
        for f in 1:NUMBER_OF_FACILITIES
            if minimum(x[c, f]) == 1
                if !isnothing(assigned_facility)
                    println("Numerous facilities assigned")
                end
                assigned_facility = f
            end
        end
        client_facility_association[c] = assigned_facility
    end

    push!(client_facility_association_progress, client_facility_association)

    facility_open = falses(NUMBER_OF_FACILITIES)
    ## Check if facility is open or not
    for f in 1:NUMBER_OF_FACILITIES
        facility_open[f] = minimum(y[f])
    end

    push!(facility_open_progress, facility_open)

    ## Collect the cost progress
    push!(cost_progress, minimum(total_cost))

    println(repeat('*', 30))
    println("Solution found")
    println(repeat('*', 30))
    println()
end)

## Optimize the objective
Engine.optimize(objective, search)

search.searchStatistics


using DelimitedFiles
path = joinpath(@__DIR__, "client_facility_assignment.txt")
writedlm(path, client_facility_association_progress, ",")

facility_open_progress

vscodedisplay(cost_progress)

Plots.plot(cost_progress)


## Assignment of clients to facilities - Scatter-plot + line-plot

## Plot client positions
p = Plots.scatter(
    x_client,
    y_client,
    label= "client",
    markershape = :circle,
    markercolor = :blue,
    markersize = 0.1 .* (2 .+ demands),
);


## Plot the facilities based on whether they were opened or not
Plots.scatter!(
    x_facility,
    y_facility,
    markershape = :square,
    markercolor = [(facility_open_progress[end][j] ? :red : :white) for j in 1:NUMBER_OF_FACILITIES],
    markersize = capacities * 0.015,
    markerstrokecolor = :red,
    markerstrokewidth = 2,
    label = "facility",
);

## Plot connecting lines
for i in 1:NUMBER_OF_CLIENTS
    assigned_facility = client_facility_association_progress[end][i]
    Plots.plot!(
        [x_client[i], x_facility[assigned_facility]],
        [y_client[i], y_facility[assigned_facility]];
        color = :black,
        label = nothing,
    )
end

p



client_facility_association_progress

## Makie plot

## 2 figures

using GLMakie

fig = Figure();

# ax = fig[1, 1] = Axis(fig,
#     ## Title
#     title = "Cost Progress (Capacitated Facility Location)",
#     titlegap = 12, titlesize = 16,

#     ## x axis definition
#     xgridcolor = :darkgray, xgridwidth = 1,
#     xlabel = "Completed Solution Timestep", xlabelsize = 16,
#     xticklabelsize = 12, xticks = LinearTicks(20),

#     ## y axis
#     ygridcolor = :darkgray, ygridwidth = 1,
#     ylabel = "Cost", ylabelsize = 18,
#     yticklabelsize = 12, yticks = LinearTicks(20),
# )

# limits!(ax, 0, 25, 1000, 5000)

# frames = 1:length(cost_progress)

# data = convert.(Int64, cost_progress)

# record(fig, "capacitated_facility_location_cost_progress.gif", frames; framerate = 4) do i
#     lines!(ax, 1:i, data[1:i], color = :blue, linewidth = 2)
#     # GLMakie.scatter!(ax, i, data[i], color = :blue, markersize = 18)
# end

# linestyle = :dash, 


## Scatter plot with redrawing lines
ax1 = fig[1, 1] = Axis(fig,
    ## Title
    title = "Client-Facility Assignment",
    titlegap = 12, titlesize = 16,

    ## x axis definition
    # xgridcolor = :darkgray, xgridwidth = 1,
    xlabel = "x co-ordinate", xlabelsize = 16,
    xticklabelsize = 12, xticks = LinearTicks(20),

    ## y axis
    # ygridcolor = :darkgray, ygridwidth = 1,
    ylabel = "y co-ordinate", ylabelsize = 18,
    yticklabelsize = 12, yticks = LinearTicks(20),
)

limits!(ax1, 0, LOCATION_UPPER_BOUND, 0, LOCATION_UPPER_BOUND)

## Plot the chart
client_points = Point2f.(x_client, y_client)
### Client plots
GLMakie.scatter(ax1, 
    client_points,
    # label= "client",
    # markershape = :circle,
    # markercolor = :blue,
    # markersize = 0.1 .* (2 .+ demands),
)


using DelimitedFiles
client_postions = hcat(x_facility, y_facility)
path = joinpath(@__DIR__, "facility_positions.txt")



writedlm(path, client_postions, ",")

