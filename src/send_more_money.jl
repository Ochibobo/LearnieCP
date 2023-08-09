
include("JuliaCP.jl")

using .JuliaCP

"""
      C₄ C₃ C₂ C₁
         S  E  N  D
      +  M  O  R  E
    ------------
      M  O  N  E  Y
    ------------

4 carries:
C₁, C₂, C₃, C₄
"""

## Solver instance
solver = Engine.LearnieCP()

## Variable definition
S = Engine.IntVar(solver, 0, 9)
E = Engine.IntVar(solver, 0, 9)
N = Engine.IntVar(solver, 0, 9)
D = Engine.IntVar(solver, 0, 9)
M = Engine.IntVar(solver, 0, 9)
O = Engine.IntVar(solver, 0, 9)
R = Engine.IntVar(solver, 0, 9)
Y = Engine.IntVar(solver, 0, 9)

### Carries variables definition
C₁ = Engine.IntVar(solver, 0, 1)
C₂ = Engine.IntVar(solver, 0, 1)
C₃ = Engine.IntVar(solver, 0, 1)
C₄ = Engine.IntVar(solver, 0, 1)


## Constraints definition
### Not Equal constraint
vars = [S, E, N, D, M, O , R, Y]

for i in eachindex(vars)
  for j in eachindex(vars)
    ## Don't put a NotEqual constraint when i is j
    if i == j
      continue
    end

    ## Post the constraint to the solver
    Engine.Solver.post(solver, Engine.NotEqual{Integer}(vars[i], vars[j]))
  end
end

## Equals constraint
## Notice than C₁ == M
Engine.Solver.post(solver, Engine.Equal{Integer}(C₄, M))

## Notice that S & M cannot be equal to zero
Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(S, 0))
Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(M, 0))

## Sum constraint definition
Engine.Solver.post(solver, Engine.Sum{Integer}(D, E, -Y, -10C₁))
Engine.Solver.post(solver, Engine.Sum{Integer}(C₁, N, R, -E, -10C₂))
Engine.Solver.post(solver, Engine.Sum{Integer}(C₂, E, O, -N, -10C₃))
Engine.Solver.post(solver, Engine.Sum{Integer}(C₃, S, M, -O, -10C₄))


## Branching strategy
push!(vars, [C₁, C₂, C₃, C₄]...)
function branchingSchema()
    idx = nothing
    for i in eachindex(vars)
      if (!Engine.isFixed(vars[i]))
        idx = i
        break
      end
    end

    if isnothing(idx)
      return []
    end

    ## Get the target variable
    var = vars[idx]
    ## Get the minimum value
    var_min = Engine.minimum(var)
    
    ## Branch when var = min
    function left()
      return Engine.Solver.post(solver, Engine.ConstEqual{Integer}(var, var_min))
    end

    ## Branch when var != min
    function right()
      return Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(var, var_min))
    end

    return [left, right]
end


## Search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), branchingSchema)

## Print out the solution once found
Engine.addOnSolution(search, () -> begin
    println("Solution found")

    S = Engine.minimum(vars[1])
    E = Engine.minimum(vars[2])
    N = Engine.minimum(vars[3])
    D = Engine.minimum(vars[4])
    M = Engine.minimum(vars[5])
    O = Engine.minimum(vars[6])
    R = Engine.minimum(vars[7])
    Y = Engine.minimum(vars[8])
    C₁ = Engine.minimum(vars[9])
    C₂ = Engine.minimum(vars[10])
    C₃ = Engine.minimum(vars[11])
    C₄ = Engine.minimum(vars[12])

    println("$(C₄)  $(C₃)  $(C₂)  $(C₁)")
    println("  $(S)  $(E)  $(N)  $(D)")
    println("  $(M)  $(O)  $(R)  $(E)")
    println("$(M)  $(O)  $(N)  $(E)  $(Y)")
    println()
  end
)

Engine.solve(search)