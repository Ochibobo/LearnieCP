include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Define an all-different constraint on the Sudoku Puzzle

## The initial solution
init_sol = [
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
]

## Board definition based on constraints and variables
n = 9
board = Matrix{Engine.IntVar}(undef, n, n)
for i in 1:n
    for j in 1:n
        board[i, j] = Engine.IntVar(solver, 1, n)
    end
end

## Mark the fixed areas
for i in 1:9
    for j in 1:9
        val = init_sol[i, j]
        if val > 0
            ## Mark the variable as being fixed
            Engine.Solver.post(solver, Engine.ConstEqual{Integer}(board[i, j], val))
        end
    end
end


"""
NotEqual constraint definition for:
    Rows
    Columns
    Squares
"""

for i in 1:n
    for j in 1:n
        for k in (j + 1):n
            ### Row constraints
            Engine.Solver.post(solver, Engine.NotEqual{Integer}(board[i, j], board[i, k]))
            ### Column constraints
            Engine.Solver.post(solver, Engine.NotEqual{Integer}(board[j, i], board[k, i]))
        end
    end
end

### Function used to get the appropriate square
function verifySquare(row::Integer, col::Integer, board::Matrix{Engine.IntVar})
    squareRow = (convert(Integer, floor((row - 1) / 3)) * 3) + 1
    squareCol = (convert(Integer, floor((col - 1) / 3)) * 3) + 1

    for i in squareRow:(squareRow + 2)
        for j in squareCol:(squareCol + 2)
            ## Skip the entry containing the row & col
            if(i == row && j == col)
                continue
            else
                try
                    Engine.Solver.post(solver, Engine.NotEqual{Integer}(board[row, col], board[i, j]))
                catch e
                    println("Failed because of: ($i, $j) being empty when working on constraints for ($row, $col) on square ($squareRow, $squareCol)")
                    throw(e)
                end
            end
        end
    end
end


### Square constraints
for i in 1:n
    for j in 1:n
        verifySquare(i, j, board)
    end
end

"""
Branching Schema
"""
function branchingSchema()
    idx = nothing
    ## Pick the next available variable
    for i in 1:n
        for j in 1:n
            if(!Engine.isFixed(board[i, j]))
                idx = (i, j)
                break
            end
        end
    end

    ## This means that search can no longer proceed - either there's a solution found or an error
    if isnothing(idx)
        return []
    end

    ## Pick the next candidate variable
    i, j = idx
    sudoku_var = board[i, j]
    ## Get the minimum value in the variable's domain
    s_min = Engine.minimum(sudoku_var)

    ## Branching functions
    function left()
        return Engine.Solver.post(solver, Engine.ConstEqual{Integer}(sudoku_var, s_min))
    end

    function right()
        return Engine.Solver.post(solver, Engine.ConstNotEqual{Integer}(sudoku_var, s_min))
    end

    return [left, right]
end


## Define the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), branchingSchema)

## Function to dispaly the solution
Engine.addOnSolution(search, () -> begin
    println("Solution found")
    for i in 1:n
        for j in 1:n
            print("$(Engine.minimum(board[i, j])) ")
        end
        println()
    end
end)

## Solve
Engine.solve(search)