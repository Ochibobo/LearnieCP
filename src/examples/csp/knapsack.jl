### An implementation of the KnapSack problem
include("../../JuliaCP.jl")

using .JuliaCP

## The number of items
n = 5

## The Knapsack's capacity
capacity = 10

## The item weights & respecitve profits
weights = [2, 8, 4, 2, 5]
profits = [5, 3, 2, 7, 4]

## Solver instance
solver = Engine.LearnieCP()

## Constraint modeling
x = [Engine.BoolVar(solver) for _ in 1:n] ## Indicate whether an item has been selected or not

## Store the total weight of elements placed in the Knapsack
knapsack_elements = Vector{Engine.AbstractVariable{Integer}}(undef, n)

for i in 1:n
    ## Product of the weight & 1/0 depending on whether item i was placed in the knapsack
    knapsack_elements[i] = weights[i] * x[i] 
end

## Create the sum and ascertain it's less or equal to the knapsack's capacity
total_weight = Engine.summation(knapsack_elements)
Engine.post(solver, Engine.lessOrEqual{Integer}(total_weight, capacity))

## Maximize the profits
selected_items_profits = Vector{Engine.AbstractVariable{Integer}}(undef, n)

for i in 1:n
    selected_items_profits[i] = profits[i] * x[i]
end

## The total profit is a sum of selected_items_profits
knapsack_profit = Engine.summation(selected_items_profits)

## Maximize the profit
objective = Engine.Maximize{Integer}(knapsack_profit)

## Search definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))

profit_progress = Vector{Integer}()
items = Vector{Integer}(undef, n)

Engine.addOnSolution(search, () -> begin
    push!(profit_progress, Engine.minimum(knapsack_profit))

    for i in 1:n
        items[i] = Engine.minimum(x[i])
    end

end)

## Optimize the model
Engine.optimize(objective, search)


profit_progress
items