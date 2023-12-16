## An implementation from Lecture 7 of UBC Data Structures and Algorithms Class by Mike Gelbart
## Link: (https://github.com/UBC-MDS/DSCI_512_alg-data-struct/blob/master/lectures/07_discrete-optimization.ipynb)

using DataFrames
using CSV
include("../../JuliaCP.jl")
using .JuliaCP

## The Teacher's Assignment Dataset
tas_df = CSV.read("./data/extern/ubc/TA_apps.csv", DataFrame)
## Cast the can_teach and enthusiastic columns to lists
tas_df[!, :can_teach] = split.(tas_df[:, :can_teach], ",")
tas_df[!, :enthusiastic] = split.(tas_df[:, :enthusiastic], ",")

tas_df

## Get the name of the teaching assistants
TAs = tas_df[:, :name]

## The course's DataFrame
courses_df = CSV.read("./data/extern/ubc/MDS_courses2021W1.csv", DataFrame)
# vscodedisplay(courses_df)

## Get the course instance
courses = courses_df[:, :course_number]

## Get the unique blocks
blocks = Set(courses_df[:, :block])

# courses
"""
Goal:  possibleMatch TAs to courses so that our staffing needs are covered in the best way

Constraints:
    - Each course should be assigned to exactly 2 TAs
    - A TA can cover only 1 course at a time in a given block
    - A TA can only be assigned to a course they have listed as "can teach" or "enthusiastic to teach"
    - To cover a course, a TA must be available for one of the 2 lab days

Objective: Maximize the number of assigned courses that TAs are enthusiastic about
"""

## DataFrame showing the association between TA's and courses
ta_with_courses_df = DataFrame(zeros(Int, length(TAs), length(courses)), string.(courses))
## Add the
insertcols!(ta_with_courses_df, 1, :name => TAs)

## Mark the TA-course intersect with 1
idx = 1
for row in eachrow(tas_df)
    ## Get the values from can_teach and enthusiastic
    assigned = Set(row[:can_teach])
    push!(assigned, row[:enthusiastic]...)
    assigned = parse.(Int, assigned)
    
    for course in assigned 
        if course in courses ## Needed to weed out course 532
            ta_with_courses_df[idx, string(course)] = 1
        end
    end

    idx += 1
end

println(ta_with_courses_df)

## For display purposes
#vscodedisplay(ta_with_courses_df)


"""
LearnieCP Model Definition
"""

## Define the solver
solver = Engine.LearnieCP()

nCourses = length(courses)
nTAs = length(TAs)
TAS_PER_COURSE = 2

## The variables are Boolean variables at the point of intersection between TAs and courses
x = Matrix{Engine.IntVar}(undef, nTAs, nCourses)

for i in 1:nTAs
    for j in 1:nCourses
        x[i, j] = Engine.IntVar(solver, 0, 1)
    end
end

## Each course should be assigned to 2 TAs
for course in eachindex(courses)
   Engine.post(solver, Engine.Sum{Integer}(x[:, course], TAS_PER_COURSE))
end

course_block_dict = Dict{Int, Vector{Int}}()

for row in eachrow(courses_df)
    list = get(course_block_dict, row[:block], [])
    push!(list, row[:course_number])
    course_block_dict[row[:block]] = list
end

# courses
## A TA can only cover 1 course at a time in a given block
for (i, tA) in enumerate(TAs)
    vars = Vector{Engine.AbstractVariable{Integer}}()
    for block in blocks
        ## Collect all courses in the block
        courses_in_block = course_block_dict[block]
        ## Get the indices
        course_indices = indexin(courses, courses_in_block)
        ## Use the indices to collect the variables
        vars = Vector{Engine.AbstractVariable{Integer}}()
        for j in course_indices
            if !isnothing(j)
                push!(vars, x[i, j])
            end
        end
    end

    ## Enforce a summation
    block_sum = Engine.summation(vars)

    ## Ensure the sum is <= 1
    Engine.post(solver, Engine.lessOrEqual{Integer}(block_sum, 1))
end


## A TA can only be assigned to a course they have listed as "can_teach" or "enthusiastic"
for i in eachindex(TAs)
    for (j, course) in enumerate(courses)
        if !in(string(course), tas_df[i, :can_teach]) && !in(string(course), tas_df[i, :enthusiastic])
            Engine.post(solver, Engine.ConstEqual{Integer}(x[i, j], 0))
        end
    end
end


## To cover a course, the TA must be available for one of the 2 lab days
for i in eachindex(TAs)
    days_available = tas_df[i, :availability]
    for j in eachindex(courses)
        days = courses_df[j, :lab_days]
        day_1 = days[1]
        day_2 = days[2]

        ## If the TA is unavailable in both days, 
        if !contains(days_available, day_1) && !contains(days_available, day_2)
            Engine.post(solver, Engine.ConstEqual{Integer}(x[i, j], 0))
        end
    end
end


## Objective definition: maximize the number of assigned courses that TAs are passionate about
objective_terms = Vector{Engine.AbstractVariable{Integer}}()

for i in eachindex(TAs)
    for (j, course) in enumerate(courses)
        if string(course) in tas_df[i, :enthusiastic]
            push!(objective_terms, x[i, j])
        end
    end
end


## Define the objective value
objective_value = Engine.summation(objective_terms)

## Maximize the objective value
objective = Engine.Minimize{Integer}(-objective_value)

## Define the search
search = Engine.DFSearch(Engine.Solver.stateManager(solver), Engine.FirstFail(x...))

Engine.addOnSolution(search, () -> begin
    println("Found solution...")
    println("----------------------------------------")

    ## Decision matrix
    m = zeros(Integer, nTAs, nCourses)

    for i in eachindex(TAs)
        for j in eachindex(courses)
            m[i, j] = minimum(x[i, j]) & maximum(x[i, j])
        end
    end

    answer_df = DataFrame(m, string.(courses))
    insertcols!(answer_df, 1, :name => TAs)

    println(answer_df)

    println("----------------------------------------")
end)

## Optimize the solution
Engine.optimize(objective, search)

search.searchStatistics


## Work on assertions
## Compare with UBC answers
## Get the objective value

