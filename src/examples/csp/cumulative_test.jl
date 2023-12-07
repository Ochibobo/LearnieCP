## A test for the cumulative constraint
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

s = Engine.makeIntVarArray(solver, 5, 0, 4)
d = fill(1, 5)
r = fill(100, 5)

Engine.post(solver, Engine.Cumulative{Integer}(s, d, r, 100))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(s))

Engine.addOnSolution(search, () -> begin
    println(map(v -> minimum(v), s))
end)
Engine.solve(search)

search.searchStatistics