## IsOr constraint Test
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()
x = [Engine.BoolVar(solver) for _ in 1:4]
b = Engine.BoolVar(solver)
Engine.post(solver, Engine.IsOr(b, x))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))
Engine.solve(search)

search.searchStatistics