include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

startA = Engine.IntVar(solver, 0, 5)
startB = Engine.IntVar(solver, 0, 3)

durA = 3
durB = 5

disjunctiveBinary = Engine.DisjunctiveBinary{Integer}(startA, durA, startB, durB)

Engine.post(solver, disjunctiveBinary)

# Engine.isFixed(Engine.before(disjunctiveBinary))

# Engine.isTrue(Engine.after(disjunctiveBinary))

# Engine.slack(disjunctiveBinary)

## Further tests
## Tighten the lst of startA
Engine.post(solver, Engine.lessOrEqual(startA, 2))

"""
// The situation is the following:
// A = [ --- ]    est = 0, lst = 2, dur = 3
// B = [ -----  ] est = 0, lst = 3, dur = 5
// It is clearly impossible given the time windows that B comes before A
// therefore the constraint should detect that B should come after A
"""

minimum(startA)
maximum(startA)
minimum(startB)
maximum(startB)

Engine.isFixed(Engine.before(disjunctiveBinary))
Engine.isFixed(disjunctiveBinary)
Engine.isFalse(Engine.after(disjunctiveBinary))
Engine.slack(disjunctiveBinary)