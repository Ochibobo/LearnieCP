## An implementation of the magic square problem

include("../../JuliaCP.jl")

using .JuliaCP
using LinearAlgebra

solver = Engine.LearnieCP()

## Variable Definition
rows = 3
n = rows * rows

## Create a square instance
square = Matrix{Engine.IntVar}(undef, rows, rows)

for row in 1:rows
    square[row, :] = Engine.Variables.makeIntVarArray(solver, rows, 1, n)
end


## Calculate the sums
all_sums = Vector{Engine.IntVar}()

## Convert the square_vec to a matrix
# square = reshape(square_vec, (rows, rows))

## Get the sum of the rows
for row in eachrow(square)
    summation = Engine.summation(Vector(row))
    push!(all_sums, summation)
end

## Get the sum of all columns
for col in eachcol(square)
    summation = Engine.summation(Vector(col))
    push!(all_sums, summation)
end

## Diagonal sums
right_diag_sum = Engine.summation(diag(square))
push!(all_sums, right_diag_sum)

## Get the reverse diagonal
diag_entry = Vector{Engine.IntVar}()
col = rows
for row in eachindex(eachrow(square))
    push!(diag_entry, square[row, col])
    col -= 1;
end

left_diag_sum = Engine.summation(diag_entry)
push!(all_sums, left_diag_sum)


## An Equals constraint
for i in 2:length(all_sums)
    Engine.post(solver, Engine.Equal{Integer}(all_sums[i - 1], all_sums[i]))
end

## Assert that all variables are different
allDiff = Engine.AllDifferentBinary{Integer}(vcat(square...))
Engine.Solver.post(solver, allDiff)


## Create the search function
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(vcat(square...)))

## Print On Solution
function printSolution()
    println("=========================")
    for row in eachrow(square)
        println(Engine.minimum.(row))
    end
    println("=========================")
end

## Add onSolution
Engine.addOnSolution(search, printSolution)

Engine.solve(search)
