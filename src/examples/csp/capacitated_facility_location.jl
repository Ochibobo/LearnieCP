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
import Random
import LinearAlgebra
import Plots
include("../../JuliaCP.jl")
using .JuliaCP

Random.seed!(6789)

## Upper bound used for the random number integer generation for facility & client locations
LOCATION_UPPER_BOUND = 100
NUMBER_OF_CLIENTS = 12
NUMBER_OF_FACILITIES = 5
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

## Demands from each client
demands = rand(1:5, NUMBER_OF_CLIENTS)

## Capacities for each facility
capacities = rand(12:20, NUMBER_OF_FACILITIES)

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

## 
