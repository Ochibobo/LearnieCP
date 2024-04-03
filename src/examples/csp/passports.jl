using DataFrames
using CSV

## Data pre-processing
df = CSV.read("./data/passport/passport-index-matrix.csv", DataFrames.DataFrame)
first(df, 10)
## Move Afghanistan to the first column
select!(df, :Passport, :Afghanistan, Not([:Afghanistan]))

## Format all the rows (starrt from 2 to skip the first column)
for colName in names(df)[2:end]
    replace!(df[!, colName], "visa required" => "1")
    replace!(df[!, colName], "visa free" =>  "0")
    replace!(df[!, colName], "visa on arrival" => "0")
    replace!(df[!, colName], "e-visa" => "1")
    replace!(df[!, colName], "no admission" => "2")

    ## Cast the column to an integer type
    df[!, colName] = string.(df[!, colName])
    df[!, colName] = parse.(Int, df[!, colName])

    ## Assign the cells with values > 2 a value of 0
    replace!(x -> x > 2 ? 0 : x, df[!, colName])
end

first(df, 10)
