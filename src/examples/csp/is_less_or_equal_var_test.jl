include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

x = Engine.IntVar(solver, 0, 5)
y = Engine.IntVar(solver, 0, 5)

b = Engine.BoolVar(solver)

Engine.post(solver, Engine.IsLessOrEqualVar{Integer}(b, x, y))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x, y))

Engine.addOnSolution(search, () -> begin
    minX = minimum(x)
    minY = minimum(y)

    println((minX <= minY && Engine.isTrue(b)) || (minX > minY && Engine.isFalse(b)))
end)

Engine.solve(search)

ss = search.searchStatistics
ss.numberOfSolutions


### True Boolean
x = Engine.IntVar(solver, -8, 7)
y = Engine.IntVar(solver, -4, 3)

b = Engine.BoolVar(solver)

Engine.post(solver, Engine.IsLessOrEqualVar{Integer}(b, x, y))
Engine.post(solver, Engine.ConstEqual{Integer}(b, true))

maximum(x)
v = Vector{Integer}()
Engine.Variables.fillArray(x, v)


### False boolean
x = Engine.IntVar(solver, -8, 7)
y = Engine.IntVar(solver, -4, 3)

b = Engine.BoolVar(solver)

Engine.post(solver, Engine.IsLessOrEqualVar{Integer}(b, x, y))
Engine.post(solver, Engine.ConstEqual{Integer}(b, false))

minimum(x)
v = Vector{Integer}()
Engine.Variables.fillArray(x, v)

"""
x = [-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7]
y = [-4, -3, -2, -1, 0, 1, 2, 3]

[-3, -2, -1, 0, 1, 2, 3, 4]
"""