## A test for the Element1DVar constraint
include("JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Variables definition
v1 = Engine.Variables.makeIntVarWithSparseDomain(solver, Integer[1, 3])
v2 = Engine.Variables.makeIntVarWithSparseDomain(solver, Integer[1, 2])
v3 = Engine.Variables.makeIntVarWithSparseDomain(solver, Integer[1, 9])
v4 = Engine.Variables.makeIntVarWithSparseDomain(solver, Integer[1, 2, 6])
zz = Engine.Variables.makeIntVarWithSparseDomain(solver, Integer[4, 6, 7])

## Create an array of variables
T = Engine.AbstractVariable{Integer}[v1, v2, v3, v4]

## Variable y
y = Engine.Variables.IntVar(solver, 1, 4)

Engine.Variables.fix(y, 4)

Engine.post(solver, Engine.Element1DVar{Integer}(T, y, zz))

## Enforce Element1DVar constraint
# z = Engine.element1DVar(T, y)


Engine.minimum(T[4])