using GLMakie
using CSV
using DataFrames

clients = CSV.read(joinpath(@__DIR__, "client_positions.txt"), DataFrames.DataFrame)
LOCATION_UPPER_BOUND = 1000

fig = Figure();

ax1 = fig[1, 1] = Axis(fig,
    ## Title
    title = "Client-Facility Assignment",
    titlegap = 12, titlesize = 16,

    ## x axis definition
    xgridcolor = :darkgray, xgridwidth = 1,
    xlabel = "x co-ordinate", xlabelsize = 16,
    xticklabelsize = 12, xticks = LinearTicks(20),

    ## y axis
    ygridcolor = :darkgray, ygridwidth = 1,
    ylabel = "y co-ordinate", ylabelsize = 18,
    yticklabelsize = 12, yticks = LinearTicks(20),
);

limits!(ax1, 0, LOCATION_UPPER_BOUND, 0, LOCATION_UPPER_BOUND);

client_points = Point2f.(clients[:, :x], clients[:, :y])

## Scatter plot
scatter!(ax1, client_points);

## Facility positions
facilities = CSV.read(joinpath(@__DIR__,"facility_positions.txt"), DataFrame)
facility_points = Point2f.(facilities[:, :x], facilities[:, :y])
scatter!(
    ax1,
    facility_points,
    marker= :rect,
    color = :red,
)

## Read the changes in assignment
client_facility_assignment = CSV.read(joinpath(@__DIR__, "client_facility_assignment.txt"), DataFrame)
## Get the first row
row = client_facility_assignment[1, :]
row = Vector(row)

NUMBER_OF_CLIENTS = 8

## Simulate the assignment
for i in 1:NUMBER_OF_CLIENTS
    ## Get the facility location
    assigned_facility = row[i]

    lines!(
        ax1,
        [clients[i, :x], facilities[assigned_facility, :x]],
        [clients[i, :y], facilities[assigned_facility, :y]],
        color= :black,
    )
end


fig