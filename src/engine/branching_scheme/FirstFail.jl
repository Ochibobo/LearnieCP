"""
    selectMin(v::Vector{AbstractVariable{T}}, fnTest::Function, fnComparison::Function)::Union{Nothing, AbstractVariable{T}} where T

Function to select the minimum variable in `v` that satisfies `fnTest` or `nothing` otherwise
"""
function SelectMin(v::Vector{<:AbstractVariable{T}}, fnTest::Function, fnComparison::Function)::Union{Nothing, AbstractVariable{T}} where T
    selectedVar = nothing

    for var in v
        if fnTest(var)
            selectedVar = isnothing(selectedVar) || (fnComparison(var, selectedVar)) ? var : selectedVar
            break
        end
    end

    return selectedVar
end



"""
    firstFail(vars::Vararg{AbstractVariable{T}}) where T

Function used to branch based on the first failed node as selected by the `selectMin` function
"""
function FirstFail(vars::Vararg{<:AbstractVariable{T}})::Function where T
    return () -> begin
        xVar = SelectMin(collect(vars),
            (var) -> !Variables.isFixed(var),
            (varA, varB) -> size(varA) < size(varB)
        )

        ## If all variables are fixed, return an empty branching scheme
        if isnothing(xVar)
            return []
        end
        ## Get the minimum of the selected variable
        xVarMin = minimum(xVar)

        return [
            () -> Solver.post(Variables.solver(xVar), Constraints.ConstEqual{T}(xVar, xVarMin)),
            () -> Solver.post(Variables.solver(xVar), Constraints.ConstNotEqual{T}(xVar, xVarMin))
        ]
    end 
end

function FirstFail(vars::Vector{<:AbstractVariable{T}})::Function where T
    return FirstFail(vars...)    
end