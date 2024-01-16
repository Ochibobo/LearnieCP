## Test for the ConstGreaterThanOrEqual constraint
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

x = Engine.IntVar(solver, 0, 100)
minimum(x)
Engine.post(solver, Engine.ConstGreaterOrEqual{Integer}(x, 15))
minimum(x)
