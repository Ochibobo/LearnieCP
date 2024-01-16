###################################################################################################
#
# This example was pulled from JuMP's Factory Schedule Example
#
# Link: https://jump.dev/JuMP.jl/stable/tutorials/linear/factory_schedule/
#
# We are optimizing the production of goods from factories f ∈ F over a period of 12 months m ∈ M
#
###################################################################################################
using CSV
using DataFrames
using StatsPlots
include("../../JuliaCP.jl")
using .JuliaCP

factories_path = "./data/factory_schedule/factories.csv"
factories = CSV.read(factories_path, DataFrame, delim = ' ', ignorerepeated = true)
vscodedisplay(factories)

demand_path = "./data/factory_schedule/demand.csv"
demand = CSV.read(demand_path, DataFrame, delim = ' ',ignorerepeated = true)
vscodedisplay(demand)

## Data Validation
function validate_data(demand_df::DataFrame, factories_df::DataFrame)
    ## The minimum production must not exceed the maximum production
    @assert all(factories_df.min_production .<= factories_df.max_production)
    ## Demand, minimum production, fixed costs, variable costs must all be non-negative
    @assert all(demand_df.demand .>= 0)
    @assert all(factories_df.min_production .>= 0)
    @assert all(factories_df.fixed_cost .>= 0)
    @assert all(factories_df.variable_cost .>= 0)
end


## Model definition
solver = Engine.LearnieCP()

## Get the unique months and factories
months, factories = unique(factories.month), unique(factories.factory)

## Penalty for unmet demand
UNMET_DEMAND_PENALTY = 10_000

## The status is a shows whether factory f is open in month m
status = Matrix{Engine.BoolVar}(undef, months, factories)

for m in 1:months
    for f in factories
        status[m, f] = Engine.BoolVar(solver)
    end
end

## Production variables
x = Matrix{Engine.IntVar}(undef, months, factories)
df_idx = 1 ## Index to control the looping of rows in the array

for f in 1:factories
    for m in 1:months
        min_prod, max_prod = factories[df_idx, :min_production], factories[df_idx, :max_production]
        x[m, f] = Engine.IntVar(solver, min_prod, max_prod)
        df_idx += 1
    end
end

## Demand oughts to be met
for m in 1:months
    per_factory_production = []
    for f in 1:factories
        push!(per_factory_production, x[m, f])
    end

    ## The total production this month must meet the demand
    Engine.post(solver, Engine.Sum{Integer}(per_factory_production, demand[m, :demand]))
end

### Get the total cost to be minimized
production_contributors = []
df_idx = 1

for f in 1:factories
    for m in 1:months
        ## Fixed cost if open
        fixed_cost = factories[df_idx, :fixed_cost] * status[m, f]
        ## Cost of production
        production_cost = factories[df_idx, :variable_cost] * x[m, f]

        ## Add the above to production contributors
        push!(production_contributors, fixed_cost)
        push!(production_contributors, production_cost)

        df_idx += 1
    end
end

## Get the total production cost
total_production_cost = Engine.summation(production_contributors)

## Get the unmet demand, if any
unmet_demand = []

for m in 1:months
    monthly_production = []
    for f in 1:factories
        push!(monthly_production, x[m, f])
    end

    total_monthly_production = Engine.summation(monthly_production)
    push!(unmet_demand, UNMET_DEMAND_PENALTY * (demand[m, :demand] - total_monthly_production))
end


## Calculat the total unmet demand 
total_unmet_demand = Engine.summation(unmet_demand)

## Minimize the production cost
total_cost = Engine.summation([total_production_cost, total_unmet_demand])
objective = Engine.Minimize{Integer}(total_cost)

## Search definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x...))


Engine.addOnSolution(search, () -> begin
    ## Collect the total cost progress
    cost = minimum(total_cost)
    @show cost
end)

## Optimize
Engine.optimize(objective, search)



