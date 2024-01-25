include("../../JuliaCP.jl")

using .JuliaCP

## A test on the Sum constraint
solver = Engine.LearnieCP()

## Variable declaration
# A = Engine.IntVar(solver, 0, 9)
# B = Engine.IntVar(solver, 0, 9)
# C = Engine.IntVar(solver, 0, 9)
# D = Engine.IntVar(solver, 0, 9)
# C₁ = Engine.IntVar(solver, 0, 1)

# ## Constraints
# vars = [A, B, C, D]

# for i in eachindex(vars)
#     for j in eachindex(vars)
#         if i == j
#             continue
#         end

#         Engine.Solver.post(solver, Engine.NotEqual{Integer}(vars[i], vars[j]))
#     end
# end

# ## Equality
# Engine.Solver.post(solver, Engine.Equal{Integer}(C₁, C))

# ## C cannot be 0
# Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(C, 0))

# ## Sum constraint
# Engine.Solver.post(solver, Engine.Sum{Integer}(A, B, -D, -10C₁))

# push!(vars, C₁)
# ## Branching strategy
# function branchingSchema()
#     idx = nothing
#     for i in eachindex(vars)
#       if(!Engine.isFixed(vars[i]))
#         idx = i
#         break
#       end
#     end

#     if isnothing(idx)
#       return []
#     end

#     ## Get the target variable
#     var = vars[idx]
#     ## Get the minimum value
#     var_min = Engine.minimum(var)
    
#     ## Branch when var = min
#     function left()
#       return Engine.Solver.post(solver, Engine.ConstEqual{Integer}(var, var_min))
#     end

#     ## Branch when var != min
#     function right()
#       return Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(var, var_min))
#     end

#     return [left, right]
# end


# search = Engine.DFSearch(Engine.Solver.stateManager(solver), branchingSchema)

# solutions = []
# ## Print out the solution once found
# Engine.addOnSolution(search, () -> begin
#     push!(solutions, [Engine.minimum(A), Engine.minimum(B), Engine.minimum(C), Engine.minimum(D)]);
#     return nothing
#   end
# )

# Engine.solve(search)

# for vals in solutions
#   A = vals[1]
#   B = vals[2]
#   C = vals[3]
#   D = vals[4]
  
#   print("$(A) + $(B) = ")
#   println("$(C)$(D)")
#   println()
# end

# length(solutions)



"""
      C₁
         A
         B
      -----
      C  D
"""



### Test 1
y = Engine.IntVar(solver, -100, 100)
x = [
  Engine.IntVar(solver, 0, 5),
  Engine.IntVar(solver, 1, 5),
  Engine.IntVar(solver, 0, 5)
]

Engine.post(solver, Engine.Sum{Integer}(x, y))

minimum(y)
maximum(y)

### Test 2
x = [
  Engine.IntVar(solver, -5, 5),
  Engine.IntVar(solver, 1, 2),
  Engine.IntVar(solver, 0, 1)
]

y = Engine.IntVar(solver, 0, 100)

Engine.post(solver, Engine.Sum{Integer}(x, y))

minimum(x[1])
minimum(y)
maximum(y)


### Test 3
solver = Engine.LearnieCP()

x = [
  Engine.IntVar(solver, -5, 5),
  Engine.IntVar(solver, 1, 2),
  Engine.IntVar(solver, 0, 1)
]

y = Engine.IntVar(solver, 5, 5)

Engine.post(solver, Engine.Sum{Integer}(x, y))

## 1-5 + 1-2 + 0-1 = 5
Engine.Variables.removeBelow(x[1], 1)

## 1-5 + 1 + 0-1 - 5
Engine.Variables.fix(x[2], 1)

Engine.Solver.fixPoint(solver)

minimum(x[1])
maximum(x[1])

minimum(x[3])
maximum(x[3])


### Test 4
x = [
  Engine.IntVar(solver, 0, 5),
  Engine.IntVar(solver, 0, 2),
  Engine.IntVar(solver, 0, 1)
]

Engine.post(solver, Engine.Sum{Integer}(x, 0))

