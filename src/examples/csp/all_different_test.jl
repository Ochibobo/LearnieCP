## A test for the AllDifferent constraint
include("../../JuliaCP.jl")
using .JuliaCP

solver = Engine.LearnieCP()

x = Engine.Variables.makeIntVarArray(solver, 4, 1, 4)

allDiff = Engine.AllDifferentDC{Integer}(x)
Engine.post(solver, allDiff)
Engine.post(solver, Engine.ConstEqual{Integer}(x[1], 1))

for (i, v) in enumerate(x)
    println("Variable $i has minimum = $(Engine.minimum(v)) and maximum = $(Engine.maximum(v))")
end