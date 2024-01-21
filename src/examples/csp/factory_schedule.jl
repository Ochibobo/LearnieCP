#####################################################################################################################
#
# This example was pulled from JuMP's Factory Schedule Example
#
# Link: https://jump.dev/JuMP.jl/stable/tutorials/linear/factory_schedule/
#
# We are optimizing the production of goods from factories f ∈ F over a period of 12 months m ∈ M
#
# This is a good problem to demonstrate that the methods employed by this solver are inefficient for large integers
#
####################################################################################################################
using CSV
using DataFrames
using StatsPlots
include("../../JuliaCP.jl")
using .JuliaCP

factories_path = "./data/factory_schedule/factories.csv"
factories = CSV.read(factories_path, DataFrame, delim = ' ', ignorerepeated = true)
# vscodedisplay(factories)

demand_path = "./data/factory_schedule/demand.csv"
demand = CSV.read(demand_path, DataFrame, delim = ' ',ignorerepeated = true)
# vscodedisplay(demand)

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
nMonths, nFactories = length(unique(factories.month)), length(unique(factories.factory))

## Penalty for unmet demand
UNMET_DEMAND_PENALTY = 2

## The status is a shows whether factory f is open in month m
status = Matrix{Engine.BoolVar}(undef, nMonths, nFactories)

for m in 1:nMonths
    for f in 1:nFactories
        status[m, f] = Engine.BoolVar(solver)
    end
end

## Production variables
x = Matrix{Engine.IntVar}(undef, nMonths, nFactories)
df_idx = 1 ## Index to control the looping of rows in the array

for f in 1:nFactories
    for m in 1:nMonths
        min_prod, max_prod = factories[df_idx, :min_production], factories[df_idx, :max_production]
        x[m, f] = Engine.IntVar(solver, min_prod, max_prod)
        
        Engine.post(solver, Engine.LessOrEqual{Integer}(x[m, f], max_prod * status[m, f]))
        Engine.post(solver, Engine.GreaterOrEqual{Integer}(x[m, f], min_prod * status[m, f]))
        df_idx += 1
    end
end

## Unmet demand variables
## Get the unmet demand, if any
unmet_demand = Engine.AbstractVariable{Integer}[]

for m in 1:nMonths
    ## Demand variable - the domain is from zero to the entire demand as the entire demand may have not been met
    δ_demand = Engine.IntVar(solver, 0, demand[m, :demand])

    push!(unmet_demand, δ_demand)
end


## Demand oughts to be met
for m in 1:nMonths
    per_factory_production = Engine.AbstractVariable{Integer}[]
    for f in 1:nFactories
        push!(per_factory_production, x[m, f])
    end

    ## Add the unmet demand here
    ##push!(per_factory_production, unmet_demand[m])

    ## The total production this month must meet the demand
    Engine.post(solver, Engine.Sum{Integer}(per_factory_production, demand[m, :demand]))
end

### Get the total cost to be minimized
production_contributors = Engine.AbstractVariable{Integer}[]
df_idx = 1


for f in 1:nFactories
    for m in 1:nMonths
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

## Calculat the total unmet demand 
total_unmet_demand = UNMET_DEMAND_PENALTY * Engine.summation(unmet_demand)

# ## Minimize the production cost
# total_cost = Engine.summation([total_production_cost, total_unmet_demand])
# objective = Engine.Minimize{Integer}(total_cost)

objective = Engine.Minimize{Integer}(total_production_cost)

## Search definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x...))

## Cost progress
cost_progress = Int[]
## Collect the production
actual_production = zeros(Int, nMonths, nFactories)
## Collect the unmet demands
actual_unmet_demand = zeros(Int, nMonths)
## Collect the open status
actual_status = zeros(Int, nMonths, nFactories)

Engine.addOnSolution(search, () -> begin
    ## Get the actual production and status
    for m in 1:nMonths
        for f in 1:nFactories
            actual_production[m, f] = minimum(x[m, f])
            actual_status[m, f] = minimum(status[m, f])
        end
    end

    ## Get the unmet demands
    for m in 1:nMonths
        actual_unmet_demand[m] = minimum(unmet_demand[m])
    end

    ## Collect the total cost progress
    cost = minimum(total_cost)
    push!(cost_progress, cost)
end)

## Optimize
Engine.optimize(objective, search)

println(actual_production)
println(actual_status)
println(actual_unmet_demand)
println(cost_progress)

## Generate data skewed based on the dataframes
## Get the distribution
## Use it to generate data with small bounds