## A test for the IsLessOrEqual constraint
include("JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## A true value is expected
v4 = Engine.Variables.IntVar(solver, 4, 8)
v = 6
b4 =  Engine.Variables.BoolVar(solver)
c = Engine.IsLessOrEqual{Integer}(b4, -v4, -v)
Engine.post(solver, c)
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(v4))
Engine.addOnSolution(search, () -> begin
    println( Engine.minimum(v4), " >= ", v , " ? ", Engine.isTrue(b4))
end)

Engine.solve(search)









## A false value is expected
v3 = Engine.Variables.IntVar(solver, 1, 5)
v = 0
b3 = Engine.Variables.BoolVar(solver)
Engine.post(solver, Engine.IsLessOrEqual{Integer}(b3, v3, v))
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(v3))
Engine.addOnSolution(search, () -> begin
    println(Engine.isTrue(b3))
end)

Engine.solve(search)



## A true value is expected

v1 = Engine.Variables.IntVar(solver, 1, 5)

v = 15

b1 = Engine.Variables.BoolVar(solver)

Engine.post(solver, Engine.IsLessOrEqual{Integer}(b1, v1, v))

Engine.isTrue(b1)

Engine.isFalse(b1)


## A true value is expected
v2 = Engine.Variables.IntVar(solver, 1, 5)
v = 5
b2 = Engine.Variables.BoolVar(solver)
Engine.post(solver, Engine.IsLessOrEqual{Integer}(b2, v2, v))
Engine.isTrue(b2)
Engine.isFalse(b2)
