include("JuliaCP.jl")

using .JuliaCP

## Solver Instance
solver = Engine.LearnieCP()

## The size of the board
n = 4

## Integer variables representing the queen positions
q = Engine.makeIntVarArray(solver, n, 0, n - 1)

## Constraint Definition
for i in 1:n
    for j in (i + 1):n
        ## Post a constraint to the solver that enforces the row constraint
        Engine.Solver.post(solver, Engine.NotEqual{Integer}(q[i], q[j]))
        ## Diagonal constraint
        Engine.Solver.post(solver, Engine.NotEqual{Integer}(q[i], q[j], (i - j)))
        ## Diagonal constraint
        Engine.Solver.post(solver, Engine.NotEqual{Integer}(q[i], q[j], (j - i)))
    end
end



function branchingSchema()
    idx = -1
    ## Loop through every queen position
    for k in eachindex(q)
        ## Check if the current queen is bound
        if size(q[k]) > 1
            idx = k
            break
        end
    end

    ## Asset that idx hasn't changed
    if idx == -1
        return []
    end

    ## Get the queen whose position is at hand
    q_var = q[idx]
    ## Get the minimum value in q_var's domain
    v = Engine.minimum(q_var)

    ## Where the queen in column q_var is in position min
    function left()
        Engine.Solver.post(solver, Engine.ConstEqual{Integer}(q_var, v))
    end

    ## Where queen in column q_var is not in position min
    function right()
        Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(q_var, v))
    end

    ## Create the 2 branches
    return [left, right]
end


## Search Definition
search = Engine.DFSearch(Engine.Solver.stateManager(solver), branchingSchema)

## Function to be executed on solution
Engine.setOnSolution(search, () -> begin
    println(repeat('*', 15))
    for i in eachindex(q)
        println("i = $i, v = $(Engine.minimum(q[i]))")
    end
    println(repeat('*', 15))
    println()
end)

## Solve
Engine.solve(search)

