include("JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

T = Integer[3, 4, 5, 5, 4, 3]

y = Engine.Variables.IntVar(solver, 1, 6)

z = Engine.element1D(T, y)

v = Vector{Integer}()
Engine.Variables.fillArray(z, v)

Engine.Variables.remove(y, 1)
Engine.Variables.remove(y, 6)

Engine.Variables.fillArray(z, v)
