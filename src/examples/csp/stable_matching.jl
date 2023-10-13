## Implementation of the Stable Matching
include("../../JuliaCP.jl")

using .JuliaCP

## Solver instance
solver = Engine.LearnieCP()

## Number of variables
n = 9

## The rank order
## Student rank of companies = Matrix{Integer}(undef, n, n)
rankCompanies = [ 
    7 3 8 9 6 4 2 1 5;
    5 4 8 3 1 2 6 7 9;
    4 8 3 9 7 5 6 1 2;
    9 7 4 2 5 8 3 1 6;
    2 6 4 9 8 7 5 1 3;
    2 7 8 6 5 3 4 1 9;
    1 6 2 3 8 5 4 9 7;
    5 6 9 1 2 8 4 3 7;
    6 1 4 7 5 8 3 9 2;
]
## Companies rank of students = Matrix{Integer}(undef, n, n)
rankStudents = [
    3 1 5 2 8 7 6 9 4;
    9 4 8 1 7 6 3 2 5;
    3 1 8 9 5 4 2 6 7;
    8 7 5 3 2 6 4 9 1;
    6 9 2 5 1 4 7 3 8;
    2 4 5 1 6 8 3 9 7;
    9 3 8 2 7 5 4 6 1;
    6 3 2 1 8 4 5 9 7;
    8 2 6 4 9 1 3 7 5;
]


## Variable Definition
## student[c] is the student chosen for company c
student = Engine.Variables.makeIntVarArray(solver, n, 1, n)

## company[s] is the company chosen for student s
company = Engine.Variables.makeIntVarArray(solver, n, 1, n)

## Preference variables
## companyPref[s] is the preference of student s for the company chosen for s
companyPref = Engine.Variables.makeIntVarArray(solver, n, 1, n) 

## studentPref[c] is the preference for company c for the student chosen for c
studentPref = Engine.Variables.makeIntVarArray(solver, n, 1, n)

## TODO: is AllDifferent a factor?

## The assignment constraints
for s in 1:n
    ## Model this with Element1DVar: the student of the company of student s is s
    zₛ = Engine.Variables.IntVar(solver, 1, s)
    ## Fix zₛ to the value of s
    Engine.Variables.fix(zₛ, s)
    ## Element1DVar for indexing
    ## company[sᵢ] = cⱼ - student sᵢ is matched to company cⱼ
    ## student[cⱼ] = sᵢ - company cⱼ is matched to student sᵢ
    Engine.Solver.post(solver, Engine.Element1DVar{Integer}(student, company[s], zₛ))
    
    ## Model this with Element1D: rankCompanies[s][company[s]] = companyPref[s]
    Engine.Solver.post(solver, Engine.Element1D{Integer}(rankCompanies[s, :], company[s], companyPref[s]))
end


for c in 1:n
    ## Model this with Element1DVar: the company of the student of company c is c
    z = Engine.Variables.IntVar(solver, 1, c)
    ## Fix zᵪ to c
    Engine.Variables.fix(z, c)
    ## Element1DVar for indexing
    ## student[cᵢ] = sⱼ - company cᵢ is matched to student cᵢ
    ## company[sⱼ] = cᵢ - student sⱼ is matched to company cᵢ
    Engine.Solver.post(solver, Engine.Element1DVar{Integer}(company, student[c], z))
    ## Model this with Element1D: rankStudents[c][student[c]] = studentPref[c]
    Engine.Solver.post(solver, Engine.Element1D{Integer}(rankStudents[c, :], student[c], studentPref[c]))
end

## Meaning a => b | !a v b | !a + b = 1
function implies(a::Engine.Variables.BoolVar, b::Engine.Variables.BoolVar)::Engine.Variables.BoolVar
    return Engine.IsGreaterOrEqual(Engine.summation(!a, b), 1)
end

## The stability rules constraint
for s in 1:n
    for c in 1:n
        ## if student s prefers company c over the chosen company, then the opposite is not true: c prefers their chosen student over s
        ## (companyPref[s] > rankCompanies[s][c]) => (studentPref[c] < rankStudents[c][s])
        
        sPrefc = Engine.IsGreater(companyPref[s], rankCompanies[s, c])
        cPrefItsStudent = Engine.IsLess(studentPref[c], rankStudents[c, s])
        Engine.Solver.post(solver, implies(sPrefc, cPrefItsStudent)) ## Post the implication
        
        ## if company c prefers student s over their chosen student, then the opposite is not true: s prefers the chosen company over c
        ## (studentPref[c] > rankStudents[c][s]) => (companyPref[s] < rankCompanies[s][c])

        cPrefS = Engine.IsGreater(studentPref[c], rankStudents[c, s])
        sPrefItsCompany = Engine.IsLess(companyPref[s], rankCompanies[s, c])
        Engine.Solver.post(solver, implies(cPrefS, sPrefItsCompany))
    end
end

## 89 [0, 1], 117 [0, 1], 132 [0, 1], 137, 143, 144,  error
## Search Definition & Branching Schema formulation
branchingScheme = Engine.And(Engine.FirstFail(company), Engine.FirstFail(student))
search = Engine.DFSearch(Engine.Solver.stateManager(solver), branchingScheme)

## Print the results
Engine.addOnSolution(search, () -> begin
    students = map(s -> Engine.minimum(s) - 1, student)
    companies = map(c -> Engine.minimum(c) - 1, company)

    @show companies'
    @show students'
    
    println()
end)

## Solve the search
Engine.solve(search)

## TODO: Plot the results - GraphRecipes


"""
company: 5,0,3,7,4,6,2,1,8
student: 1,7,6,2,4,0,5,3,8

company: 5,0,3,7,4,8,2,1,6
student: 1,7,6,2,4,0,8,3,5

company: 5,3,0,7,4,6,2,1,8
student: 2,7,6,1,4,0,5,3,8

company: 5,3,8,7,2,6,0,4,1
student: 6,8,4,1,7,0,5,3,2

company: 5,4,8,7,2,6,0,3,1
student: 6,8,4,7,1,0,5,3,2

company: 6,4,8,7,2,5,0,3,1
student: 6,8,4,7,1,5,0,3,2
"""

using Graphs
using GraphPlot
function buildGraph(n::T, edgeList::Vector{T}) where {T <: Integer}
    ## Create a simple graph with n nodes
    g = SimpleGraph(n * 2)

    ## Create edges and connect vertices together
    for (u, v) in enumerate(edgeList)
        add_edge!(g, u, v + n)
    end

    ## Return the graph instance
    return g
end

## Plot the graph
edgeList = map(x -> x + 1, [5,0,3,7,4,6,2,1,8])
edgeList
graph = buildGraph(n, edgeList)
adjacency_matrix(graph)
nodelabel = 1:nv(graph)
gplot(graph, nodelabel=nodelabel)
