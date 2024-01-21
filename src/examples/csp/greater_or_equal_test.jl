## A test for greater or equal constraint
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

x = Engine.IntVar(solver, 3, 5)
y = Engine.IntVar(solver, 0, 9)

Engine.post(solver, Engine.GreaterOrEqual{Integer}(x, y))

minimum(x)
maximum(x)

minimum(y)
maximum(y)