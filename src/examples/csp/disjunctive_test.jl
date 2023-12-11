## Tests for the disjunctive constraint
include("../../JuliaCP.jl")

using .JuliaCP

## Testing AllDiff Disjunctive
solver = Engine.LearnieCP();
x = Engine.makeIntVarArray(solver, 5, 0, 4);
durations = fill(1, 5);
disjunctive = Engine.Disjunctive{Integer}(x, durations);
Engine.post(solver, disjunctive);

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x));
Engine.addOnSolution(search, () -> begin
   println("Solution found.\n\n\n")
end)
Engine.solve(search);

ss = search.searchStatistics
println(ss)


## Test overload checker - works
sA = Engine.IntVar(solver, 0, 9)
sB = Engine.IntVar(solver, 1, 10)
sC = Engine.IntVar(solver, 3, 7)
vars = [sA, sB, sC]

disjunctive = Engine.Disjunctive{Integer}(vars, Integer[5, 5, 6])

Engine.post(solver, disjunctive)



## Test Detectable Preference = works
sA = Engine.IntVar(solver, 0, 8)
sB = Engine.IntVar(solver, 1, 9)
sC = Engine.IntVar(solver, 8, 14)
vars = [sA, sB, sC]

disjunctive = Engine.Disjunctive{Integer}(vars, Integer[5, 5, 3])
Engine.post(solver, disjunctive)

minimum(sC)


## Test Not Last
sA = Engine.IntVar(solver, 0, 9)
sB = Engine.IntVar(solver, 1, 10)
sC = Engine.IntVar(solver, 3, 9)

vars = [sA, sB, sC]

disjunctive = Engine.Disjunctive{Integer}(vars, Integer[5, 5, 4])

Engine.post(solver, disjunctive)

maximum(sC)
maximum(sA)


## Test Binary Decomposition
sA = Engine.IntVar(solver, 0, 10)
sB = Engine.IntVar(solver, 6, 15)

vars = [sA, sB]

disjunctive = Engine.Disjunctive{Integer}(vars, [10, 6])

Engine.post(solver, disjunctive)

minimum(sB)

### Test
s = Engine.makeIntVarArray(solver, 4, 0, 19)
d = [5, 4, 6, 7]

Engine.post(solver, Engine.Disjunctive{Integer}(s, d))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(s))
Engine.solve(search)

ss = search.searchStatistics



### General Test 1
sA = Engine.IntVar(solver, 0, 9)
sB = Engine.IntVar(solver, 1, 10)
sC = Engine.IntVar(solver, 3, 9)

vars = [sA, sB, sC]

disjunctive = Engine.Disjunctive{Integer}(vars, Integer[5, 5, 4])

Engine.post(solver, disjunctive)


for v in vars
    @show minimum(v)
    @show maximum(v)

    println()
end


### General Test 2
sA = Engine.IntVar(solver, 0, 9)
sB = Engine.IntVar(solver, 1, 10)
sC = Engine.IntVar(solver, 8, 15)

vars = [sA, sB, sC]

disjunctive = Engine.Disjunctive{Integer}(vars, Integer[5, 5, 3])

Engine.post(solver, disjunctive)

minimum(sC)
maximum(sC)

for v in vars
    @show size(v)
end