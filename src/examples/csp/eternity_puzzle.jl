## The eternity puzzle problem
include("../../JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Read the file
f = open("./data/eternity/brendan/pieces_04x04.txt")
data = readlines(f)
## Read the file dimensions
n, m = parse.(Int, split(data[1], " "))
data = data[2:end]
## Matrix to hold the pieces
pieces = Matrix{Int}(undef, n * m, 4) ## Each piece is defined by 4 parts, up, bottom, left & right

## Read the remaining set of lines
i = 1
for entry in data
    ## Split the entry based on spaces and convert them to int
    entry = strip(entry)
    if !isempty(entry)
        piece = parse.(Int, split(entry, " "))
        pieces[i, :] = piece
        i += 1
    end
end

## Get the maximum value of the pieces passed - maximum color value that will define the domains of each variable
maxVal = maximum(pieces)

pieces

function rotate(arr::Vector, n::Int, angle::Int)::Vector
    ans = Vector(undef, n)
    for i in 1:n
        idx = (i + angle)
        if idx != n
            idx %= n
        end
        ans[idx] = arr[i]
    end

    return ans
end

"""
Create the table where each line corresponds to one possible rotation of a piece
For instance if the line piece[6] = [2,3,5,1]
the four lines created in the table are
[6,2,3,5,1] // rotation of 0°
[6,3,5,1,2] // rotation of 90°
[6,5,1,2,3] // rotation of 180°
[6,1,2,3,5] // rotation of 270°
"""
table = Matrix{Int}(undef, 4 * n * m, 5)

rotations = 0:3 ## Rotations
ti = 1 ## table index
## Add the pieces to the table
for (index, piece) in enumerate(eachrow(pieces))
    index -= 1 ## To start indexing from zero
    ## Perform all rotations (0°, 90°, 180°, 270°)
    for rotation in rotations
        table[ti, :] = [index, rotate(Vector(piece), length(piece), rotation)...]
        ti += 1
    end
end
table

"""
     |         |
   - +---------+- -
     |    u    |
     | l  i  r |
     |    d    |
   - +---------+- -
     |         |
"""

## Variables definition
id = Matrix{Engine.IntVar}(undef, n, m)
up = Matrix{Engine.IntVar}(undef, n, m)
down = Matrix{Engine.IntVar}(undef, n, m)
left = Matrix{Engine.IntVar}(undef, n, m)
right = Matrix{Engine.IntVar}(undef, n, m)


## Create the up and id variables
for i in 1:n
    up[i, :] = Engine.Variables.makeIntVarArray(solver, m, 0, maxVal)
    id[i, :] = Engine.Variables.makeIntVarArray(solver, m, 0, (n * m) - 1)
end

## Create the down variables
for i in 1:n
    ## Set the down = up for variables whose down is not the bottom-most row
    if i < n
        down[i, :] = up[i + 1, :]
    else
        down[i, :] = Engine.Variables.makeIntVarArray(solver, m, 0, maxVal)
    end
end



## Create the left-most variables
for i in 1:m
    for j in 1:n
        left[i, j] = Engine.Variables.IntVar(solver, 0, maxVal)
    end
end


### Create the right-most variables
for i in 1:n
    for j in 1:m
        if j < m
            right[i, j] = left[i, j + 1]
        else
            right[i, j] = Engine.Variables.IntVar(solver, 0, maxVal)
        end
    end
end


### Constraint Definition
### Constraint 1:
### All the pieces placed are AllDifferent using the AllDifferentBinary constraint
### We have to flatten the matrix
allDiff = Engine.AllDifferentBinary{Integer}(vcat(id...))
Engine.Solver.post(solver, allDiff)

# for (index, entry) in enumerate(id)
#     Engine.size(entry)
#     v = Vector{Integer}()
#     println("id = $(index), value = ", Engine.Variables.fillArray(entry, v))
# end

### Constraint 2:
### All the pieces placed are valid ones i.e. one of the given (m x n) pieces possibly rotated
### Use the table constraint
data = Vector{Vector{Bool}}()
for i in 1:n
    for j in 1:m
        arr = Vector{Engine.IntVar}(undef, 5)
        v = Vector{Integer}()
        arr[1] = id[i, j]
        arr[2] = up[i, j]
        arr[3] = right[i, j]
        arr[4] = down[i, j]
        arr[5] = left[i, j]
        
        ## Create a table constraint for the same
        tableCT = Engine.TableCT{Integer}(arr, table)
        Engine.Solver.post(solver, tableCT)
    end
end

# c_data = mapreduce(permutedims, vcat, data)
# df_data = c_data'

# vscodedisplay(Int.(df_data))

# vscodedisplay(Int.(df_data[:, 10]))

# for (index, entry) in enumerate(id)
#     Engine.size(entry)
#     v = Vector{Integer}()
#     println("id = $(index), value = ", Engine.Variables.fillArray(entry, v))
# end



### Constraint 3:
### Make sure only '0's appear on the edges of the board
### All right & left edges
for i in 1:n  ## Loop through each row
    Engine.Variables.fix(left[i, 1], 0)
    Engine.Variables.fix(right[i, m], 0)
end


## All top & bottom edges
for i in 1:m
    Engine.Variables.fix(up[1, i], 0)
    Engine.Variables.fix(down[n, i], 0)
end

### Search instance
search = Engine.DFSearch(Engine.Solver.stateManager(solver), 
            Engine.And(
                Engine.FirstFail(vcat(id...)), Engine.FirstFail(vcat(up...)),
                Engine.FirstFail(vcat(right...)), Engine.FirstFail(vcat(down...)),
                Engine.FirstFail(vcat(left...))
            )
        )

#### Function to be called onSolution
function onSolution()
    println("--------------------")

    for i in 1:n
        print("   ")

        ## Print the top row
        for j in 1:m
            print("$(Engine.minimum(up[i, j]))   ")
        end
        println()
        print(" ")

        for j in 1:m
            print("$(Engine.minimum(left[i, j]))   ")
        end
        
        ## Print the rightmost element
        println("$(Engine.minimum(right[i, m]))")
    end

    ## Print the bottom-most row
    print("   ")
    for j in 1:m
        print("$(Engine.minimum(down[n, j]))   ")
    end
    println()
end


### Add the function to be executed when the solution is found
Engine.addOnSolution(search, onSolution)

## Run the solverdata/eternity/brendan/pieces_03x03.txt
Engine.solve(search)

# # vscodedisplay(table)

arr = [21, 29, 32, 33]
ans = falses(36)

for v in arr
    ans[v + 1] = true
end

df_data[:, 25]
ans

q = all(i -> isone(i), df_data[:, 10] .== ans)

vscodedisplay(Int.(df_data[:, 25]))

vscodedisplay(table)