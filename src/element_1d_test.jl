include("JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

T = Integer[10, 20, 15, 30]

y = Engine.Variables.IntVar(solver, 1, length(T))

z = Engine.element1D(T, y)

v = Vector{Integer}()
Engine.Variables.fillArray(z, v)

Engine.Variables.remove(y, 1)
Engine.Variables.remove(y, 4)

Engine.Variables.fillArray(z, v)

Engine.Solver.post(solver, Engine.ConstEqual{Integer}(y, 2))

Engine.minimum(y)
Engine.maximum(y)

Engine.Variables.fillArray(z, v)