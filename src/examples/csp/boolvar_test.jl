### A test of the BoolVar
include("../../JuliaCP.jl")

using .JuliaCP

## A solver instance
solver =  Engine.LearnieCP()

## Boolean variable example
# b = Engine.Variables.BoolVar(solver)

# Engine.maximum(b)
# Engine.minimum(b)

# ## Fix b to 1
# Engine.fix(b, true)

# ## Mark b as not
# r = Engine.Variables.not(b)

# Engine.maximum(r)
# Engine.minimum(r)

# j = Engine.Variables.not(r)

# Engine.minimum(j)
# Engine.maximum(j)

# k = !j

# Engine.minimum(k)
# Engine.maximum(k)


a = Engine.Variables.BoolVar(solver)
# b = Engine.Variables.BoolVar(solver)
b = !a

# Engine.post(solver, Engine.NotEqual{Integer}(a, b))
maximum(a)
minimum(a)
maximum(b)
minimum(b)

Engine.post(solver, Engine.ConstEqual{Integer}(a, true))

Engine.isFixed(a)
Engine.isFixed(b)

maximum(a)
minimum(a)
maximum(b)
minimum(b)

a = Engine.Variables.BoolVar(solver)
Engine.post(solver, Engine.ConstEqual{Integer}(a, true))

maximum(a)
minimum(a)
maximum(b)
minimum(b)