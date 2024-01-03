### Steel Mill Problem

## Read the bench file
path = "./data/steel/bench_19_10"
file = open(path)

## Read the data
data = readlines(file)

## The slab capacities
row = data[1]
capacities = parse.(Int, split(row, " ")[2:end])
sort!(capacities) ## Sort the capacities in ascending order
data = data[2:end]

## Number of colors
numberOfColors = parse(Int, data[1])
data = data[2:end]

## Number of orders
numberOfSlabs = parse(Int, data[1])
numberOfOrders = numberOfSlabs
data = data[2:end]

## Read the weight, color pairs
weights = zeros(Int, numberOfOrders)
colors = zeros(Int, numberOfOrders)

for i in 1:numberOfOrders
    weight, color = parse.(Int, split(strip(data[i]), r"\s+"))
    weights[i] = weight
    colors[i] = color
end

## Maximum capacity
maxCapacity = maximum(capacities)
maxNumberOfColorsPerSlab = 2

## Store the minimum loss per load level
loss = zeros(Int, maxCapacity + 1)
capaIdx = 1

## Update the minimum loss per load level
for i in 1:maxCapacity
    loss[i + 1] = capacities[capaIdx] - i
    if loss[i + 1] == 0
        capaIdx += 1
    end
end

## Update the first loss entry
loss[1] = 0



### Model Definition
include("../../JuliaCP.jl")
using .JuliaCP

## Solver Definition
solver = Engine.LearnieCP()

## Variables Definition
x = Engine.makeIntVarArray(solver, numberOfOrders, 0, numberOfSlabs - 1) ## Orders variable
l = Engine.makeIntVarArray(solver, numberOfSlabs, 0, maxCapacity) ## Load in slab j
inSlab = Matrix{Engine.BoolVar}(undef, numberOfSlabs, numberOfOrders) ## inSlab[i, j] = 1 iff order j is placed in slab i

for j in 1:numberOfSlabs
    for i in 1:numberOfOrders
        inSlab[j, i] = Engine.IsEqual(x[i], j)
    end
end


for j in 1:numberOfSlabs ## Loop through all the slabs
    ## Check the presence of each color in each slab
    presence = Vector{Engine.BoolVar}(undef, numberOfColors)
    
    for col in 1:numberOfColors
        ## Create a BoolVar instance
        presence[col] = Engine.BoolVar(solver)

        inSlabWithColor = Vector{Engine.BoolVar}()
        for i in 1:numberOfOrders
            ## If the color of the order is equal to the current color, add the 
            ## boolean variable representing the presence/absence of the order in 
            ## slab j to the inSlabWithColor vector
            if(colors[i] == col)
                push!(inSlabWithColor, inSlab[j, i])
            end
        end

        ## presence[col] is true iff at least one order with color col is placed in slab j
        Engine.post(solver, Engine.IsOr(presence[col], inSlabWithColor))
    end

    ## Restrict the number of colors present to slab j to be <= 2
    slabNumColors = Engine.summation(presence)
    Engine.post(solver, Engine.lessOrEqual{Integer}(slabNumColors, maxNumberOfColorsPerSlab))
end


## The total weight stored per slab
totalWeightInSlab = Vector{Engine.AbstractVariable{Integer}}(undef, numberOfSlabs)
## The Bin-Packing constraint
## Ensure the total weight of the orders placed in the slab does
## not exceed the capacity of the slab
for j in 1:numberOfSlabs
    ## Array of all orders potentially placed in slab j
    ordersInSlabJ = Vector{AbstractVariable{Integer}}(undef, numberOfOrders)
    for i in 1:numberOfOrders
        ordersInSlabJ[i] = w[i] * inSlab[j, i]
    end

    push!(ordersInSlabJ, -l[j])
    ## Capacity-limit constraint
    weightInThisSlab = Engine.summation(ordersInSlabJ)
    # Engine.post(solver, Engine.Sum{Integer}(ordersInSlabJ, l[j]))
    totalWeightInSlab[j] = weightInThisSlab
end


### A redundant constraint
### The sum of the loads is equal to the sum of the items
Engine.post(solver, Engine.Sum{Integer}(l, sum(capacities)))

## Get the loss per slab
slabLosses = Vector{AbstractVariable{Integer}}(undef, numberOfSlabs)

for j in 1:numberOfSlabs
    slabLosses[j] = Engine.element1D(loss, totalWeightInSlab[j])  ## Food for thought - indexing
end

### Objective function - minimize the total loss
totalLoss = Engine.summation(slabLosses)
objective = Engine.Minimize{Integer}(totalLoss)

### Add static symmetry breaking constraint

### Implement a dynamic symmetry constraint

### Define the search

### Define the solution listener

### Optiimize
