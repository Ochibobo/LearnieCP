"""
NQueens backtracking solver

This is backtracking; however, it overrides the solutions presented from the previous tree as it's way of unchoosing.

Can replace the board to hold boolean variables instead of integers, however, you may need the n * n board instead.
    - Think of how to use a sum Constraint
    - Or an & per row/column/diagonal

Redo NQueens after the Sum Constraint
"""

"""
Backtracking solution to the NQueens problem
"""
function backtrackNQueens(n::Integer)::Nothing
    ## No solution for smaller boards
    if n in [2, 3]
        @info "No solution for boards with $(n) columns."
        return
    end

    board::Vector{Integer} = zeros(Integer, n)
    dfs(board, 1, n)
end


"""
Search function
    - We expore the entire search tree for when a node's value is set to i.
"""
function dfs(board::Vector{T}, index::T, n::T)::Nothing where T <: Integer
    if(index == n + 1)
        ## Verificiation is done after every candidate solution.
        ## Very inefficient - if verification is done before branching, no need to verify here again.
        if(verified(board, n))
            ## Can save a clone of the board too.
            @show board
            println()
        end
    else
        ## Explore the entire search space.
        for i in 1:n
            ## index represents the column, i represents the row where the queen is placed.
            board[index] = i
            ## Can include verification here before calling DFS
            dfs(board, index + 1, n)
        end
    end
end


"""
Constraint satisfaction functon
"""
function verified(board::Vector{T}, n::T)::Bool where T<: Integer
    ## Verify per selection
    for i in 1:n
        for j in i+1:n
            ## No 2 queens are on the same row
            if(board[i] == board[j]) return false end

            ## No 2 queens are on the same diagonal (Good Constraint)
            ## Verify that there is no triangle formed by the positioning of the queens.
            ## For a square matrix, triangles tend to be isosceles in nature
            ## So if the distance between the value decided for the rows is equal to the values of j & i, you have a triangle.
            ## j & i represent the columns.
            ## board[i] && board[j] represent the rows with queens in columns i & j respectively.
            ## Boils down to comparing the difference between the row positions of the queens & their columnar position; are the sides equal (isosceles triangle)
            if(abs(board[i] - board[j]) == (j - i)) return false end
        end
    end

    return true
end