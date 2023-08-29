### A test of the BoolVar
include("JuliaCP.jl")

using .JuliaCP

## A solver instance
solver =  Engine.LearnieCP()

## Boolean variable example
b = Engine.Variables.BoolVar(solver)

Engine.maximum(b)
Engine.minimum(b)

## Fix b to 1
Engine.fix(b, true)

## Mark b as not
r = Engine.Variables.not(b)

Engine.maximum(r)
Engine.minimum(r)

j = Engine.Variables.not(r)

Engine.minimum(j)
Engine.maximum(j)

k = !j

Engine.minimum(k)
Engine.maximum(k)