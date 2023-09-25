## A test for the TableCT constraint
include("JuliaCP.jl")

using .JuliaCP

## Solver instance
solver = Engine.LearnieCP()

max = 11
## 3 variables
vars = Engine.Variables.makeIntVarArray(solver,3,0,max)

## The table to be used
table = [
    0 0 2;
    3 5 7;
    6 9 10;
    1 2 3;
    0 0 3;
]

## Declare the TableCT constraint
tableCT = Engine.TableCT{Integer}(vars, table);

## Display the contents of the table using a DataFrame
supports = tableCT.supports

## Column Definitions
xCols = map(i -> "x = $i", 0:max)
yCols = map(i -> "y = $i", 0:max)
zCols = map(i -> "z = $i", 0:max)

cols = [xCols...,yCols..., zCols...]

## Collect the vector of supports
data = Vector{Vector{Bool}}()

for i in eachindex(supports)
    for entry in supports[i]
        push!(data, entry)
    end
end

c_data = mapreduce(permutedims, vcat, data)
df_data = c_data'

df_data[:, 1]
## Place the values in a dataframe
using DataFrames

df_data = Int64.(df_data)
df = DataFrame(:index => collect(0:11))

### Extend the table
values_table = table
extra_rows = repeat([12 12 12], 7)
values_table = vcat(values_table, extra_rows)
extra_cols = [:x, :y, :z]

## Add the row values
for i in eachindex(extra_cols)
    insertcols!(df, extra_cols[i] => values_table[:, i])
end

## Add columns to the df
for i in eachindex(cols)
    insertcols!(df, Symbol(cols[i]) => df_data[:, i])
end

df

vscodedisplay(df)