[maximum(var) for var in x]


### Test 5
x = [
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -3, 0)
]

Engine.post(solver, Engine.Sum{Integer}(x, 0))

[maximum(var) for var in x]


### Test 6
x = [
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -3, 3)
]

Engine.post(solver, Engine.Sum{Integer}(x, 0))

minimum(x[1])
minimum(x[2])

Engine.Variables.removeAbove(x[3], 0)

Engine.Solver.fixPoint(solver)

[minimum(var) for var in x]


### Test 7
x = [
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -5, 0),
  Engine.IntVar(solver, -3, 3)
]

Engine.post(solver, Engine.Sum{Integer}(x, 0))

minimum(x[1])
minimum(x[2])

Engine.Variables.remove(x[3], 1)
Engine.Variables.remove(x[3], 2)
Engine.Variables.remove(x[3], 3)
Engine.Variables.remove(x[3], 4)
Engine.Variables.remove(x[3], 5)

Engine.Solver.fixPoint(solver)

[minimum(var) for var in x]


### Test 8
x = [
  Engine.IntVar(solver, -3, 3),
  Engine.IntVar(solver, -3, 3),
  Engine.IntVar(solver, -3, 3)
]

Engine.post(solver, Engine.Sum{Integer}(x, 0))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))
Engine.solve(search)

stats = search.searchStatistics
stats.numberOfSolutions

### Test 9
x = [Engine.IntVar(solver, -9, -9)]
failed = false

try
  Engine.post(solver, Engine.Sum{Integer}(x, 0))
catch ex
  _ = ex
  failed = true
end

failed


### Test 10
x = Engine.IntVar(solver, -9, -4)
failed = false

try
  Engine.post(solver, Engine.Sum{Integer}(x, 0))
catch ex
  _ = ex
  failed = true
end

failed



include("../../JuliaCP.jl")
using .JuliaCP

## A test on the Sum constraint
solver = Engine.LearnieCP()

### Test 11
x = [
  Engine.IntVar(solver, -4, 3) * 5,
  Engine.IntVar(solver, -4, 3) * 5,
  Engine.IntVar(solver, -4, 3) * 5
]

x1 = x[1]
v = zeros(Integer, size(x1))

Engine.Variables.fillArray(x1, v)
Engine.Variables.removeBelow(x1, -11)
Engine.Variables.fillArray(x1, v)   

Engine.post(solver, Engine.Sum{Integer}(x, 0))
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))

try
  Engine.solve(search)
catch ex
  _ = ex
end

stats = search.searchStatistics
stats.numberOfSolutions


### Test 12
include("../../JuliaCP.jl")
using .JuliaCP

solver = Engine.LearnieCP()
N = 11
y = [Engine.BoolVar(solver) for _ in 1:N]
cost = ones(Integer, N)

k = [cost[i] * y[i] for i in 1:N]

Engine.post(solver, Engine.Sum{Integer}(k, 1))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(y))

try
  Engine.solve(search)
catch ex
  _ = ex
end

stats = search.searchStatistics
stats.numberOfSolutions


### Test 13
include("../../JuliaCP.jl")
using .JuliaCP

solver = Engine.LearnieCP()
x = [Engine.BoolVar(solver) for _ in 1:10]

Engine.post(solver, Engine.Sum{Integer}(x, 1))

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x))

try
  Engine.solve(search)
catch ex
  _ = ex
end

search.searchStatistics


### Test 14
include("../../JuliaCP.jl")
using .JuliaCP

solver = Engine.LearnieCP()
N = 3
M = 10
MAX = 1
x = Matrix{Engine.BoolVar}(undef, M, N)

for i in 1:M
  for j in 1:N
    x[i, j] = Engine.BoolVar(solver)
  end

  Engine.post(solver, Engine.Sum{Integer}(x[i, :], MAX))
end

facility_cost = Engine.summation(x...)
objective = Engine.Minimize{Integer}(facility_cost)

search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x...))

try
  Engine.optimize(objective, search)
catch ex
  _ = ex
end

search.searchStatistics