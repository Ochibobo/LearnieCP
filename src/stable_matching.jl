## Implementation of the Stable Matching
include("JuliaCP.jl")

using .JuliaCP

## Solver instance
solver = Engine.LearnieCP()

## Number of variables
n = 4

## The rank order
## Student rank of companies = Matrix{Integer}(undef, n, n)
rankCompanies = Integer[
    1  2  3  4;
    2  1  3  4;
    1  4  3  2;
    4  3  2  1;
]
## Companies rank of students = Matrix{Integer}(undef, n, n)
rankStudents = [
    1  2  3  4;
    4  3  2  1;
    1  2  3  4;
    3  4  2  1;
]


## Variable Definition
## company[s] is the company chosen for student s
company = Variables.makeIntVarArray(solver, n, 1, n)

## student[c] is the student chosen for company c
student = Variables.makeIntVarArray(solver, n, 1, n)

## Preference variables
## companyPref[s] is the preference of student s for the company chosen for s
companyPref = Variables.makeIntVarArray(solver, n, 1, n)

## studentPref[c] is the preference for company c for the student chosen for c
studentPref = Variables.makeIntVarArray(solver, n, 1, n)

## TODO: is AllDifferent a factor?

## The assignment constraints
for s in 1:n
    ## Model this with Element1DVar: the student of the company of student s is s
    zₛ = Variables.IntVar(solver, 1, n)
    ## Fix zₛ to the value of s
    Variables.fix(zₛ, s)
    ## Element1DVar for indexing
    ## company[sᵢ] = cⱼ - student sᵢ is matched to company cⱼ
    ## student[cⱼ] = sᵢ - company cⱼ is matched to student sᵢ
    Engine.Solver.post(solver, Engine.Element1DVar{Integer}(student, company[s], zₛ))

    ## Model this with Element1D: rankCompanies[s][company[s]] = companyPref[s]
    Engine.Solver.post(solver, Engine.Element1D{Integer}(rankCompanies[s], company[s], companyPref[s]))
end

for c in 1:n
    ## Model this with Element1DVar: the company of the student of company c is c
    zᵪ = Variables.Intvar(solver, 1, n)
    ## Fix zᵪ to c
    Variables.fix(zᵪ, c)
    ## Element1DVar for indexing
    ## student[cᵢ] = sⱼ - company cᵢ is matched to student cᵢ
    ## company[sⱼ] = cᵢ - student sⱼ is matched to company cᵢ
    Engine.Solver.post(solver, Engine.Element1DVar{Integer}(company, student[c], zᵪ))

    ## Model this with Element1D: rankStudents[c][student[c]] = studentPref[c]
    Engine.Solver.post(solver, Engine.Element1D{Integer}(rankStudents[c], student[c], studentPref[c]))
end

## Meaning a => b | !a v b | a + b = 1
function implies(a::Engine.Variables.BoolVar, b::Engine.Variable.BoolVar)::Engine.Variables.BoolVar
    return Engine.IsGreaterOrEqual(Engine.Sum{Integer}([a, b]), 1)
end

## The stability rules constraint
for s in 1:n
    for c in 1:n
        ## if student s prefers company c over the chosen company, then the opposite is not true: c prefers their chosen student over s
        ## (companyPref[s] > rankCompanies[s][c]) => (studentPref[c] < rankStudents[c][s])
        
        sPrefc = Engine.IsGreater(companyPref[s], rankCompanies[s, c])
        cPrefItsStudent = Engine.isLess(studentPref[c], rankStudents[c, s])
        Engine.post(solver, implies(sPrefc, cPrefItsStudent)) ## Post the implication
        
        ## if company c prefers student s over their chosen student, then the opposite is not true: s prefers the chosen company over c
        ## (studentPref[c] > rankStudents[c][s]) => (companyPref[s] < rankCompanies[s][c])

        cPrefS = Engine.IsGreater(studentPref[c], rankStudents[c, s])
        sPrefItsCompany = Engine.isLess(companyPref[s], rankCompanies[s, c])
        Engine.post(solver, implies(cPrefS, sPrefItsCompany))
    end
end


## TODO: Search Definition & Branching Schema formulation
## TODO: Solve the search
## TODO: Print the results
## TODO: Plot the results - GraphRecipes
