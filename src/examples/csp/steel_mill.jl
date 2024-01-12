### Steel Mill Problem
using OffsetArrays

## Read the bench file
path = "./data/steel/bench_20_01"
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
base_loss_vector = zeros(Int, maxCapacity + 1)
# loss = OffsetVector(base_loss_vector, 0:maxCapacity)
loss = base_loss_vector
capaIdx = 1

## Update the minimum loss per load level
for i in 1:maxCapacity
    loss[i + 1] = capacities[capaIdx] - i
    if loss[i + 1] == 0
        capaIdx += 1
    end
end

# vscodedisplay(loss)

### Model Definition
include("../../JuliaCP.jl")
using .JuliaCP

## Solver Definition
solver = Engine.LearnieCP()

## Variables Definition
x = Engine.makeIntVarArray(solver, numberOfOrders, 1, numberOfSlabs) ## Orders variable
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


## The Bin-Packing constraint
## Ensure the total weight of the orders placed in the slab does
## not exceed the capacity of the slab
for j in 1:numberOfSlabs
    ## Array of all orders potentially placed in slab j
    ordersInSlabJ = Vector{Engine.AbstractVariable{Integer}}(undef, numberOfOrders)
    for i in 1:numberOfOrders
        ordersInSlabJ[i] = weights[i] * inSlab[j, i]
    end

    ## Capacity-limit constraint
    Engine.post(solver, Engine.Sum{Integer}(ordersInSlabJ, l[j]))
end


### A redundant constraint
### The sum of the loads is equal to the sum of the items
Engine.post(solver, Engine.Sum{Integer}(l, sum(weights)))

## Get the loss per slab
slabLosses = Vector{Engine.AbstractVariable{Integer}}(undef, numberOfSlabs)

for j in 1:numberOfSlabs
    slabLosses[j] = Engine.element1D(loss, l[j] + 1)  ## Food for thought - indexing - solved by an offset vector
end

### Objective function - minimize the total loss
totalLoss = Engine.summation(slabLosses)
objective = Engine.Minimize{Integer}(totalLoss)

### Add static symmetry breaking constraint
### A lexographical constraint (LessOrEqual) to make sure the loads of the slabs are increasing.
# for i in 1:(numberOfSlabs - 1)
#     Engine.post(solver, Engine.LessOrEqual{Integer}(l[i], l[i + 1]))
# end

### Define the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), () -> begin
    idx = nothing
    for i in 1:numberOfOrders
        ## Find an unfixed order variable
        if !Engine.isFixed(x[i])
            idx = i
            break
        end
    end

    ## If all variables are fixed, return an empty branch
    if isnothing(idx)
        return []
    end

    ### Implement a dynamic symmetry constraint used in branching and search definition
    maxFilledSlabIdx = 0
    fixed = filter(v -> Engine.isFixed(v), x)
    ## Update the maxFilledSlabIdx index
    if !isempty(fixed)
        maxFilledSlabIdx = maximum(maximum.(fixed))
    end
    
    ## Storage of branch functions
    branches = Vector{Function}()
    ### Try at most upto one empty Bin
    for j in 1:min(maxFilledSlabIdx + 1, numberOfSlabs)
        if in(j, x[idx])
            ## Create a branch by fixing x[idx] to j
            branchFn = function ()
                return Engine.post(solver, Engine.ConstEqual{Integer}(x[idx], j))
            end
            ## Append the branch to the vector of branches
            push!(branches, branchFn)
        end
    end

    return branches
end)

### Monitor the total loss progress
lossProgress = Vector{Int}()
## Store in what slab orders are placed
orders = Vector{Int}(undef, numberOfOrders)
## Store the load in the particular slab
loads = zeros(Int, numberOfSlabs)
## Store the colors per slab
slabColors = [Set{Int}() for _ in 1:numberOfSlabs]

### Define the solution listener
Engine.addOnSolution(search, () -> begin
    for i in 1:numberOfOrders
        ## Get the assigned slab
        slab = minimum(x[i])
        ## Store the slab in which order `i` is placed in
        orders[i] = slab
        ## Store the load of the slab
        loads[slab] = minimum(l[slab])
        ## Add the color of the order to the slabColors
        push!(slabColors[slab], colors[i])
    end
    
    push!(lossProgress, minimum(totalLoss))
end)

### Optiimize
Engine.optimize(objective, search)


lossProgress
loads

orders
## Plot Loss progress
## Assert the assigned colors <= 2
## Assert weight is not exceeded
## Assert the total load == sum(capacities)
## Check the number of nodes traversed
## Histogram plot for the slabs with orders assigned to them