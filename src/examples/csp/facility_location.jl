##########################################################################################################################
#
# This example was pulled from JuMP's Facility Location problem
#
# Link: https://jump.dev/JuMP.jl/stable/tutorials/linear/facility_location/
#
# The objective is to minimize the cost of serving clients by also determining whether to open a facility or not
#
##########################################################################################################################
import Random
import LinearAlgebra
using Plots
include("../../JuliaCP.jl")
using .JuliaCP

## For reproducability
Random.seed!(1234)

## Number of clients
nClients = 10

## Number of facilities
nFacilities = 3

## Upper bound used for the random number integer generation for facility & client locations
LOCATION_UPPER_BOUND = 100
NUMBER_OF_CLIENTS = 7
NUMBER_OF_FACILITIES = 3
MAX_NUMBER_OF_FACILITIES_ASSIGNED = 1

## Generate the client locations
x_client, y_client = rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_CLIENTS), rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_CLIENTS)
x_facility, y_facility = rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_FACILITIES), rand(1:LOCATION_UPPER_BOUND, NUMBER_OF_FACILITIES)

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

# ## Plot the data
# ## The clients by location
scatter(
    x_client,
    y_client,
    label= "Clients",
    markershape = :circle,
    markercolor = :blue
)

## The facilities by location
scatter!(
    x_facility,
    y_facility,
    label = "Facility",
    markershape = :square,
    markercolor = :white,
    markersize = 6,
    markerstrokecolor = :red,
    markerstrokewidth = 2,
)


## Model definition
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

## Append the facility cost to the client cost
append!(client_cost, facility_cost)

# ## Minimize the cost above
total_cost = Engine.summation(client_cost)
objective = Engine.Minimize{Integer}(total_cost)

## Search definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.And(Engine.FirstFail([x..., y...]...)))

## Solution holders
cost_progress = Int[]
## Client- Facility assoc
client_facility_association = zeros(Int, NUMBER_OF_CLIENTS)
## Whether a facitlity is open or not
facility_open = falses(NUMBER_OF_FACILITIES)

Engine.addOnSolution(search, () -> begin
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

    ## Check if facility is open or not
    for f in 1:NUMBER_OF_FACILITIES
        facility_open[f] = minimum(y[f])
    end

    ## Collect the cost progress
    push!(cost_progress, minimum(total_cost))

    println(repeat('*', 30))
    println("Solution found")
    println(repeat('*', 30))
    println()
end)

## Optimize the model
Engine.optimize(objective, search)

## Model results analysis
search.searchStatistics

vscodedisplay(client_facility_association)
vscodedisplay(facility_open)
vscodedisplay(cost_progress)


### Add necessary plots
## Cost progress - line plot + scatter plot
plot(cost_progress)
## Assignment of clients to facilities - Scatter-plot + line-plot
## Facility-client distribution - Histogram
## What happens if the cost of the facility with the most assignments increases by a factor of 10