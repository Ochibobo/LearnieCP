## Tests for the Or constraint
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Boolean Variables vector
x = [Engine.BoolVar(solver) for _ in 1:4]

## Post the Or constraint
Engine.post(solver, Engine.Or(x))

for var in x
    println("Is variable true? ", Engine.isTrue(var))
end

## Mark 2:4 as false
Engine.post(solver, Engine.ConstEqual{Integer}(x[2], false))
Engine.post(solver, Engine.ConstEqual{Integer}(x[3], false))
Engine.post(solver, Engine.ConstEqual{Integer}(x[4], false))

println("Is variable true? ", Engine.isTrue(x[1]))



### Number of nodes stats
solver = Engine.LearnieCP()
x = [Engine.BoolVar(solver) for _ in 1:4]

## Post the Or constraint
Engine.post(solver, Engine.Or(x))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))

Engine.solve(search)

ss = search.searchStatistics
ss


### A Test that should Fail
solver = Engine.LearnieCP()
x = [Engine.BoolVar(solver) for _ in 1:4]

for var in x
    Engine.fix(var, false)
end

try
    Engine.post(solver, Engine.Or(x))
catch e
    _ = e
    println("Failed...")
end


### 
